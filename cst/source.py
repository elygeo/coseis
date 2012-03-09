"""
Source utilities
"""
import os
import numpy as np
from . import util, coord


def magarea(A):
    """
    Various earthquake magnitude area relations.
    """
    A = np.array(A, copy=False, ndmin=1)
    i = A > 537.0
    Mw = 3.98 + np.log10(A)
    Mw[i] = 3.07 + 4.0 / 3.0 * np.log10(A)
    Mw = dict(
        Hanks2008 = Mw,
        EllsworthB2003 = 4.2 + np.log10(A),
        Somerville2006 = 3.87 + 1.05 * np.log10(A),
        Wells1994 = 3.98 + 1.02 * np.log10(A),
    )
    return Mw


def areamag(Mw):
    """
    Various inverse earthquake magnitude area relations.
    """
    Mw = np.array(Mw, copy=False, ndmin=1)
    A = 10 ** (Mw - 3.98)
    i = A > 537.0
    A[i] = 10 ** ((Mw - 3.07) * 3.0 / 4.0)
    A = dict(
        Hanks2008 = A,
        EllsworthB2003 = 10 ** (Mw - 4.2),
        Somerville2006 = 10 ** ((Mw - 3.87) / 1.05),
        Wells1994 = 10 ** ((Mw - 3.98) / 1.02),
    )
    return A


def mw(moment, units='mks'):
    """
    Moment magnitude
    """
    if units=='mks':
        m = (np.log10(moment) - 9.05) / 1.5
    else:
        m = (np.log10(moment) - 16.05) / 1.5
    return m


def _open(fh, mode='r'):
    """
    Open a regular or compressed file if not already opened.
    """
    if isinstance(fh, basestring):
        fh = os.path.expanduser(fh)
        if fh.endswith('.gz'):
            import gzip
            fh = gzip.open(fh, mode)
        else:
            fh = open(fh, mode)
    return fh


