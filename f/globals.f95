!------------------------------------------------------------------------------!
! GLOBALS

module globals_m

implicit none

integer, parameter :: nz = 100, maxpml = 100

real, allocatable, dimension(:,:,:,:) :: &
  x, v, u, w1, w2, &
  p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
  nrm, t0, t1, t2, t3

real, allocatable, dimension(:,:,:) :: &
  rho, lam, mu, y, s1, s2, &
  fs, fd, dc, co, area, r, us, vs, trup, tn, ts, f1, f2

real :: &
  material(nz,3), friction(nz,4), traction(nz,3), stress(nz,6), &
  dx, dt, viscosity(2), vrup, rcrit, moment(6), msrcradius, domp, &
  amax, vmax, umax, wmax, vsmax, usmax, x0(3), &
  mu0, truptol, matmin(3), matmax(3), &
  dn1(maxpml), dn2(maxpml), dc1(maxpml), dc2(maxpml)

integer :: &
  nn(3), nm(3), nhalo, offset(3), npml, bc(6), &
  nt, it, checkpoint, np(3), ip, wt(5), &
  hypocenter(3), nrmdim, downdim, nclramp, &
  outit(nz), &
  locknodes(nz,3), noper, nlock, nout, nmat, nfric, ntrac, nstress, &
  iamax(3), ivmax(3), iumax(3), iwmax(3), ivsmax(3), iusmax(3), &
  i1node(3), i1cell(3), i1nodepml(3), i1cellpml(3), &
  i2node(3), i2cell(3), i2nodepml(3), i2cellpml(3), &
  i1(3), j1, k1, l1, &
  i2(3), j2, k2, l2, &
  i, j, k, l

integer, dimension(nz,6) :: ioper, ilock, iout, imat, ifric, itrac, istress

character :: oper(nz)
character(8) :: outvar(nz)
character(160) :: grid = '', srctimefcn = '', dir = '', &
  matdir = '', fricdir = '', tracdir='', stressdir = '', griddir = ''

logical :: hypop = .false.

end module

