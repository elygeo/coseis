"""
Utilities for accessing the Southern California Earthquake Data Center (SCEDC).

http://www.data.scec.org/
"""
import os, sys, time, urllib, struct, socket
from . import util


def mts( eventid, path='scsn-mts-%s.py' ):
    """
    Retrieve Moment Tensor Solution (MTS)

    Parameters
    ----------
        eventid : Event identification number

    Returns
    -------
        mts : Dictionary of MTS parameters

    MTS coordinate system: (x, y, z) = (north, east, down)

    For lower hemisphere moment tensor projection with obspy.imaging.beachball,
    use (up, south, east) coordinates with:
    fm = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']

    For SORD point source in (east, north, up) coordinates:
    source1 =  m['myy'],  m['mxx'],  m['mzz']
    source2 = -m['mxz'], -m['myz'],  m['mxy']
    """
    url = 'http://www.data.scec.org/MomentTensor/solutions/%s/' % eventid
    url = 'http://www.data.scec.org/MomentTensor/showMT.php?evid=%s' % eventid
    try:
        path = path % eventid
    except:
        pass
    if os.path.exists( path ):
        mts = {}
        exec( open( path ).read() ) in mts
        return mts
    print( 'Retrieving %s' % url )
    text = urllib.urlopen( url )
    mts = dict(
        url=url,
        mts_units = 'Newton-meters',
        mts_coordinates ='(x, y, z) = (north, east, down)',
    )
    clvd = {}
    dc   = {}
    for line in text.readlines():
        line = line.strip()
        if not line:
            continue
        elif ':' in line:
            f = line.split( ':', 1 )
        elif '=' in line:
            f = line.split( '=' )
        else:
            f = line.split()
        k = f[0].strip().lower().replace( ' ', '_' )
        if k == 'event_id':
            mts[k] = int( f[1] )
        elif k in ('magnitude', 'depth_(km)', 'latitude', 'longitude'):
            k = k.replace( '_(km)', '' )
            mts[k] = float( f[1] )
        elif k == 'origin_time':
            f = f[1].split()
            d = f[0].split( '/' )
            t = f[1].split( ':' )
            mts[k] = '%s-%s-%sT%s:%s:%s.%s' % (d[2], d[0], d[1], t[0], t[1], t[2], t[3])
        elif k == 'best_fitting_double_couple_and_clvd_solution':
            tensor = clvd
        elif k == 'best_fitting_double_couple_solution':
            tensor = dc
        elif k == 'moment_tensor':
            scale = 10 ** (int( f[1].split( '**' )[1].split()[0] ) - 7)
        elif k in ('mxx', 'myy', 'mzz', 'myz', 'mxz', 'mxy'):
            tensor[k] = scale * float( f[1] )
        elif k in ('t', 'n', 'p'):
            mts[k+'_axis'] = dict(
                value = float( f[1] ),
                plunge = float( f[2] ),
                azimuth = float( f[3] ),
            )
        elif k == 'mo':
            mts['moment'] = 1e-7 * float( f[1].split()[0] )
        elif k in ('np1', 'np2'):
            mts[k] = dict(
                strike = float( f[1] ),
                rake = float( f[2] ),
                dip = float( f[3] ),
            )
        elif k == 'moment_magnitude' and '=' in line:
            mts[k] = float( f[1] )
            break
    mts['double_couple_clvd'] = clvd
    mts['double_couple'] = dc
    util.save( path, mts, header='# SCSN moment tensor solution\n' )
    return mts


class stp():
    """
    Seismogram Transfer Program (STP) client.

    See STP Manual for command reference:
    http://www.data.scec.org/STP/STP_Manual_v1.01.pdf
    """

    def __init__( self, waveserver='scedc' ):
        domain, password = {
            'scedc': ('gps.caltech.edu', 'stpisgreat'),
            'ncedc': ('geo.berkeley.edu', 'hastalavista'),
        }[waveserver]
        host = 'stp', 'stp2', 'stp3'
        port = 9999
        addr = '%s.%s' % (host[0], domain), port
        self.sock = socket.socket()
        self.close = self.sock.close
        self.sock.connect( addr )
        self.sock.send( 'STP %s 1.6 stpc\n' % password )
        line = self.sock.recv( 16 )
        if line != 'CONNECTED\n':
            sys.exit( 'STP error' )
        two = struct.pack( 'i', 2 )
        self.__call__( [two], raw=True )
        return

    def __call__( self, cmd, raw=False ):
        if not raw:
            if type( cmd ) in [tuple, list]:
                cmd = '\n'.join( cmd )
            cmd = [s + '\n' for s in cmd.split( '\n' )]
        for cmd in cmd:
            self.sock.send( cmd )
            data = ''
            while( not data.endswith( 'OVER\n' ) ):
                data += self.sock.recv( 4096 )
            mess = None
            while( len( data ) > 0 ):
                i = data.index( '\n' ) + 1
                line, data = data[:i], data[i:]
                print( line )
                f = line.split()
                if f == []:
                    pass
                elif f[0] == 'OVER':
                    pass
                elif f[0] == 'ERR':
                    mess = line[4:]
                    print( mess )
                elif f[0] == 'FILE':
                    filename = f[1]
                elif f[0] == 'DIR':
                    dirname = f[1]
                    if not os.path.exists( dirname ):
                        os.makedirs( dirname )
                elif f[0] == 'DATA':
                    f = os.path.join( dirname, filename )
                    i = int( f[1] )
                    open( f, 'wb' ).write( data[:i] )
                    data = data[i:]
                elif f[0] == 'MESS':
                    i = data.index( 'ENDmess' )
                    mess, data = data[:i], data[i:]
                    print( mess )
                    i = data.index( '\n' )
                    data = data[i:]
                else:
                    sys.exit( 'Error: %s' % line )
            return

