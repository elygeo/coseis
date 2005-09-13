!------------------------------------------------------------------------------!
! GLOBALS

module globals_m

implicit none

integer, parameter :: nz = 80

real, allocatable, dimension(:,:,:,:) :: &
  x, v, u, w1, w2, &
  p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6, &
  nrm, t0, t1, t2, t3

real, allocatable, dimension(:,:,:) :: &
  mr, lam, mu, y, s1, s2, &
  fs, fd, dc, co, area, r, us, vs, trup, tn, ts, f1, f2

real :: &
  material(nz,3), friction(nz,4), traction(nz,3), stress(nz,6), &
  dx, dt, viscosity(2), vrup, rcrit, moment(6), rsource, domp, &
  amax, vmax, umax, wmax, vsmax, usmax, &
  mu0, truptol, matmin(3), matmax(3), x0(3)

real, dimension(80) :: dn1, dn2, dc1, dc2

integer, dimension(3) :: &
  nn, nm, nf, np, noff, i0, &
  iamax, ivmax, iumax, iwmax, ivsmax, iusmax, &
  i1, i1node, i1cell, i1nodepml, i1cellpml, &
  i2, i2node, i2cell, i2nodepml, i2cellpml

integer, dimension(nz,6) :: ilock, iout, imat, ifric, itrac, istress

integer :: &
  ip, nhalo, i, j, k, l, j1, k1, l1, j2, k2, l2, j3, k3, l3, j4, k4, l4, &
  nt, it, itcheck, npml, bc(6), inrm, idown, nramp, wt(5), &
  noper, i1oper(2,3), i2oper(2,3), nlock, locknodes(nz,3), nout, itout(nz), &
  nmat, nfric, ntrac, nstress

character :: oper(2)
character(8) :: outvar(nz)
character(160) :: grid = '', srctimef = '', &
  matdir = '', fricdir = '', tracdir='', stressdir = '', griddir = ''

logical :: hypop = .false.

end module

