"""
Southern California Earthquake Data Center (SCEDC) tools.
"""

import sys
if '' in sys.path:
    sys.path.remove('')
import os
import time
import struct
import socket
import urllib


class stp():
    """
    Seismogram Transfer Program (STP) client.

    Init parameters:

    waveserver: 'scedc' or 'ncedc' for N. or S. CA Earthquake Data Centers, or
        list of (host, port, password) triplets.

    Call parameters:

    cmd: STP command or list of commands.
    path: directory for saved files, default specified by server.
    verbose: diagnostic output.

    See STP Manual for command reference:
        http://www.data.scec.org/STP/STP_Manual_v1.01.pdf

    Excluded STP commands:
    ! (shell escape), SET, VERBOSE, INPUT, OUTPUT, EXIT

    Example:

    # download waveforms in SAC format and save station list:
    import cst
    with cst.scedc.stp('scedc') as stp:
        stp('status')
        stp(['sac', 'gain on'])
        stp('trig -net ci -chan _n_ -radius 20 14383980')
        out = stp('sta -l -net ci -chan _n_')
        open('station-list.txt', 'w').write(out[0])
    """
    presets = {
        'scedc': [
            ('stp.gps.caltech.edu',  9999, 'stpisgreat'),
            ('stp2.gps.caltech.edu', 9999, 'stpisgreat'),
            ('stp3.gps.caltech.edu', 9999, 'stpisgreat'),
        ],
        'ncedc': [
            ('stp.geo.berkeley.edu',  9999, 'hastalavista'),
            ('stp2.geo.berkeley.edu', 9999, 'hastalavista'),
            ('stp3.geo.berkeley.edu', 9999, 'hastalavista'),
        ],
    }

    def __init__(self, waveserver='scedc', retry=60):
        print('init')
        self.sock = socket.socket()
        self.send = self.sock.send
        self.close = self.sock.close
        if isinstance(waveserver, str):
            waveserver = self.presets[waveserver]
        for i in range(retry):
            for host, port, password in waveserver:
                print('STP: Connecting to ' + host)
                self.sock.connect((host, port))
                self.sock.send('STP %s 1.6 stpc\n' % password)
                line = self.sock.recv(16)
                conn = line == 'CONNECTED\n'
                if conn:
                    break
                self.sock.close()
                time.sleep(1)
            if conn:
                break
        if not conn:
            raise Exception('STP connection error')
        two = struct.pack('i', 2)
        self.send(two)
        self.receive()
        return

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.sock.close()
        return

    def __call__(self, cmd, path=None, verbose=False):
        if isinstance(cmd, (tuple, list)):
            cmd = '\n'.join(cmd)
        out = []
        for cmd in cmd.split('\n'):
            print(cmd)
            self.send(cmd + '\n')
            out += self.receive(path, verbose)
        if out:
            return out
        else:
            return

    def receive(self, path=None, verbose=False):
        dirname = path
        buff = self.sock.recv(4096)
        line = ''
        out = []
        while(line != 'OVER'):
            if len(buff) < 4096 and not buff.endswith('OVER\n'):
                buff += self.sock.recv(4096)
            line, buff = buff.split('\n', 1)
            key = line.split()
            if verbose:
                print(line)
            if key == []:
                pass
            elif key[0] == 'OVER':
                sys.stdout.write('STP> ')
            elif key[0] == 'MESS':
                i = buff.find('ENDmess\n')
                while i < 0:
                    buff += self.sock.recv(4096)
                    i = buff.find('ENDmess\n')
                mess, buff = buff[:i], buff[i:]
                out += [mess]
                print(mess)
                line, buff = buff.split('\n', 1)
            elif key[0] == 'FILE':
                filename = key[1]
            elif key[0] == 'DIR':
                if path is None:
                    dirname = key[1]
                if not os.path.exists(dirname):
                    os.makedirs(dirname)
            elif key[0] == 'DATA':
                f = os.path.join(dirname, filename)
                print(f)
                i = int(key[1])
                while(len(buff) < i):
                    buff += self.sock.recv(4096)
                open(f, 'wb').write(buff[:i])
                buff = buff[i:]
                if buff.find('ENDdata\n') < 0:
                    buff += self.sock.recv(4096)
                line, buff = buff.split('\n', 1)
            elif key[0] == 'ERR':
                print('ERROR: ' + line[4:])
            else:
                print('ERROR: ' + repr(line))
        return out


def mts(eventid):
    """
    Retrieve Moment Tensor Solution (MTS)
    Takes event identification number.
    Returns Dictionary of MTS parameters.

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

    print('Retrieving %s' % url)
    text = urllib.urlopen(url)
    mts = {
        'url': url,
        'mts_units': 'Newton-meters',
        'mts_coordinates': '(x, y, z) = (north, east, down)',
    }
    clvd = {}
    dc = {}
    for line in text.readlines():
        print(line)
        line = line.strip()
        if not line:
            continue
        elif ':' in line:
            f = line.split(':', 1)
        elif '=' in line:
            f = line.split('=')
        else:
            f = line.split()
        k = f[0].strip().lower().replace(' ', '_')
        if k == 'event_id':
            mts[k] = int(f[1])
        elif k in ('magnitude', 'depth_(km)', 'latitude', 'longitude'):
            k = k.replace('_(km)', '')
            mts[k] = float(f[1])
        elif k == 'origin_time':
            f = f[1].split()
            d = f[0].split('/')
            t = f[1].split(':')
            mts[k] = '%s-%s-%sT%s:%s:%s.%s' % (
                d[2], d[0], d[1], t[0], t[1], t[2], t[3])
        elif k == 'best_fitting_double_couple_and_clvd_solution':
            tensor = clvd
        elif k == 'best_fitting_double_couple_solution':
            tensor = dc
        elif k == 'moment_tensor':
            scale = 10 ** (int(f[1].split('**')[1].split()[0]) - 7)
        elif k in ('mxx', 'myy', 'mzz', 'myz', 'mxz', 'mxy'):
            tensor[k] = scale * float(f[1])
        elif k in ('t', 'n', 'p'):
            mts[k+'_axis'] = {
                'value': float(f[1]),
                'plunge': float(f[2]),
                'azimuth': float(f[3]),
            }
        elif k == 'mo':
            mts['moment'] = 1e-7 * float(f[1].split()[0])
        elif k in ('np1', 'np2'):
            mts[k] = {
                'strike': float(f[1]),
                'rake': float(f[2]),
                'dip': float(f[3]),
            }
        elif k == 'moment_magnitude' and '=' in line:
            mts[k] = float(f[1])
            break
    mts['double_couple_clvd'] = clvd
    mts['double_couple'] = dc
    mts['depth'] *= 1000.0
    return mts
