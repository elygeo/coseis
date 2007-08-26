! Moment source and plane wave source
module m_source
implicit none
real, private, allocatable :: srcfr(:)
integer, private, allocatable :: jj(:), kk(:), ll(:)
contains

! Moment source init
subroutine momentsource_init
use m_globals
use m_diffnc
use m_collective
use m_util
real, allocatable :: cellvol(:)
integer :: i1(3), i2(3), i, j, k, l, nsrc
real :: sumsrcfr, allsumsrcfr

if ( rsource <= 0. ) return
if ( master ) write( 0, * ) 'Moment source initialize'

! Cell volumes
i1 = i1bc
i2 = i2bc - 1
call diffnc( s1, w1, 1, 1, i1cell, i2cell, oplevel, bb, xx, dx1, dx2, dx3, dx )
call scalarsethalo( s1, 0., i1, i2 )

! Hypocenter/cell radius (squared)
call radius( s2, w2, xhypo, i1cell, i2cell )
call scalarsethalo( s2, huge(sumsrcfr), i1cell, i2cell )
nsrc = count( s2 < rsource*rsource )
allocate( jj(nsrc), kk(nsrc), ll(nsrc), cellvol(nsrc), srcfr(nsrc) )

! Use points inside radius
i = 0
srcfr = 0.
sumsrcfr = 0.
do l = i1cell(3), i2cell(3)
do k = i1cell(2), i2cell(2)
do j = i1cell(1), i2cell(1)
if ( s2(j,k,l) < rsource*rsource ) then
  i = i + 1
  jj(i) = j
  kk(i) = k
  ll(i) = l
  cellvol(i) = s1(j,k,l)
  select case( rfunc )
  case( 'point' )
  case( 'box'  ); srcfr(i) = 1.
  case( 'tent' ); srcfr(i) = rsource - sqrt( s2(j,k,l) )
  case default
    write( 0, * ) 'invalid rfunc: ', trim( rfunc )
    stop
  end select
  if ( all( (/ j, k, l /) >= i1core .and. (/ j, k, l /) <= i2core ) ) then
    sumsrcfr = sumsrcfr + srcfr(i)
  end if
end if
end do
end do
end do
call scalarsethalo( s2, 0., i1cell, i2cell )

! Normalize and divide by cell volume
if ( rfunc == 'point' ) then
  if ( nsrc > 8 ) stop 'rsource too large for point source'
  srcfr = ( .5 * dx / rsource ) ** 3
else
  call rreduce( allsumsrcfr, sumsrcfr, 'allsum', 0 )
  if ( allsumsrcfr <= 0. ) stop 'bad source space function'
  srcfr = srcfr / allsumsrcfr
end if
where ( cellvol > 0. ) srcfr = srcfr / cellvol

end subroutine

!------------------------------------------------------------------------------!

! Add moment source
subroutine momentsource
use m_globals
integer :: i, j, k, l, ic, nsrc
real :: srcft = 0.

if ( rsource <= 0. ) return
if ( master .and. debug == 2 ) write( 0, * ) 'Moment source'

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 1.
case( 'ricker' ); srcft = ( 1 - 2. * ( pi * tm / tsource ) ** 2. ) * &
  exp( -( pi * tm / tsource ) ** 2. )
case( 'brune'  ); srcft = 1. - exp( -tm / tsource ) / tsource * ( tm + tsource )
case( 'sbrune' ); srcft = 1. - exp( -tm / tsource ) / tsource * &
  ( tm + tsource + tm * tm / tsource / 2. )
case default
  write( 0, * ) 'invalid tfunc: ', trim( tfunc )
  stop
end select

! Add to stress variables
nsrc = size( srcfr )
do ic = 1, 3
do i = 1, nsrc
  j = jj(i)
  k = kk(i)
  l = ll(i)
  w1(j,k,l,ic) = w1(j,k,l,ic) - srcft * srcfr(i) * moment1(ic)
  w2(j,k,l,ic) = w2(j,k,l,ic) - srcft * srcfr(i) * moment2(ic)
end do
end do

end subroutine

!------------------------------------------------------------------------------!

! Add planewave
subroutine planewave
use m_globals
integer :: ic
real :: srcft = 0.

if ( wavenormal <= 0 ) return
if ( master .and. debug == 2 ) write( 0, * ) 'Plane wave source'

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 1.
case( 'ricker' ); srcft = ( 1 - 2. * ( pi * tm / tsource ) ** 2. ) * &
  exp( -( pi * tm / tsource ) ** 2. )
case( 'brune'  ); srcft = 1. - exp( -tm / tsource ) / tsource * ( tm + tsource )
case( 'sbrune' ); srcft = 1. - exp( -tm / tsource ) / tsource * &
  ( tm + tsource + tm * tm / tsource / 2. )
case default
  write( 0, * ) 'invalid tfunc: ', trim( tfunc )
  stop
end select

! Set displacement
do ic = 1, 3
select case( wavenormal )
case( 1 ); uu(ihypo(1),:,:,ic) = uu(ihypo(1),:,:,ic) + srcft * moment1(ic)
case( 2 ); uu(:,ihypo(2),:,ic) = uu(:,ihypo(2),:,ic) + srcft * moment1(ic)
case( 3 ); uu(:,:,ihypo(3),ic) = uu(:,:,ihypo(3),ic) + srcft * moment1(ic)
case default
  write( 0, * ) 'invalid wavenormal: ', wavenormal
  stop
end select
end do

end subroutine

end module

