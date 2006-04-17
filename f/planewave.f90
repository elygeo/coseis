! Moment source added to stress
module bodysource_m
implicit none
contains

subroutine bodysource
use globals_m
use tictoc_m
integer :: i1(3), i2(3), i, j1, k1, l1, j2, k2, l2
real :: srcft

if ( planenormal == 0. ) return

if ( master ) call toc( 'Body source' )

! Indices
i1 = i1plane
i2 = i2plane
call zone( i1, i2, nn, nnoff, ihypo, ifn )
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 0.; if ( it == 1 ) srcft = 1.
case( 'brune'  ); srcft = 1. - exp( -t / tsource ) / tsource * ( t + tsource )
case( 'sbrune' ); srcft = 1. - exp( -t / tsource ) / tsource * &
  ( t + tsource + t * t / tsource / 2. )
case default; stop 'tfunc'
end select

! Set velocity
do i = 1, 3
  v(j1:j2,k1:k2,l1:l2,i) = srcft * vbody(i)
end do

end subroutine

end module

