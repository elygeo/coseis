! Resample material model
module m_resample
implicit none
contains

subroutine resample
use m_globals
use m_collectiveio
use m_diffnc
use m_bc
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2, 

if ( master ) write( 0, * ) 'Resample material model'

! Harmonic average Lame parameters onto cell centers
s1 = 0.
s2 = 0.
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
where( lam > 0. ) s1 = 1. / lam
where( mu  > 0. ) s2 = 1. / mu
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  lam(j,k,l) = 0.125 * &
    ( s1(j,k,l) + s1(j+1,k+1,l+1) &
    + s1(j+1,k,l) + s1(j,k+1,l+1) &
    + s1(j,k+1,l) + s1(j+1,k,l+1) &
    + s1(j,k,l+1) + s1(j+1,k+1,l) )
  mu(j,k,l) = 0.125 * &
    ( s2(j,k,l) + s2(j+1,k+1,l+1) &
    + s2(j+1,k,l) + s2(j,k+1,l+1) &
    + s2(j,k+1,l) + s2(j+1,k,l+1) &
    + s2(j,k,l+1) + s2(j+1,k+1,l) )
end forall
where( lam > 0. ) lam = 1. / lam
where( mu  > 0. ) mu  = 1. / mu

! Hourglass constant
y = 12. * ( lam + 2. * mu )
where ( y /= 0. ) y = dx * mu * ( lam + mu ) / y
! y = 12. * dx * dx * ( lam + 2. * mu )
! where ( y /= 0. ) y = s1 * mu * ( lam + mu ) / y

! Cell volume
s1 = 0.
call diffnc( s1, 'g', x, x, dx, 1, 1, i1cell, i2cell )
select case( ifn )
case( 1 ); j = ihypo(1); s1(j,:,:) = 0.; lam(j,:,:) = 0.; mu(j,:,:) = 0.
case( 2 ); k = ihypo(2); s1(:,k,:) = 0.; lam(:,k,:) = 0.; mu(:,k,:) = 0.
case( 3 ); l = ihypo(3); s1(:,:,l) = 0.; lam(:,:,l) = 0.; mu(:,:,l) = 0.
end select

! Node volume
s2 = 0.
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s2(j,k,l) = 0.125 * &
    ( s1(j,k,l) + s1(j-1,k-1,l-1) &
    + s1(j-1,k,l) + s1(j,k-1,l-1) &
    + s1(j,k-1,l) + s1(j-1,k,l-1) &
    + s1(j,k,l-1) + s1(j-1,k-1,l) )
end forall

! Divide Lame parameters by cell volume
where ( s1 /= 0. ) s1 = 1. / s1
lam = lam * s1
mu = mu * s1

! Node mass ratio
mr = mr * s2
where ( mr /= 0. ) mr = 1. / mr
call scalarbc( mr, ibc1, ibc2, nhalo )
call scalarswaphalo( mr, nhalo )

end subroutine

end module