class srf():
    """
    Utilities for Graves Standard Rupture Format (SRF).

    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    """
    def __init__(self, filename):
        """
        Read SRF file.
        """

        # mks units
        u_km = 1000
        u_cm = 0.01
        u_cm2 = 0.0001

        # open file
        with _open(filename) as fh:

            # header block
            self.version = fh.next().split()[0]
            k = fh.next().split()
            if k[0] == 'PLANE':
                self.plane = []
                for i in range(int(k[1])):
                    k = fh.next().split() + fh.next().split()
                    if len(k) != 11:
                        raise Exception('error reading %s' % filename)
                    seg = {
                        'topcenter': (float(k[0]), float(k[1]), float(k[8])),
                        'shape': (int(k[2]), int(k[3])),
                        'length': (float(k[4]) * u_km, float(k[5]) * u_km),
                        'strike': float(k[6]),
                        'dip': float(k[7]),
                        'hypocenter': (float(k[9]) * u_km, float(k[10]) * u_km),
                    }
                    x, y = seg['length']
                    j, k = seg['shape']
                    seg['area'] = x * y
                    seg['delta'] = x / j, y / k
                    self.plane += [seg]
                k = fh.next().split()
            if k[0] != 'POINTS':
                raise Exception('error reading %s' % filename)
            self.nsource = int(k[1])

            # data block
            n = self.nsource
            self.lon = np.empty(n, 'f')
            self.lat = np.empty(n, 'f')
            self.dep = np.empty(n, 'f')
            self.stk = np.empty(n, 'f')
            self.dip = np.empty(n, 'f')
            self.rake = np.empty(n, 'f')
            self.area = np.empty(n, 'f')
            self.t0 = np.empty(n, 'f')
            self.dt = np.empty(n, 'f')
            self.slip1 = np.empty(n, 'f')
            self.slip2 = np.empty(n, 'f')
            self.slip3 = np.empty(n, 'f')
            self.nt1 = np.empty(n, 'i')
            self.nt2 = np.empty(n, 'i')
            self.nt3 = np.empty(n, 'i')
            sv1 = []
            sv2 = []
            sv3 = []
            for i in range(n):
                k = fh.next().split() + fh.next().split()
                if len(k) != 15:
                    raise Exception('error reading %s %s' % (filename, i))
                self.lon[i] = float(k[0])
                self.lat[i] = float(k[1])
                self.dep[i] = float(k[2]) * u_km
                self.stk[i] = float(k[3])
                self.dip[i] = float(k[4])
                self.rake[i] = float(k[8])
                self.area[i] = float(k[5]) * u_cm2
                self.t0[i] = float(k[6])
                self.dt[i] = float(k[7])
                self.slip1[i] = float(k[9]) * u_cm
                self.slip2[i] = float(k[11]) * u_cm
                self.slip3[i] = float(k[13]) * u_cm
                self.nt1[i] = int(k[10])
                self.nt2[i] = int(k[12])
                self.nt3[i] = int(k[14])
                sv = []
                n = np.cumsum([self.nt1[i], self.nt2[i], self.nt3[i]])
                while len(sv) < n[-1]:
                    sv += fh.next().split()
                if len(sv) != n[-1]:
                    raise Exception('error reading %s %s' % (filename, i))
                sv1 += [float(f) * u_cm for f in sv[:n[0]]]
                sv2 += [float(f) * u_cm for f in sv[n[0]:n[1]]]
                sv3 += [float(f) * u_cm for f in sv[n[1]:]]
            self.sv1 = sv1 = np.array(sv1, 'f')
            self.sv2 = sv2 = np.array(sv2, 'f')
            self.sv3 = sv3 = np.array(sv3, 'f')

        # useful meta data
        i1 = (self.nt1 > 0).sum()
        i2 = (self.nt2 > 0).sum()
        i3 = (self.nt3 > 0).sum()
        self.nsource_nonzero = i1 + i2 + i3
        i = np.argmin(self.t0)
        self.hypocenter = self.lon.flat[i], self.lat.flat[i], self.dep.flat[i]
        self.area_total = self.area.sum()
        self.potency = np.sqrt(
            (self.area * self.slip1).sum() ** 2 +
            (self.area * self.slip2).sum() ** 2 +
            (self.area * self.slip3).sum() ** 2)
        self.displacement = self.potency / self.area_total
        return


    def write_srf(self, filename):

        # mks units
        u_km = 0.001
        u_cm = 100
        u_cm2 = 10000

        # open file
        with _open(filename, 'w') as fh:

            # header block
            fh.write('%s\n' % self.version)
            if hasattr(self, 'plane'):
                for i, seg in enumerate(self.plane):
                    fh.write('PLANE %s\n%s %s %s %s %s %s\n%s %s %s %s %s\n' % (
                        i + 1,
                        seg['topcenter'][0],
                        seg['topcenter'][1],
                        seg['shape'][0],
                        seg['shape'][1],
                        seg['length'][0] * u_km,
                        seg['length'][1] * u_km,
                        seg['strike'],
                        seg['dip'],
                        seg['topcenter'][2],
                        seg['hypocenter'][0] * u_km,
                        seg['hypocenter'][1] * u_km,
                    ))

            # data block
            fh.write(('POINTS %s\n' % self.nsource))
            i1 = 0
            i2 = 0
            i3 = 0
            for i in range(self.nsource):
                fh.write('%s %s %s %s %s %s %s %s\n%s %s %s %s %s %s %s\n' % (
                    self.lon[i],
                    self.lat[i],
                    self.dep[i] * u_km,
                    self.stk[i],
                    self.dip[i],
                    self.area[i] * u_cm2,
                    self.t0[i],
                    self.dt[i],
                    self.rake[i],
                    self.slip1[i] * u_cm,
                    self.nt1[i],
                    self.slip2[i] * u_cm,
                    self.nt2[i],
                    self.slip3[i] * u_cm,
                    self.nt3[i],
                ))
                n1 = self.nt1[i]
                n2 = self.nt2[i]
                n3 = self.nt3[i]
                s1 = self.sv1[i1:i1+n1] * u_cm
                s2 = self.sv2[i2:i2+n2] * u_cm
                s3 = self.sv3[i3:i3+n3] * u_cm
                s = np.concatenate([s1, s2, s3])
                i = s.size // 6 * 6
                np.savetxt(fh, s[:i].reshape([-1,6]), '%13.5e', '')
                np.savetxt(fh, s[i:].reshape([1,-1]), '%13.5e', '')
                i1 += n1
                i2 += n2
                i3 += n3
        return


    def write_py(self, path):
        """
        Save SRF as a Python source file.
        """
        util.save(path, self,
            expand=['plane'],
            prune_pattern='(^_)|(_$)',
            header='# source parameters\nfrom numpy import array, load, float32\n',
        )
        return


    def write_sord(self, path='source', delta=(1,1,1), proj=None, dbytes=4):
        """
        Write potency tensor SORD input files.

        Parameters
        ----------
        path: location on disk
        delta: grid step size (dx, dy, dz)
        proj: function to project lon/lat to logical model coordinates
        dbytes: 4 or 8
        """

        # setup
        i_ = 'i%s' % dbytes
        f_ = 'f%s' % dbytes
        path = os.path.expanduser(path) + os.sep
        os.mkdir(path)

        # time
        i1 = self.nt1 > 0
        i2 = self.nt2 > 0
        i3 = self.nt3 > 0
        f1 = open(path + 'nt.bin', 'wb')
        f2 = open(path + 'dt.bin', 'wb')
        f3 = open(path + 't0.bin', 'wb')
        with f1, f2, f3:
            self.nt1[i1].astype(i_).tofile(f1)
            self.nt2[i2].astype(i_).tofile(f1)
            self.nt3[i3].astype(i_).tofile(f1)
            for i in i1, i2, i3:
                self.dt[i].astype(f_).tofile(f2)
                self.t0[i].astype(f_).tofile(f3)

        # coordinates
        x = self.lon
        y = self.lat
        z = self.dep
        if proj:
            rot = coord.rotation(x, y, proj)[1]
            x, y = proj(x, y)
        else:
            rot = 0.0
        x = 1.0 + x / delta[0]
        y = 1.0 + y / delta[1]
        z = 1.0 + z / delta[2]
        f1 = open(path + 'xi1.bin', 'wb')
        f2 = open(path + 'xi2.bin', 'wb')
        f3 = open(path + 'xi3.bin', 'wb')
        with f1, f2, f3:
            for i in i1, i2, i3:
                x[i].astype(f_).tofile(f1)
                y[i].astype(f_).tofile(f2)
                z[i].astype(f_).tofile(f3)
        del(x, y, z)

        # fault local coordinate system
        s1, s2, n = coord.slip_vectors(self.stk + rot, self.dip, self.rake)
        p1 = self.area * coord.potency_tensor(n, s1)
        p2 = self.area * coord.potency_tensor(n, s2)
        p3 = self.area * coord.potency_tensor(n, n)
        del(s1, s2, n)

        # tensor components
        f11 = open(path + 'w11.bin', 'wb')
        f22 = open(path + 'w23.bin', 'wb')
        f33 = open(path + 'w33.bin', 'wb')
        f23 = open(path + 'w23.bin', 'wb')
        f31 = open(path + 'w31.bin', 'wb')
        f12 = open(path + 'w12.bin', 'wb')
        with f11, f22, f33, f23, f31, f12:
            for p, i in (p1, i1), (p2, i2), (p3, i3):
                p[0,0,i].astype(f_).tofile(f11)
                p[0,1,i].astype(f_).tofile(f22)
                p[0,2,i].astype(f_).tofile(f33)
                p[1,0,i].astype(f_).tofile(f23)
                p[1,1,i].astype(f_).tofile(f31)
                p[1,2,i].astype(f_).tofile(f12)
        del(p1, p2, p3)

        # time history
        i1 = 0
        i2 = 0
        i3 = 0
        fh = open(path + 'history.bin', 'wb')
        with fh:
            for i in range(self.nsource):
                n = self.nt1[i]
                s = self.sv1[i1:i1+n].cumsum() * self.dt[i]
                s.astype(f_).tofile(fh)
                i1 += n
            for i in range(self.nsource):
                n = self.nt2[i]
                s = self.sv2[i2:i2+n].cumsum() * self.dt[i]
                s.astype(f_).tofile(fh)
                i2 += n
            for i in range(self.nsource):
                n = self.nt3[i]
                s = self.sv3[i3:i3+n].cumsum() * self.dt[i]
                s.astype(f_).tofile(fh)
                i3 += n
        return


    def write_awp(self, filename, t, mu, lam=0.0, delta=1.0, proj=None,
        binary=True, interp='linear'):
        """
        Write ODC-AWP moment rate input file.

        Parameters
        ----------
        delta: grid step size (dx, dy, dz)
        t: array of time
        mu, lam: elastic moduli
        proj: Function to project lon/lat to logical model coordinates
        binary: If true, write AWP binary format, otherwise text format.
        """
        if type(delta) not in (tuple, list):
            delta = delta, delta, delta

        # coordinates
        x = self.lon
        y = self.lat
        z = self.dep
        if proj:
            rot = coord.rotation(x, y, proj)[1]
            x, y = proj(x, y)
        else:
            rot = 0.0
        jj = (x / delta[0] + 1.5).astype('i')
        kk = (y / delta[1] + 1.5).astype('i')
        ll = (z / delta[2] + 1.5).astype('i')
        del(x, y, z)

        # moment tensor components
        s1, s2, n = coord.slip_vectors(self.stk + rot, self.dip, self.rake)
        m1 = mu * self.area * coord.potency_tensor(n, s1) * 2.0
        m2 = mu * self.area * coord.potency_tensor(n, s2) * 2.0
        m3 = lam * self.area * coord.potency_tensor(n, n) * 2.0
        del(s1, s2, n)

        # write file
        i1 = 0
        i2 = 0
        i3 = 0
        s = np.zeros_like
        with _open(filename, 'wb') as fh:
            for i in range(self.dt.size):
                n1 = self.nt1[i]
                n2 = self.nt2[i]
                n3 = self.nt3[i]
                s1 = self.sv1[i1:i1+n1]
                s2 = self.sv2[i2:i2+n2]
                s3 = self.sv3[i3:i3+n3]
                t1 = self.t0[i], self.t0[i] + self.dt[i] * (n1 - 1)
                t2 = self.t0[i], self.t0[i] + self.dt[i] * (n2 - 1)
                t3 = self.t0[i], self.t0[i] + self.dt[i] * (n3 - 1)
                s1 = coord.interp(t1, s1, t, s(t), interp, bound=True)
                s2 = coord.interp(t2, s2, t, s(t), interp, bound=True)
                s3 = coord.interp(t3, s3, t, s(t), interp, bound=True)
                ii = np.array([[jj[i], kk[i], ll[i]]], 'i')
                mm = np.array([
                    m1[0,0,i] * s1 + m2[0,0,i] * s2 + m3[0,0,i] * s3,
                    m1[0,1,i] * s1 + m2[0,1,i] * s2 + m3[0,1,i] * s3,
                    m1[0,2,i] * s1 + m2[0,2,i] * s2 + m3[0,2,i] * s3,
                    m1[1,1,i] * s1 + m2[1,1,i] * s2 + m3[1,1,i] * s3,
                    m1[1,0,i] * s1 + m2[1,0,i] * s2 + m3[1,0,i] * s3,
                    m1[1,2,i] * s1 + m2[1,2,i] * s2 + m3[1,2,i] * s3,
                ])
                if binary:
                    mm.astype('f').tofile(fh)
                else:
                    np.savetxt(fh, ii, '%d')
                    np.savetxt(fh, mm.T, '%14.6e')
                i1 += n1
                i2 += n2
                i3 += n3
        return


    def write_coulomb(self, path, proj, scut=0):
        """
        Write Coulomb input file.
        """

        # output location
        path = os.path.expanduser(path)

        # slip components
        s1, s2  = self.slip1, self.slip2
        s = np.sin(np.pi / 180.0 * self.rake)
        c = np.cos(np.pi / 180.0 * self.rake)
        r1 = -c * s1 + s * s2
        r2 =  s * s1 + c * s2

        # coordinates
        x, y, z = self.lon, self.lat, self.dep
        rot = coord.rotation(x, y, proj)[1]
        x, y = proj(x, y)
        x *= 0.001
        y *= 0.001
        z *= 0.001
        delta = 0.0005 * self.plane[0]['delta'][0]
        dx = delta * np.sin(np.pi / 180.0 * (self.stk + rot))
        dy = delta * np.cos(np.pi / 180.0 * (self.stk + rot))
        dz = delta * np.sin(np.pi / 180.0 * self.dip)
        x1, x2 = x - dx, x + dx
        y1, y2 = y - dy, y + dy
        z1, z2 = z - dz, z + dz

        # source file
        i = (s1**2 + s2**2) > (np.sign(scut) * scut**2)
        c = np.array([x1[i], y1[i], x2[i], y2[i], r1[i], r2[i], self.dip[i], z1[i], z2[i]]).T
        with open(path + 'source.inp', 'w') as fh:
            fh.write(coulomb_header % self.__dict__)
            np.savetxt(fh, c, coulomb_fmt)
            fh.write(coulomb_footer)

        # receiver file
        s1.fill(0.0)
        c = np.array([x1, y1, x2, y2, s1, s1, self.dip, z1, z2]).T
        with open(path + 'receiver.inp', 'w') as fh:
            fh.write(coulomb_header % self.__dict__)
            np.savetxt(fh, c, coulomb_fmt)
            fh.write(coulomb_footer)
        return

