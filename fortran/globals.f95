!------------------------------------------------------------------------------!
! GLOBALS
module globals

implicit none
integer, parameter :: nz = 255
integer :: n(4), np(3), npg(3), nt, npml, bc(6), nhalo, ipe, &
  i1node(3), i2node(3), i1cell(3), i2cell(3), i1cellpml(3), i2cellpml(3), &
  nrmdim, nclramp, hypocenter(3), &
  nmat, nfric, ntrac, nstress, nout, mati(nz,0), &
  noper, operi(nz,6), nlock, locknodes(nz,9), checkpoint, &
  umaxi(3), vmaxi(3), wmaxi(3), &
  i, i1(3), i2(3), j, j1, j2, k, k1, k2, l, l1, l2
real :: dx, dt, nu, rho0, vp, vs, miu0, lam0, vrup, rcrit, viscosity(2), gam(2), &
  msrcradius, umax, vmax, wmax, &
  material(nz,3), friction(nz,4), traction(nz,3), stress(nz,6), hypoloc(3)
real, allocatable, dimension(:) :: dn1, dn2, dc1, dc2
real, allocatable, dimension(:,:,:) :: s1, s2, rho, lam, miu, yc, yn
real, allocatable, dimension(:,:,:,:) :: x, u, v, w1, w2, &
  p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
character :: oper(nz)
character(255) :: grid

real, allocatable, dimension(:,:,:) :: uslip, vslip, trup

end module

