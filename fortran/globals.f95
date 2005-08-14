!------------------------------------------------------------------------------!
! GLOBALS
module globals

implicit none
integer, parameter :: nz = 256
integer :: n(4), npe(3), np(3), nt, npml, bc(6), edge(6), halo, &
  nrmdim, nclramp, &
  nmat, nfric, ntrac, nstress, nout, mati(nz,0), checkpoint, &
  nop, opi1(nz,3), opi2(nz,3) 
real :: dx, dt, nu, rho0, vp, vs, vrup, rcrit, viscosity(2), msrcradius, &
  material(nz,3), friction(nz,4), traction(nz,3), stress(nz,3)
real, allocatable, dimension(:) :: dn1, dn2
real, allocatable, dimension(:,:,:) :: s1, s2, rho, lam, miu, yc, yn
real, allocatable, dimension(:,:,:,:) :: x, u, v, w1, w2, &
  p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
character(nz) :: oper
character(256) :: grid

real, allocatable, dimension(:,:,:) :: uslip, vslip, trup

end module

