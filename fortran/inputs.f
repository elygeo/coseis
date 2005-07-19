!==============================================================================!
! INPUTS
!------------------------------------------------------------------------------!
module inputs
  integer np(3), nt, npml, bc(6)
subroutine inputs

integer n

npe = (/ 1 1 1 /)
open( 9, file='inputs' status='old' )
do
  read( 9,'(a)', end=10 ) buff
  read( buff, * ) key
  selectcase( key )
  case( 'parallel' )
    read( buff, * ) a, npe
  case( 'n' )
    read( buff, * ) a, n
  case( 'out' )
    nout = nout + 1
  case( 'nrmdim' )
  end select
end do
10 continue
close( 9 )

halo = 1
np = n(1:3)
nt = n(4)
if( nrmdim /= 0 ) np(nrmdim) = np(nrmdim) + 1
nl = ceiling( np / npe )
n = nl + 2 * halo
j = nl(1)
k = nl(2)
l = nl(3)
allocate( x(j,k,l,3), u(j,k,l,3), v(j,k,l,3), w1(j,k,l,3), w2(j,k,l,3), &
          s1(j,k,l), s2(j,k,l), &
          rho(j,k,l), lam(j,k,l), miu(j,k,l), yc(j,k,l), yn(j,k,l) )
if( nrmdim /= 0 ) then
  n = nl + 2 * halo
  j = nl(1)
  k = nl(2)
  l = nl(3)
  allocate( fs(j,k,l), fd(j,k,l), dc(j,k,l), cohes(j,k,l), &
            s0(j,k,l,6), t0nsd(j,k,l,3) )
  fs(:,:,:) = 0
  fd(:,:,:) = 0
  dc(:,:,:) = 0
  cohes(:,:,:) = 1e9
  s0(:,:,:,6) = 0
  t0nsd(:,:,:,3) = 0
end if
  

open( 9, file='inputs' status='old' )
do
  read( 9,'(a)', end=10 ) buff
  if ( buff .eq. ' ' ) cycle
  read( buff, * ) key
  if ( key(1:1) .eq. '#' .or. key(1:1) .eq. '!' .or. key(1:1) .eq. '%' ) cycle
 
  selectcase( key )
  case( 'parallel' )
  case( 'n' )
  case( 'dx' )
    read( buff, * ) a, dx
  case( 'dt' )
    read( buff, * ) a, dt
  case( 'material' )
    read( buff, * ) a, rho0, vp, vs, beta0, i1, i2
    call zoneselect( i1, i2, ng, nl, offset, hypocenter )
    miu0 = rho0 * vs * vs
    lam0 = rho0 * ( vp * vp - 2 * vs * vs )
    yc0  = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2
    forall( j=i1(1):i2(1)-1, k=i1(2):i2(2)-1, l=i1(3):i2(3)-1 )
      s1(j,k,l) = rho0
      lam(j,k,l) = lam0
      miu(j,k,l) = miu0
      yc(j,k,l)  = yc0
    end forall
  case( 'hypocenter' )
    read( buff, * ) a, hypocenter
  case( 'friction' )
    read( buff, * ) a, smin0, smax0, d00, t00, cohes0, i1, i2
    call zoneselect( i1, i2, ng, nl, offset, hypocenter )
    forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
      smin(j,k,l)  = smin0
      smax(j,k,l)  = smax0
      t0(j,k,l,1)  = t00(1)
      t0(j,k,l,2)  = t00(2)
      t0(j,k,l,3)  = t00(3)
      d0(j,k,l)    = d00
      cohes(j,k,l) = cohes0
    end forall
  case( 'out' )
    nout = nout + 1
    read( buff, * ) a, outvar(nout), outint(nout), i1, i2
    call zoneselect( i1, i2, ng, nl, offset, hypocenter )
    do i = 1, 3
      outgi1(i,nout) = i1(i)
      outgi2(i,nout) = i2(i)
    end do
  case( 'checkpoint' )
    read( buff, * ) a, checkpoint
  case default
    error( 'unrecognized input type: ' // key )
  end select
end do
20 continue

maxvel = max( maxvel, vp0(1) )
if ( checkpoint .eq. 0 )  checkpoint = ti2 + 1
do i = 1, 3
  mype3d(i) = 0
  core1(i) = 1
  core2(i) = ng(i)
  nl(i) = ng(i)
  offset(i) = 0
end do

if ( nfault .gt. m3s ) error( 'nfault too big' )
if ( min( h(1), h(2), h(3) ) / maxvel .le. h(4) ) error( 'courant condition' )
do i = 1, nfault
  if ( kind0(i) .lt. 0 .or. kind0(i) .gt. 2 ) error( 'kind must be 0, 1 or 2' )
end do

return
end

function error( string )
character*(*) string
write(0,*) 'DFM error: ', string
stop
end