coulomb_fmt = '  1' + 4*' %10.4f' + ' 100' + 5*' %10.4f' + '    Fault 1'

coulomb_header = """\
header line 1
header line 2
#reg1=  0  #reg2=  0  #fixed=  {nsource}  sym=  1
 PR1=       0.250     PR2=       0.250   DEPTH=      12.209
  E1=     8.000e+005   E2=     8.000e+005
XSYM=       .000     YSYM=       .000
FRIC=          0.400
S1DR=         19.000 S1DP=         -0.010 S1IN=        100.000 S1GD=          0.000
S2DR=         89.990 S2DP=         89.990 S2IN=         30.000 S2GD=          0.000
S3DR=        109.000 S3DP=         -0.010 S3IN=          0.000 S3GD=          0.000

  #   X-start    Y-start     X-fin      Y-fin   Kode  rt.lat    reverse   dip angle     top      bot
xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
"""

coulomb_footer = """
   Grid Parameters
  1  ----------------------------  Start-x =     -100.0
  2  ----------------------------  Start-y =        0.0
  3  --------------------------   Finish-x =      500.0
  4  --------------------------   Finish-y =      400.0
  5  ------------------------  x-increment =        5.0
  6  ------------------------  y-increment =        5.0
     Size Parameters
  1  --------------------------  Plot size =        2.0
  2  --------------  Shade/Color increment =        1.0
  3  ------  Exaggeration for disp.& dist. =    10000.0

     Cross section default
  1  ----------------------------  Start-x =     -126.4
  2  ----------------------------  Start-y =     -124.6
  3  --------------------------   Finish-x =       40.0
  4  --------------------------   Finish-y =       40.0
  5  ------------------  Distant-increment =        1.0
  6  ----------------------------  Z-depth =       30.0
  7  ------------------------  Z-increment =        1.0
     Map info
  1  ---------------------------- min. lon =     -128.0
  2  ---------------------------- max. lon =     -123.0
  3  ---------------------------- zero lon =     -125.0
  4  ---------------------------- min. lat =       39.5
  5  ---------------------------- max. lat =       42.5
  6  ---------------------------- zero lat =       40.0
"""

