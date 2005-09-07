!------------------------------------------------------------------------------!
! GLOBALS

module globals_m

implicit none

integer, parameter :: nz = 256

integer :: &
  nn(3), nm(3), nhalo, offset(3), npml, bc(6), &
  nt, it, checkpoint, ip, np(3), wt(3), &
  hypocenter(3), nrmdim, downdim, nclramp, &
  outit(nz), &
  locknodes(nz,3), noper, nlock, nout, nmat, nfric, ntrac, nstress, &
  iamax(3), ivmax(3), iumax(3), iwmax(3), &
  i1node(3), i1cell(3), i1nodepml(3), i1cellpml(3), &
  i2node(3), i2cell(3), i2nodepml(3), i2cellpml(3), &
  i1(3), j1, k1, l1, &
  i2(3), j2, k2, l2, &
  i, j, k, l

integer, dimension(nz,6) :: ioper, ilock, iout, imat, ifric, itrac, istress

real :: &
  material(nz,3), friction(nz,4), traction(nz,3), stress(nz,6), &
  dx, dt, viscosity(2), vrup, rcrit, moment(6), msrcradius, domp, &
  amax, vmax, umax, wmax, vslipmax, uslipmax, xhypo(3), &
  nu, rho0, vp, vs, mu0, lam0, truptol

character :: oper(nz)
character(16) :: outvar(nz), grid='', srctimefcn=''
character(64) :: matdir='', fricdir='', tracdir='', stressdir='', griddir=''

real, allocatable, dimension(:) :: &
  dn1, dn2, dc1, dc2

real, allocatable, dimension(:,:,:) :: &
  s1, s2, rho, lam, mu, yc, yn, &
  uslip, vslip, trup, fs, fd, dc, co, area, r, tn, ts, f1, f2

real, allocatable, dimension(:,:,:,:) :: &
  p1, p2, p3, p4, p5, p6, &
  g1, g2, g3, g4, g5, g6, &
  x, u, v, w1, w2, &
  nrm, t0, t1, t2, t3

end module

