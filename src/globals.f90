! Global variables
module m_globals
implicit none

real, parameter :: &
  pi = 3.14159

! 4d vectors
real, allocatable, dimension(:,:,:,:,:) :: &
  bb               ! B matrix

! 3d vectors
real, allocatable, target, dimension(:,:,:,:) :: &
  xx,            & ! node locations
  vv,            & ! velocity
  uu,            & ! displacement
  z1,            & ! anelastic memory variable
  z2,            & ! anelastic memory variable
  w1,            & ! temporary storage
  w2               ! temporary storage

! 3d scalars
real, allocatable, target, dimension(:,:,:) :: &
  mr,            & ! mass ratio
  lam,           & ! Lame parameter
  mu,            & ! Lame parameter
  gam,           & ! viscosity
  qp,            & ! anelastic coefficient
  qs,            & ! anelastic coefficient
  yy,            & ! hourglass constant
  s1,            & ! temporary storage
  s2               ! temporary storage

! PML state
real, allocatable, dimension(:,:,:,:) :: &
  p1,            & ! j1 pml momentum
  p2,            & ! k1 pml momentum
  p3,            & ! l1 pml momentum
  p4,            & ! j2 pml momentum
  p5,            & ! k2 pml momentum
  p6,            & ! l2 pml momentum
  g1,            & ! j1 pml gradient
  g2,            & ! k1 pml gradient
  g3,            & ! l1 pml gradient
  g4,            & ! j2 pml gradient
  g5,            & ! k2 pml gradient
  g6               ! l2 pml gradient

! 1D dynamic arrays
real, allocatable, dimension(:) :: &
  dx1,           & ! x rectangular element size
  dx2,           & ! y rectangular element size
  dx3,           & ! z rectangular element size
  dn1,           & ! pml node damping -2*d     / (2+d*dt)
  dn2,           & ! pml node damping  2       / (2+d*dt)
  dc1,           & ! pml cell damping (2-d*dt) / (2+d*dt)
  dc2              ! pml cell damping  2*dt    / (2+d*dt)

! Fault vectors
real, allocatable, target, dimension(:,:,:,:) :: &
  nhat,          & ! fault surface normals
  t0,            & ! initial traction
  t1,            & ! temporary storage
  t2,            & ! temporary storage
  t3               ! temporary storage

! Fault scalars
real, allocatable, target, dimension(:,:,:) :: &
  mus,           & ! coef of static friction
  mud,           & ! coef of dynamic friction
  dc,            & ! slip weakening distance
  co,            & ! cohesion
  area,          & ! fault element area
  rhypo,         & ! radius to hypocenter
  muf,           & ! shear modulus at the fault nodes
  sl,            & ! slip path length
  psv,           & ! peak slip velocity magnitude
  trup,          & ! rupture time
  tarr,          & ! rise time
  tn,            & ! temporary storage
  ts,            & ! temporary storage
  f1,            & ! temporary storage
  f2               ! temporary storage

! Parameters
real :: &
  dt,            & ! time step
  tm,            & ! time
  tm0,           & ! initial time
  dx,            & ! spatial step
  rho1,          & ! min density
  rho2,          & ! max density
  vp1,           & ! min P-wave speed
  vp2,           & ! max P-wave speed
  vs1,           & ! min S-wave speed
  vs2,           & ! max S-wave speed
  gam1,          & ! min viscosity
  gam2,          & ! max viscosity
  hourglass(2),  & ! hourglass stiffness (1) and viscosity (2)
  vdamp,         & ! shear wave velocity dependent damping
  rexpand,       & ! grid expansion ratio
  affine(9),     & ! grid transformation
  gridnoise,     & ! random noise in grid
  xhypo(3),      & ! hypocenter location
  slipvector(3)    ! slip direction for finding traction vectors

! Source parameters
real :: &
  tsource,       & ! dominant period
  rsource,       & ! source radius
  moment1(3),    & ! moment source normal components
  moment2(3),    & ! moment source shear components
  vrup,          & ! nucleation rupture velocity
  rcrit,         & ! nucleation critical radius
  trelax,        & ! nucleation relaxation time
  svtol            ! slip velocity for determining rupture time

integer, dimension(3) :: &
  np,            & ! number of processes
  nn,            & ! number of global nodes, count double nodes twice
  ihypo,         & ! hypocenter node
  bc1,           & ! boundary conditions - near side
  bc2,           & ! boundary conditions - far side
  n1expand,      & ! grid expansion nodes - near side
  n2expand,      & ! grid expansion nodes - far side
  nm,            & ! size of local 3D arrays
  nhalo,         & ! number of ghost nodes
  ip3,           & ! 3D process rank
  ip3root,       & ! 3D master process rank
  i1bc,          & ! model boundary
  i2bc,          & ! model boundary
  i1pml,         & ! PML boundary
  i2pml,         & ! PML boundary
  i1core,        & ! core region start index
  i2core,        & ! core region end index
  i1node,        & ! node calculations start index
  i2node,        & ! node calculations end index
  i1cell,        & ! cell calculations start index
  i2cell,        & ! cell calculations end index
  nnoff            ! offset between local and global indices

integer :: &
  it,            & ! current time step
  nt,            & ! number of time steps
  itstats,       & ! interval for calculating statistics
  itio,          & ! interval for writing i/o buffers
  itcheck,       & ! interval for checkpointing, must be a multiple of itio
  itstop,        & ! stop time, for simulating a killed job
  npml,          & ! number of PML damping nodes
  oplevel,       & ! 1=constant, 2=rectangular, 3=parallelepiped, 4=one-point quadrature, 5=exact
  fixhypo,       & ! fix hypocenter to 0=none, 1,2=ihypo node, cell, -1,-2=xhypo node, cell
  mpin,          & ! collective MPI input flag
  mpout,         & ! collective MPI output flag
  debug,         & ! debugging flag
  faultopening,  & ! flag to allow fault opening
  faultnormal,   & ! fault normal direction
  ifn,           & ! fault normal component=abs(faultnormal)
  ip,            & ! process rank
  ipid,          & ! processor ID
  np0              ! number of processes available

character(16) :: &
  rfunc,         & ! moment source space function
  tfunc            ! moment source time function

character(256) :: &
  str              ! string for storing file names

logical :: &
  sync,          & ! synchronize processes
  master           ! master process flag

end module

