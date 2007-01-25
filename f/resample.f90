! Initial state
module m_resample
implicit none
contains

subroutine resample
use m_globals
use m_collective
use m_diffnc
use m_bc
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2

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
!y = .3 / 16. * ( lam + 2. * mu ) * dx ! like Ma & Liu, 2006

! Cell volume
s1 = 0.
call diffnc( s1, 'g', x, x, dx, 1, 1, i1cell, i2cell )
select case( ifn )
case( 1 ); j = ihypo(1); s1(j,:,:) = 0.
case( 2 ); k = ihypo(2); s1(:,k,:) = 0.
case( 3 ); l = ihypo(3); s1(:,:,l) = 0.
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
call scalarswaphalo( mr, 0, nhalo )

! Initial state
  t     =  0.
  v     =  0.
  u     =  0.
  w1    =  0.
! z1    =  0.
! z2    =  0.
  sl    =  0.
  p1    =  0.
  p2    =  0.
  p3    =  0.
  p4    =  0.
  p5    =  0.
  p6    =  0.
  g1    =  0.
  g2    =  0.
  g3    =  0.
  g4    =  0.
  g5    =  0.
  g6    =  0.
  pv    =  0.
  psv   =  0.
  trup  =  1e9
  tarr  =  0.
  efric =  0.

  w2    =  0.
  s1    =  0.
  s2    =  0.
  t1    =  0.
  t2    =  0.
  f1    =  0.
  f2    =  0.

end subroutine

end module

