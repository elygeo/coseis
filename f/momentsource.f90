! Moment source added to stress
module m_momentsource
use m_globals
implicit none
real, private, allocatable :: srcfr(:)
integer, private, allocatable :: jj(:), kk(:), ll(:)
contains

! Moment source init
subroutine momentsource_init
use m_diffnc
use m_collective
real, allocatable :: cellvol(:)
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nsrc
real :: sumsrcfr

if ( rsource <= 0. ) return
if ( master ) print *, 'Moment source initialize'

! Indices
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Cell volumes
s1 = 0.
call diffnc( s1, 'g', x, x, dx, 1, 1, i1, i2 )

! Cell center locations
w1 = 2. * rsource
forall( j=j1:j2, k=k1:k2, l=l1:l2, i=1:3 )
  w1(j,k,l,i) = 0.125 * &
    ( x(j,k,l,i) + x(j+1,k+1,l+1,i) &
    + x(j+1,k,l,i) + x(j,k+1,l+1,i) &
    + x(j,k+1,l,i) + x(j+1,k,l+1,i) &
    + x(j,k,l+1,i) + x(j+1,k+1,l,i) );
end forall

! Find radius to cell from source location
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
end do
s2 = sqrt( sum( w1 * w1, 4 ) )
nsrc = count( s2 <= rsource )
allocate( srcfr(nsrc), cellvol(nsrc), jj(nsrc), kk(nsrc), ll(nsrc) )

! Spatial weighting
select case( rfunc )
case( 'box'  ); srcfr = 1.
case( 'tent' ); srcfr = pack( s2, s2 <= rsource )
case default
  print *, 'invalid rfunc: ', trim( rfunc )
  stop
end select

! Normalize and divide by cell volume
cellvol = pack( s1, s2 <= rsource )
call psum( sumsrcfr, sum( srcfr ), 0 )
srcfr = srcfr / sumsrcfr / cellvol

! Index map
i = 0
do l = l1, l2
do k = k1, k2
do j = j1, j2
if ( s2(j,k,l) <= rsource ) then
  i = i + 1
  jj(i) = j
  kk(i) = k
  ll(i) = l
end if
end do
end do
end do

w1 = 0.
s1 = 0.
s2 = 0.

end subroutine

!------------------------------------------------------------------------------!
! Add moment source
subroutine momentsource
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
  print *, 'invalid tfunc: ', trim( tfunc )
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

