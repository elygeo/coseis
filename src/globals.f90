! Global variables
module m_globals
implicit none

! Input parameters, see defaults.py for documentation
integer, dimension(3) :: np3, nn, ihypo, bc1, bc2, n1expand, n2expand
integer :: nt, itstats, itio, itcheck, itstop, npml, oplevel, fixhypo, mpin, &
  mpout, debug, faultopening, faultnormal
real :: tm0, dt, dx, rho1, rho2, vp1, vp2, vs1, vs2, gam1, gam2, hourglass(2), &
  vdamp, rexpand, affine(9), gridnoise, xhypo(3), slipvector(3)
real :: tsource, rsource, moment1(3), moment2(3), vrup, rcrit, trelax, svtol
character(16) :: rfunc, tfunc

! Miscellaneous parameters
real, parameter :: pi = 3.14159
real :: &
  iotimer,        & ! I/O timing
  tm                ! time
integer :: &
  it,             & ! current time step
  ifn,            & ! fault normal component=abs(faultnormal)
  ip,             & ! process rank
  ipid,           & ! processor ID
  np0               ! number of processes available
integer, dimension(3) :: &
  nm,             & ! size of local 3D arrays
  nhalo,          & ! number of ghost nodes
  ip3,            & ! 3D process rank
  ip3root,        & ! 3D master process rank
  i1bc, i2bc,     & ! model boundary
  i1pml, i2pml,   & ! PML boundary
  i1core, i2core, & ! core region
  i1node, i2node, & ! node region
  i1cell, i2cell, & ! cell region
  nnoff             ! offset between local and global indices
logical :: &
  sync,           & ! synchronize processes
  verb,           & ! print messages
  master            ! master process flag
character(256) :: &
  str               ! string for storing file names

! 1D dynamic arrays
real, allocatable, dimension(:) :: &
  dx1, dx2, dx3,  & ! x, y, z rectangular element size
  dn1,            & ! pml node damping -2*d     / (2+d*dt)
  dn2,            & ! pml node damping  2       / (2+d*dt)
  dc1,            & ! pml cell damping (2-d*dt) / (2+d*dt)
  dc2               ! pml cell damping  2*dt    / (2+d*dt)

! PML state
real, allocatable, dimension(:,:,:,:) :: &
  p1, p2, p3,     & ! pml momentum near side
  p4, p5, p6,     & ! pml momentum far side
  g1, g2, g3,     & ! pml gradient near side
  g4, g5, g6        ! pml gradient far side

! B matrix
real, allocatable, dimension(:,:,:,:,:) :: bb

! Volume fields
real, allocatable, target, dimension(:,:,:) :: &
  mr,             & ! mass ratio
  lam, mu,        & ! Lame parameters
  gam,            & ! viscosity
  qp, qs,         & ! anelastic coefficients
  yy,             & ! hourglass constant
  s1, s2            ! temporary storage
real, allocatable, target, dimension(:,:,:,:) :: &
  xx,             & ! node locations
  vv,             & ! velocity
  uu,             & ! displacement
  z1, z2,         & ! anelastic memory variables
  w1, w2            ! temporary storage

! Fault surface fields
real, allocatable, target, dimension(:,:,:) :: &
  mus,            & ! coef of static friction
  mud,            & ! coef of dynamic friction
  dc,             & ! slip weakening distance
  co,             & ! cohesion
  area,           & ! fault element area
  rhypo,          & ! radius to hypocenter
  muf,            & ! shear modulus at the fault nodes
  sl,             & ! slip path length
  psv,            & ! peak slip velocity
  trup,           & ! rupture time
  tarr,           & ! arrest time
  tn, ts, f1, f2    ! temporary storage
real, allocatable, target, dimension(:,:,:,:) :: &
  nhat,           & ! fault surface normals
  t0,             & ! initial traction
  t1, t2, t3        ! temporary storage

end module

