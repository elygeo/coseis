! Moment source added to stress
module momentsource_m
use globals_m
use diffnc_m
use collective_m
contains
subroutine momentsource

implicit none
real, save, allocatable :: srcfr(:), cellvol(:)
integer, save, allocatable :: jj(:), kk(:), ll(:)
logical, save :: init = .true.
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nsrc, ic
real :: srcft, sumsrcfr

if ( rsource <= 0. ) return

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Moment source'
  close( 9 )
end if

ifinit: if ( init ) then !-----------------------------------------------------!

init = .false.

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
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  w1(j,k,l,:) = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
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
case default; stop 'rfunc'
end select

! Normalize and divide by cell volume
cellvol = pack( s1, s2 <= rsource )
sumsrcfr = sum( srcfr )
call psum( sumsrcfr )
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

print *, 'srcfr'
print *, srcfr

return

end if ifinit !----------------------------------------------------------------!

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 1.
case( 'brune'  ); srcft = 1. - exp( -t / tsource ) / tsource * ( t + tsource )
case( 'sbrune' ); srcft = 1. - exp( -t / tsource ) / tsource * &
  ( t + tsource + t * t / tsource / 2. )
case default; stop 'tfunc'
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

