! Moment source added to stress
module m_momentsource
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
integer :: i, j, k, l, nsrc
real :: sumsrcfr, allsumsrcfr

if ( rsource <= 0. ) return
if ( master ) write( 0, * ) 'Moment source initialize'

! Cell volumes
call diffnc( s1, w1, 1, 1, i1cell, i2cell, oplevel, bb, x, dx1, dx2, dx3, dx )

! Hypocenter/cell radius (squared)
s2 = ( w2(:,:,:,1) - xhypo(1) ) * ( w2(:,:,:,1) - xhypo(1) ) &
   + ( w2(:,:,:,2) - xhypo(2) ) * ( w2(:,:,:,2) - xhypo(2) ) &
   + ( w2(:,:,:,3) - xhypo(3) ) * ( w2(:,:,:,3) - xhypo(3) )
call scalarsethalo( s2, 2.*rsource*rsource, i1cell, i2cell )
nsrc = count( s2 < rsource*rsource )
allocate( jj(nsrc), kk(nsrc), ll(nsrc), cellvol(nsrc), srcfr(nsrc) )

! Use points inside radius
i = 0
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
  case( 'box'  ); srcfr(i) = 1.
  case( 'tent' ); srcfr(i) = rsource - sqrt( s2(j,k,l) )
  case default
    write( 0, * ) 'invalid rfunc: ', trim( rfunc )
    stop
  end select
  if ( all( ibc1 /= 9 .or. (/ j, k, l /) >= i1node ) ) then
    sumsrcfr = sumsrcfr + srcfr(i)
  end if
end if
end do
end do
end do

! Normalize and divide by cell volume
call rreduce( allsumsrcfr, sumsrcfr, 'allsum', 0 )
if ( allsumsrcfr <= 0. ) stop 'bad source space function'
srcfr = srcfr / allsumsrcfr / cellvol

end subroutine

!------------------------------------------------------------------------------!

! Add moment source
subroutine momentsource
use m_globals
integer :: i, j, k, l, ic, nsrc
real :: srcft

if ( rsource <= 0. ) return

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 1.
case( 'brune'  ); srcft = 1. - exp( -t / tsource ) / tsource * ( t + tsource )
case( 'sbrune' ); srcft = 1. - exp( -t / tsource ) / tsource * &
  ( t + tsource + t * t / tsource / 2. )
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

end module

