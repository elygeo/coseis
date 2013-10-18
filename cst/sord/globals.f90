! global variables
module globals
implicit none

! input parameters, see parameters.yaml for documentation
integer :: &
    bc1(3), bc2(3), debug, faultopening, i1pml(3), i2pml(3), itio, itstats, mpin, &
    mpout, n1expand(3), n2expand(3), npml, nproc3(3), nsource, nthread, ppml, &
    shape_(4)
real :: &
    affine(9), delta(4), gam_max, gam_min, gridnoise, hourglass(2), hypocenter(3), &
    rcrit, rexpand, rho_max, rho_min, slipvector(3), svtol, tm0, trelax, vdamp, &
    vp_max, vp_min, vpml, vrup, vs_max, vs_min
character(16) :: source
character(4) :: diffop
character(2) :: faultnormal

! miscellaneous parameters
real :: &
    dt,             & ! time step length
    dx(3),          & ! spatial step lengths
    tm = 0.0          ! time
integer :: &
    it = 0,         & ! current time step
    nt,             & ! number of time steps
    ifn,            & ! fault normal component
    irup,           & ! flag for rupture on this process
    ip                ! process rank
integer, dimension(3) :: &
    nn,             & ! shape of global mesh
    nm,             & ! shape of local 3D arrays
    nl3,            & ! number of mesh nodes per process
    nhalo,          & ! number of ghost nodes
    ip3,            & ! 3d process rank
    ip3hypo,        & ! hypocenter 3d rank
    i1bc, i2bc,     & ! model boundary
    i1core, i2core, & ! core region
    i1node, i2node, & ! node region
    i1cell, i2cell, & ! cell region
    nnoff             ! offset between local and global indices
logical :: &
    sync,           & ! synchronize processes
    master            ! master process flag

! 1d arrays
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

