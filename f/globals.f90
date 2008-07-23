! Global variables
module m_globals
implicit none

real, parameter :: &
  pi = 3.14159

integer, parameter :: &
  nz = 100         ! max number of input and output zones, also see mpi.f90

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
  pv,            & ! peak velocity
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

real :: &
  tm,            & ! time
  dt,            & ! time step
  dx,            & ! spatial step
  rho_,          & ! ave density
  rho1,          & ! min density
  rho2,          & ! max density
  vp_,           & ! ave P-wave speed
  vp1,           & ! min P-wave speed
  vp2,           & ! max P-wave speed
  vs_,           & ! ave S-wave speed
  vs1,           & ! min S-wave speed
  vs2,           & ! max S-wave speed
  gam_,          & ! ave viscosity
  gam1,          & ! min viscosity
  gam2,          & ! max viscosity
  hourglass(2),  & ! hourglass stiffness (1) and viscosity (2)
  vdamp,         & ! shear wave velocity dependent damping
  rexpand,       & ! grid expansion ratio
  affine(9),     & ! grid transformation
  gridnoise,     & ! random noise in grid
  inval(nz),     & ! input value
  x1in(nz,3),    & ! input cube - near corner
  x2in(nz,3),    & ! input cube - far corner 
  xout(nz,3),    & ! timeseries output location
  xhypo(3),      & ! hypocenter location
  slipvector(3)    ! slip direction for finding traction vectors

real :: &
  tsource,       & ! dominant period
  rsource,       & ! source radius
  moment1(3),    & ! moment source normal components
  moment2(3),    & ! moment source shear components
  vrup,          & ! nucleation rupture velocity
  rcrit,         & ! nucleation critical radius
  trelax,        & ! nucleation relaxation time
  efric,         & ! friction + fracture energy
  estrain,       & ! strain energy
  moment,        & ! strain energy
  mu0,           & ! shear modulus at hypocenter
  mus0,          & ! static friction at hypocenter
  mud0,          & ! dynamic friction at hypocenter
  dc0,           & ! dc at hypocenter
  tn0,           & ! normal traction at hypocenter
  ts0,           & ! shear traction at hypocenter
  ess,           & ! strength parameter
  lc,            & ! breakdown width
  rctest,        & ! rcrit needed for spontaneous rupture
  svtol            ! slip velocity for determining rupture time

integer, dimension(3) :: &
  nn,            & ! number of global nodes, count double nodes twice
  nm,            & ! size of local 3D arrays
  nhalo,         & ! number of ghost nodes
  np,            & ! number of processes
  ip3,           & ! 3D process rank
  ip3root,       & ! 3D master process rank
  bc1,           & ! boundary conditions - near side
  bc2,           & ! boundary conditions - far side
  i1bc,          & ! model boundary
  i2bc,          & ! model boundary
  nnoff,         & ! offset between local and global indices
  ihypo,         & ! hypocenter node
  n1expand,      & ! # grid expansion nodes - near side
  n2expand,      & ! # grid expansion nodes - far side
  i1source,      & ! finite source start index
  i2source,      & ! finite source end index
  i1core,        & ! core region start index
  i2core,        & ! core region end index
  i1node,        & ! node calculations start index
  i2node,        & ! node calculations end index
  i1cell,        & ! cell calculations start index
  i2cell,        & ! cell calculations end index
  i1pml,         & ! PML boundary
  i2pml            ! PML boundary

integer :: &
  ip,            & ! process rank
  np0,           & ! number of processes available
  nt,            & ! number of time steps
  it,            & ! current time step
  itstats,       & ! interval for calculating statistics
  itio,          & ! interval for writing i/o buffers
  itcheck,       & ! interval for checkpointing, must be a multiple of itio
  itstop,        & ! stop time, for simulating a killed job
  debug,         & ! debugging flag
  npml,          & ! number of PML damping nodes
  fixhypo,       & ! fix hypocenter to 0=none, 1,2=ihypo node, cell, -1,-2=xhypo node, cell
  faultopening,  & ! flag to allow fault opening
  faultnormal,   & ! fault normal direction
  ifn              ! fault normal component=abs(faultnormal)

integer :: &
  oplevel,       & ! 1=constant, 2=rectangular, 3=parallelepiped, 4=one-point quadrature, 5=exact
  nin = 2,       & ! number of zones for input, hold two spots
  i1in(nz,3),    & ! j1 k1 l1 input start index
  i2in(nz,3),    & ! j1 k1 l1 input end index
  nout = 0,      & ! number of zones for output
  ditout(nz),    & ! interval for writing output
  i1out(nz,4),   & ! j1 k1 l1 output zone start index
  i2out(nz,4),   & ! j2 k2 l2 output zone end index
  i3out(nz,3),   & ! j1 k1 l1 local output zone start index
  i4out(nz,3),   & ! j2 k2 l2 local output zone end index
  mpin,          & ! input, 0=separate files, 1=MPI-IO
  mpout,         & ! output, 0=separate files, 1=MPI-IO
  ifile(nz),     & ! file output flag
  ibuff(nz)        ! buffered i/o flag

character :: &
  intype(nz),    & ! input type: z=zone, c=cube, r=read
  outtype(nz)      ! output type: z=zone, x=location

character(4) :: &
  fieldin(nz),   & ! input variable
  fieldout(nz)     ! output variable

character(16) :: &
  rfunc,         & ! moment source space function
  tfunc            ! moment source time function

character(256) :: &
  str              ! string for storing file names

logical :: &
  sync,          & ! synchronize processes
  master           ! master process flag

! Preparation for new i/o scheme. Not in use yet.
type t_io          ! output structure
  character(4) :: &
    field          ! variable name
  integer :: &
    di(4),       & ! j,k,l,t decimation interval
    i1(4),       & ! j,k,l,t start index
    i2(4),       & ! j,k,l,t end index
    i3(3),       & ! j,k,l local start index
    i4(3),       & ! j,k,l local end index
    nbuff          ! number of time steps to buffer
  real, pointer :: &
    ptr(:,:,:)     ! pointer to data
  real, allocatable :: &
    buff(:,:,:,:)  ! hold buffer
end type

type( t_io ) :: &
  ins(nz),       & ! input descriptions
  outs(nz)         ! output descriptions

end module

