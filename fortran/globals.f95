!------------------------------------------------------------------------------!
! GLOBALS

module globals

implicit none
integer, parameter :: nz = 256
character :: oper(nz)
character(8) :: outvar(nz)
real :: material(nz,3), friction(nz,4), traction(nz,3), stress(nz,6)
integer :: locknodes(nz,3), noper, nlock, nout, nmat, nfric, ntrac, nstress
integer :: outit(nz)
integer, dimension(nz,6) :: ioper, ilock, iout, imat, ifric, itrac, istress

integer :: wt(6), wt_rate
real :: dwt(6)

character(256) :: grid
integer :: &
  n(4), nl(3), ng(3), nhalo, offset(3), npml, bc(6), &
  nt, it, checkpoint, ip, np(3), &
  hypocenter(3), nrmdim, downdim, nclramp, &
  amaxi(3), vmaxi(3), umaxi(3), wmaxi(3), verb = 1, &
  i1node(3), i1cell(3), i1nodepml(3), i1cellpml(3), &
  i2node(3), i2cell(3), i2nodepml(3), i2cellpml(3), &
  i1(3), j1, k1, l1, &
  i2(3), j2, k2, l2, &
  i, j, k, l
real :: &
  dx, dt, nu, rho0, vp, vs, miu0, lam0, vrup, rcrit, truptol, &
  viscosity(2), gam(2), msrcradius, amax, vmax, umax, wmax, hypoloc(3)

real, allocatable, dimension(:) :: dn1, dn2, dc1, dc2
real, allocatable, dimension(:,:,:) :: uslip, vslip, trup
real, allocatable, dimension(:,:,:) :: s1, s2, rho, lam, miu, yc, yn
real, allocatable, dimension(:,:,:,:) :: &
  p1, p2, p3, p4, p5, p6, &
  g1, g2, g3, g4, g5, g6, &
  x, u, v, w1, w2

end module

