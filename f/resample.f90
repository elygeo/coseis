! Initial state
module m_resample
implicit none
contains

subroutine resample
use m_globals
use m_collective
use m_diffnc
use m_bc
use m_util
integer :: i1(3), i2(3), j, k, l, j1, k1, l1, j2, k2, l2

if ( master ) write( 0, * ) 'Resample material model'

! Cell volume
call diffnc( s1, 'g', x, x, dx, 1, 1, i1cell, i2cell )
select case( ifn )
case( 1 ); j = ihypo(1); s1(j,:,:) = 0.
case( 2 ); k = ihypo(2); s1(:,k,:) = 0.
case( 3 ); l = ihypo(3); s1(:,:,l) = 0.
end select
call sethalo( s1, 0., i1cell, i2cell )

! Mass ratio, SOM style
!call scalaraverage( s2, mr, i1node, i2node, -1 )
!mr = s2
!call scalaraverage( s2, s1, i1node, i2node, -1 )
!mr = mr * s2
!where ( mr /= 0. ) mr = 1. / mr
!call scalarbc( mr, ibc1, ibc2, nhalo, 0 )
!call scalarswaphalo( mr, nhalo )

! Mass ratio, FEM style
s2 = mr * s1
call scalaraverage( mr, s2, i1node, i2node, -1 )
where ( mr /= 0. ) mr = 1. / mr
call scalarbc( mr, ibc1, ibc2, nhalo, 0 )
call scalarswaphalo( mr, nhalo )

! Viscosity
s2 = gam * dt
call scalaraverage( gam, s2, i1node, i2node, -1 )
call scalarbc( gam, ibc1, ibc2, nhalo, 0 )
call scalarswaphalo( gam, nhalo )

! Moduli
where ( s1 /= 0. ) s1 = 1. / s1
lam = lam * s1
mu = mu * s1

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

