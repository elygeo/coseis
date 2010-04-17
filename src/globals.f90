! global variables
module m_globals
implicit none

! input parameters, see parameters.py for documentation
integer, dimension(3) :: nproc3, bc1, bc2, n1expand, n2expand
integer :: shape_(4), itstats, itio, itcheck, itstop, npml, ppml, oplevel, mpin, &
    mpout, debug, faultopening, irup, faultnormal, nsource
real :: delta(4), tm0, rho1, rho2, vp1, vp2, vs1, vs2, gam1, gam2, hourglass(2), &
    vdamp, rexpand, affine(9), gridnoise, ihypo(3), vpml, slipvector(3)
real :: period, source1(3), source2(3), vrup, rcrit, trelax, svtol !, tmnucl, delts
character(16) :: source, timefunction

! miscellaneous parameters
real, parameter :: pi = 3.14159265
real :: &
    mptimer,        & ! MPI timing
    iotimer,        & ! i/o timing
    dt,             & ! time step length
    dx(3),          & ! spatial step lengths
    tm                ! time
integer :: &
    nt,             & ! number of time steps
    it,             & ! current time step
    ifn,            & ! fault normal component=abs(faultnormal)
    ip,             & ! process rank
    ipid,           & ! processor Id
    np0               ! number of processes available
integer, dimension(3) :: &
    nn,             & ! shape of global mesh
    nm,             & ! shape of local 3D arrays
    nl3,            & ! number of mesh nodes per process
    nhalo,          & ! number of ghost nodes
    ip3,            & ! 3d process rank
    ip3root,        & ! 3d root process rank
    ip2root,        & ! 2d root process rank
    i1bc, i2bc,     & ! model boundary
    i1pml, i2pml,   & ! pml boundary
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

! 1d dynamic arrays
real, allocatable, dimension(:) :: &
    dx1, dx2, dx3,  & ! x, y, z rectangular element size
    dn1,            & ! pml node damping -2*d     / (2+d*dt)
    dn2,            & ! pml node damping  2       / (2+d*dt)
    dc1,            & ! pml cell damping (2-d*dt) / (2+d*dt)
    dc2               ! pml cell damping  2*dt    / (2+d*dt)

! pml state
real, allocatable, dimension(:,:,:,:) :: &
    n1, n2, n3,     & ! surface normal near boundary
    n4, n5, n6,     & ! surface normal far boundary
    p1, p2, p3,     & ! pml momentum near side
    p4, p5, p6,     & ! pml momentum far side
    g1, g2, g3,     & ! pml gradient near side
    g4, g5, g6        ! pml gradient far side

! b matrix
real, allocatable, dimension(:,:,:,:,:) :: bb

! volume fields
real, allocatable, target, dimension(:,:,:) :: &
    vc,             & ! cell volume
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

! fault surface fields
real, allocatable, target, dimension(:,:,:) :: &
    !f0,             & ! [ZS] steady state friction at V_0
    !fw,             & ! [ZS] fully weakened fiction
    !v0,             & ! [ZS] reference slip velocity
    !vw,             & ! [ZS] weakening slip velocity
    !ll,             & ! [ZS] state evolution distance
    !af,             & ! [ZS] direct effect parameter
    !bf,             & ! [ZS] evolution effect parameter
    !psi,            & ! [ZS] state variable
    !svtrl, svold,   & ! [ZS] trial and old slip velocities
    !sv0,            & ! [ZS] initial tiny slip velocity
    !f4, f4, f5,     & ! [ZS] temporary storage
    !fun, dfun, delf, & ! [ZS] Newton's method vars
    mus, mud,       & ! coefs of static and dynamic friction
    dc,             & ! slip weakening distance
    co,             & ! cohesion
    area,           & ! fault element area
    rhypo,          & ! radius to hypocenter
    lamf, muf,      & ! moduli at the fault nodes
    sl,             & ! slip path length
    psv,            & ! peak slip velocity
    trup,           & ! rupture time
    tarr,           & ! arrest time
    tn, ts, f1, f2    ! temporary storage
real, allocatable, target, dimension(:,:,:,:) :: &
    !tp, ts0,        & ! [ZS] stress perturbation for nucleation
    nhat,           & ! fault surface normals
    t0,             & ! initial traction
    t1, t2, t3        ! temporary storage

end module

