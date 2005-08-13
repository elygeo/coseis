!------------------------------------------------------------------------------!
! SETUP
subroutine setup

use globals
character*256 buff, key, a

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
material(1,:) = (/ rho0, vp, vs /)
friction(1,:) = (/ .6, .5,   .25, 0. /)
traction(1,:) = (/ -70e6, -120e6, 0. /)
stress(1,:)   = (/ 0., 0., 0. /)
nmat  = 1
nfric = 1
ntrac = 1
nstress = 1
nout = 0
mati(1,:)    = (/ 1, 1, 1,   -1, -1, -1/)
frici(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
traci(1,:)   = (/ 1, 1, 1,   -1, -1, -1/)
stressi(1,:) = (/ 1, 1, 1,   -1, -1, -1/)
viscosity = (/ .0, .3 /)
noise = 0.
hypocenter = (/ 0, 0, 0 /)
msrcradius = 0.
checkpoint = -1
npml = 0
bc = (/ 1, 1, 0,   1, 1, 1 /)
open( 9, file='inputs' status='old' )
loop: do
  read( 9,'(a)', iostat=iostat ) buff
  if ( iostat /= 0 ) exit loop
  if ( buff == ' ' ) cycle loop
  read( buff, * ) key
  if ( key(1:1) == '#' .or. key(1:1) == '!' .or. key(1:1) == '%' ) cycle loop
  selectcase( key )
  case( '' )
  case( 'nprocs' );     read( buff, * ) a, npe
  case( 'n' );          read( buff, * ) a, n
  case( 'nrmdim' );     read( buff, * ) a, nrmdim
  case( 'hypocenter' ); read( buff, * ) a, hypocenter
  case( 'dx' );         read( buff, * ) a, dx
  case( 'dt' );         read( buff, * ) a, dt
  case( 'checkpoint' ); read( buff, * ) a, checkpoint
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
  case default; stop( 'unrecognized input type: ' // key )
  end select
end do loop
close( 9 )

if ( count( hypocenter == 0 ) /= 0 )
halo = 1
npg = n(1:3)
nt = n(4)
if( nrmdim /= 0 ) npg(nrmdim) = npg(nrmdim) + 1
np = ceiling( npg / npe )
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

if ( ipe == 0 ) print '(a)', 'Grid generation'
forall( i=2:nm(1)-1 ) x(i,:,:,1) = i - 2
forall( i=2:nm(2)-1 ) x(:,i,:,2) = i - 2
forall( i=2:nm(3)-1 ) x(:,:,i,3) = i - 2
x(1,:,:,:) = x(2,:,:,:)
x(:,1,:,:) = x(:,2,:,:)
x(:,:,1,:) = x(:,:,2,:)
x(nm(1),:,:,:) = x(nm(1)-1,:,:,:)
x(:,nm(2),:,:) = x(:,nm(2)-1,:,:)
x(:,:,nm(3),:) = x(:,:,nm(3)-1,:)
i = hypocenter(nrmdim) + 1
selectcase( nrmdim )
case( 1 ); x(i:,:,:,1) = x(i:,:,:,1) - 1
case( 2 ); x(:,i:,:,2) = x(:,i:,:,2) - 1
case( 3 ); x(:,:,i:,3) = x(:,:,i:,3) - 1
end select
l1 = x(nm(1),1,1,1)
l2 = x(1,nm(2),1,2)
l3 = x(1,1,nm(3),3)
nop = 1
selectcase( grid )
case 'constant'
  op(1) = 'h'
case 'stretch'
  op(1) = 'r'
  x(:,:,:,3) = 2 * x(:,:,:,3)
case 'slant'
  op(1) = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ^ 2. + ( 1. - sin( theta ) ) ^ 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case default; stop 'Error: grid'
end select
x = x * dx

if ( ipe == 0 ) print '(a)', 'Material Model'
matmax = material(1,1:3)
matmin = material(1,1:3)
do iz = 1, nmat
  call zoneselect( mati(iz,:), ng, nl, offset, hypocenter )
  rho0 = material(iz,1)
  vp   = material(iz,2)
  vs   = material(iz,3)
  matmax = max( matmax, material(iz,1:3) )
  matmin = min( matmin, material(iz,1:3) )
  miu0 = rho0 * vs * vs
  lam0 = rho0 * ( vp * vp - 2 * vs * vs )
  yc0  = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2
  !nu  = .5 * lam0 / ( lam0 + miu0 )
  forall( j=i1(1):i2(1)-1, k=i1(2):i2(2)-1, l=i1(3):i2(3)-1 )
    s1(j,k,l) = rho0
    lam(j,k,l) = lam0
    miu(j,k,l) = miu0
    yc(j,k,l) = yc0
  end forall
end do
courant = dt * matmax(2) * sqrt( 3 ) / dx   ! TODO: check, make general
if ( ipe == 0 ) print *, 'courant: 1 > ', courant

print *, 'Initialize Output'
do iz = 1, nout
  call zoneselect( outi(iz,:), ng, nl, offset, hypocenter )
  do i = 1, 3
    outgi1(i,nout) = i1(i)
    outgi2(i,nout) = i2(i)
  end do
end do
if ( checkpoint .eq. 0 )  checkpoint = nt + 1

downdim = 3
if ( nrmdim /= 0 .and. nrmdim /= downdim ) then
  crdsys = (/ 6 - downdim - nrmdim, nrmdim, downdim /)
else
  do i = 1, 3; crdsys(i) = mod( downdim + i - 1, 3 ) + 1; end do
end if

end subroutine setup

