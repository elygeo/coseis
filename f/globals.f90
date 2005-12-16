! Global variables
module globals_m

implicit none

real, parameter :: &
  pi = 3.14159

integer, parameter :: &
  nz = 80,      & ! max number of input and output zones
  nhalo = 1       ! number of ghost nodes

! 3D vectors
real, allocatable, dimension(:,:,:,:) :: &
  x,            & ! node locations
  v,            & ! **velocity
  u,            & ! **displacement
  w1,           & ! temporary storage
  w2              ! temporary storage

! 3D scalars
real, allocatable, dimension(:,:,:) :: &
  mr,           & ! mass ratio
  lam,          & ! Lame parameter
  mu,           & ! Lame parameter
  y,            & ! hourglass constant
  s1,           & ! temporary storage
  s2              ! temporary storage

! PML state
real, allocatable, dimension(:,:,:,:) :: &
  p1,           & ! **j1 pml momentum
  p2,           & ! **k1 pml momentum
  p3,           & ! **l1 pml momentum
  p4,           & ! **j2 pml momentum
  p5,           & ! **k2 pml momentum
  p6,           & ! **l2 pml momentum
  g1,           & ! **j1 pml gradient
  g2,           & ! **k1 pml gradient
  g3,           & ! **l1 pml gradient
  g4,           & ! **j2 pml gradient
  g5,           & ! **k2 pml gradient
  g6              ! **l2 pml gradient

! PML damping
real, allocatable, dimension(:) :: &
  dn1,          & ! pml node damping -2*d     / (2+d*dt)
  dn2,          & ! pml node damping  2       / (2+d*dt)
  dc1,          & ! pml cell damping (2-d*dt) / (2+d*dt)
  dc2             ! pml cell damping  2*dt    / (2+d*dt)

! Fault vectors
real, allocatable, dimension(:,:,:,:) :: &
  nhat,         & ! fault surface normals
  t0,           & ! initial traction
  t1,           & ! temporary storage
  t2,           & ! temporary storage
  t3              ! temporary storage

! Fault scalars
real, allocatable, dimension(:,:,:) :: &
  mus,          & ! coef of static friction
  mud,          & ! coef of dynamic friction
  dc,           & ! slip weakening distance
  co,           & ! cohesion
  area,         & ! fault element area
  rhypo,        & ! radius to hypocenter
  sv,           & ! **slip velocity magnitude
  sl,           & ! **slip path length
  trup,         & ! **rupture time
  tarr,         & ! **rise time
  tn,           & ! temporary storage
  ts,           & ! temporary storage
  f1,           & ! temporary storage
  f2              ! temporary storage

real :: &
  t,            & ! **time
  dt,           & ! time step
  dx,           & ! spatial step
  inval(nz),    & ! input value
  rho0,         & ! hypocenter density
  rho1,         & ! min density
  rho2,         & ! max density
  vp0,          & ! hypocenter P-wave speed
  vp1,          & ! min P-wave speed
  vp2,          & ! max P-wave speed
  vs0,          & ! hypocenter S-wave speed
  vs1,          & ! min S-wave speed
  vs2,          & ! max S-wave speed
  rexpand,      & ! grid expantion ratio
  xhypo(3),     & ! hypocenter location
  xcenter(3),   & ! mesh center
  rmax(1),      & ! maximum distance from mesh center
  viscosity(2), & ! viscosity for (1) stress & (2) hourglass corrections
  upvector(3),  & ! upward direction
  tsource,      & ! dominant period
  rsource,      & ! source radius
  moment1(3),   & ! moment source normal components
  moment2(3),   & ! moment source shear components
  vrup,         & ! nucleation rupture velocity
  rcrit,        & ! nucleation critical radius
  trelax,       & ! nucleation relaxation time
  svtol           ! slip velocity for determining rupture time

integer, dimension(3) :: &
  nn,           & ! number of global nodes, count double nodes twice
  nm,           & ! size of local 3D arrays
  np,           & ! number of processors
  ip3,          & ! processor rank
  bc1,          & ! boundary conditions for j1 k1 l1
  bc2,          & ! boundary conditions for j2 k2 l2
  nnoff,        & ! offset between local and global indices
  ihypo,        & ! hypocenter node
  n1expand,     & ! # grid expantion nodes for j1 k1 l1
  n2expand,     & ! # grid expantion nodes for j2 k2 l2
  i1node,       & ! node calculations start index
  i2node,       & ! node calculations end index
  i1cell,       & ! cell calculations start index
  i2cell,       & ! cell calculations end index
  i1pml,        & ! PML boundary
  i2pml           ! PML boundary

integer :: &
  nt,           & ! number of time steps
  it,           & ! current time step
  itcheck,      & ! interval for checkpointing
  npml,         & ! number of PML damping nodes
  faultnormal,  & ! fault normal direction
  ifn,          & ! fault normal component=abs(faultnormal)
  noper,        & ! number of zones for spatial derivative operators
  i1oper(2,3),  & ! j1 k1 l1 operator zone start index
  i2oper(2,3),  & ! j2 k2 l2 operator zone end index
  nin = 0,      & ! number of zones for input
  i1in(nz,3),   & ! j1 k1 l1 input start index
  i2in(nz,3),   & ! j1 k1 l1 input end index
  nlock = 0,    & ! number of zones for locking velocity
  ilock(nz,3),  & ! flag for locking v1 v2 v3
  i1lock(nz,3), & ! j1 k1 l1 lock zone start index
  i2lock(nz,3), & ! j2 k2 l2 lock zone end index
  nout = 0,     & ! number of zones for output
  ditout(nz),   & ! interval for writing output
  i1out(nz,3),  & ! j1 k1 l1 input zone start index
  i2out(nz,3)     ! j2 k2 l2 input zone end index

character :: &
  oper(2)         ! spatial derivative operators

character(4) :: &
  fieldin(nz),  & ! input variable
  fieldout(nz)    ! output variable

character(16) :: &
  grid,         & ! grid generation scheme
  rfunc,        & ! moment source space function
  tfunc           ! moment source time function

character(160) :: &
  str             ! string for storing file names

logical :: &
  master,       & ! master processor flag
  edge1(3),     & ! edge processor
  edge2(3),     & ! edge processor
  readfile(nz)    ! read input file

end module

