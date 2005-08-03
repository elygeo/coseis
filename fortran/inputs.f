!==============================================================================!
! INPUTS
!------------------------------------------------------------------------------!

module inputs_m

integer np(3), nt, npml, bc(6)

subroutine inputs

integer n, 

npe = (/ 1, 1, 1 /)
n = (/ 21, 21, 21, 20 /)
dx = 100.
dt = .007
nu = .25
rho0 = 2670.
vp = 6000.
vs = sqrt( vp ^ 2 * ( nu - .5 ) / ( nu - 1 ) )  ! 3464.1
grid = 'constant'
nrmdim = 2
vrup = .9 * vs
rcrit = 1000.
nclramp = 10
material(1,:)  = (/ rho0, vp, vs /)
friction(1,:)  = (/ .6, .5,   .25, 0. /)
traction(1,:)  = (/ -70e6, -120e6, 0. /)
stress(1,:)    = (/ 0., 0., 0. /)
nmat  = 1
nfric = 1
ntrac = 1
nstress = 1
nout = 0
mati(1,:)    = (/ 1, 1, 1,   -1, -1, -1/)
frici(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
traci(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
stressi(1,:) = (/ 1, 1, 1,   -1, -1, -1/)
viscosity = (/ .0 .3 /)
noise = 0.
hypocenter = 0
msrcradius = 0.
checkpoint = -1
npml = 0
bc = (/ 1, 1, 0,   1, 1, 1 /)

open( 9, file='inputs' status='old' )
do
  read( 9,'(a)', end=10 ) buff
  if ( buff .eq. ' ' ) cycle
  read( buff, * ) key
  if ( key(1:1) .eq. '#' .or. key(1:1) .eq. '!' .or. key(1:1) .eq. '%' ) cycle
  selectcase( key )
  case( 'nprocs' )
    read( buff, * ) a, npe
  case( 'n' )
    read( buff, * ) a, n
  case( 'nrmdim' )
    read( buff, * ) a, nrmdim
  case( 'hypocenter' )
    read( buff, * ) a, hypocenter
  case( 'dx' )
    read( buff, * ) a, dx
  case( 'dt' )
    read( buff, * ) a, dt
  case( 'checkpoint' )
    read( buff, * ) a, checkpoint
  case( 'out' )
    nout = nout + 1
    read( buff, * ) a, outvar(nout), outint(nout), outi(nout,:)
  case( 'material' )
    nmat = nmat + 1
    read( buff, * ) a, material(nmat,:), mati(nmat,:)
  case( 'friction' )
    nfric = nfric + 1
    read( buff, * ) a, friction(nfric,:), frici(nfric,:)
  case( 'traction' )
    ntrac = ntrac + 1
    read( buff, * ) a, traction(ntrac,:), traci(ntrac,:)
  case( 'stress' )
    nstress = nstress + 1
    read( buff, * ) a, stress(nstress,:), stressi(nstress,:)
  case( '' )
  case default
    error( 'unrecognized input type: ' // key )
  end select
end do
10 continue
close( 9 )

halo = 1
np = n(1:3)
nt = n(4)
if( nrmdim /= 0 ) np(nrmdim) = np(nrmdim) + 1
nm = ceiling( np / npe )
nm = nm + 2 * halo

allocate(      &
  x(j,k,l,3),  &
  u(j,k,l,3),  &
  v(j,k,l,3),  &
  w1(j,k,l,3), &
  w2(j,k,l,3), &
  s1(j,k,l),   &
  s2(j,k,l),   &
  rho(j,k,l),  &
  lam(j,k,l),  &
  miu(j,k,l),  &
  yc(j,k,l),   &
  yn(j,k,l)    &
)
x   = 0.
u   = 0.
v   = 0.
s1  = 0.
s2  = 0.
w1  = 0.
w2  = 0.
rho = 0.
lam = 0.
miu = 0.
yc  = 0.
yn  = 0.

!------------------------------------------------------------------------------!
! MATMODEL
matmax = material(1,1:3)
matmin = material(1,1:3)
do iz = 1, nmat
  call zoneselect( mati(iz,:), ng, nl, offset, hypocenter )
  rho0  = material(iz,1)
  vp    = material(iz,2)
  vs    = material(iz,3)
  matmax = max( matmax, material(iz,1:3) )
  matmin = min( matmin, material(iz,1:3) )
  miu0  = rho0 * vs * vs
  lam0  = rho0 * ( vp * vp - 2 * vs * vs )
  yc0   = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2
  !nu    = .5 * lam0 / ( lam0 + miu0 )
  forall( j=i1(1):i2(1)-1, k=i1(2):i2(2)-1, l=i1(3):i2(3)-1 )
    s1(j,k,l) = rho0
    lam(j,k,l) = lam0
    miu(j,k,l) = miu0
    yc(j,k,l) = yc0
  end forall
end do
courant = dt * matmax(2) * sqrt( 3 ) / dx   ! TODO: check, make general
write(*,*) 'courant: %g < 1\n', courant

do iz = 1, nout
  call zoneselect( outi(iz,:), ng, nl, offset, hypocenter )
  do i = 1, 3
    outgi1(i,nout) = i1(i)
    outgi2(i,nout) = i2(i)
  end do
end do

if ( checkpoint .eq. 0 )  checkpoint = ti2 + 1

downdim = 3
if ( nrmdim /= 0 .and. nrmdim /= downdim ) then
  crdsys = (/ 6 - downdim - nrmdim, nrmdim, downdim /)
else
  forall( i=1:3 ) crdsys(i) = mod( downdim + i - 1, 3 ) + 1
end if

mype3d = 0
core1 = 1
core2 = ng
nl = ng
offset = 0

end subroutine

function error( string )

character*(*) string
write(0,*) 'DFM error: ', string
stop

end function

