!------------------------------------------------------------------------------!
! GLOBALS

module globals_m

implicit none

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
real, dimension(:) :: &
  dn1,          & ! pml node damping -2*d     / (2+d*dt)
  dn2,          & ! pml node damping  2       / (2+d*dt)
  dc1,          & ! pml cell damping (2-d*dt) / (2+d*dt)
  dc2             ! pml cell damping  2*dt    / (2+d*dt)

! Fault vectors
real, allocatable, dimension(:,:,:,:) :: &
  nrm,          & ! fault surface normals
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
  r,            & ! radius to hypocenter
  vs,           & ! **slip velocity mangitude
  us,           & ! **slip path length
  trup,         & ! **rupture time
  tn,           & ! temporary storage
  ts,           & ! temporary storage
  f1,           & ! temporary storage
  f2              ! temporary storage

real :: &
  t,            & ! **time
  dt,           & ! time step
  dx,           & ! spatial step
  vpmin,        & ! min P-wave speed
  vpmax,        & ! max P-wave speed
  vsmin,        & ! min S-wave speed
  vsmax,        & ! max S-wave speed
  x0(3),        & ! hypocenter location
  viscosity(2), & ! viscocity for (1) stress & (2) hourglass corrections
  moment(6),    & ! moment source
  tsource,      & ! dominant period
  rsource,      & ! source radius
  upvector(3)   & ! vecotor for determining strike and dip
  mu0,          & ! mu at hypocenter
  vrup,         & ! nucleation rupture velocity
  rcrit,        & ! nucleation critical radius
  truptol,      & ! min slip velocity to declare rupture
  amax,         & ! max acceleration
  vmax,         & ! max velocity
  umax,         & ! max displacement
  wmax,         & ! max stress (Frobenius norm)
  vsmax,        & ! max slip velocity
  usmax,        & ! max slip

integer, dimension(3) :: &
  nn,           & ! number of global nodes
  np,           & ! number of processors
  nm,           & ! size of local 3D arrays
  nf,           & ! size of local fault arrays
  noff,         & ! offset between local and global indices
  i0,           & ! hypocenter node
  iamax,        & ! index of max acceleration
  ivmax,        & ! index of max velocity
  iumax,        & ! index of max displacement
  iwmax,        & ! index of max stress
  ivsmax,       & ! index of max slip velocity
  iusmax,       & ! index of max slip
  i1node,       & ! node calculations start index
  i2node,       & ! node calculations end index
  i1nodepml,    & ! excluding PML region
  i2nodepml,    & ! excluding PML region
  i1cell,       & ! cell calculations start index
  i2cell,       & ! cell calculations end index
  i1cellpml,    & ! excluding PML region
  i2cellpml       ! excluding PML region

integer :: &
  ip,           & ! processor index
  nt,           & ! number of time steps
  it,           & ! current time step
  itcheck,      & ! interval for checkpointing
  npml,         & ! number of PML damping nodes
  bc(6),        & ! boundary conditions for j1 k1 l1 j2 k2 l2
  ifn,          & ! fault normal direction
  idown,        & ! downward direction
  wt(5),        & ! wall clock timing array
  noper,        & ! number of zones for spatial derivative operators
  i1oper(2,3),  & ! j1 k1 l1 operator zone start index
  i2oper(2,3),  & ! j2 k2 l2 operator zone end index
  nin,          & ! number of zones for input
  i1in(nz,3),   & ! j1 k1 l1 input start index
  i2in(nz,3),   & ! j1 k1 l1 input end index
  nlock,        & ! number of zones for locking velocity
  i1lock(nz,3), & ! j1 k1 l1 lock zone start index
  i2lock(nz,3), & ! j2 k2 l2 lock zone end index
  lock(nz,3),   & ! flag for locking v1 v2 v3
  nout,         & ! number of zones for output
  i1out(nz,3),  & ! j1 k1 l1 input zone start index
  i2out(nz,3),  & ! j2 k2 l2 input zone end index
  itout(nz)       ! interval for writing output

character(2) :: &
  oper            ! spatial derivative operators

character(8) :: &
  inkey(nz),    & ! input variable
  outkey(nz)      ! output variable

character(16) :: &
  grid,         & ! grid generation scheme
  sourcetimefn    ! source fime function

logical :: &
  readfile(nz), & ! read input file
  hypop           ! hypocenter is on this processor

end module

