!------------------------------------------------------------------------------!
! MATMODEL - Material model setup

module matmodel_m
contains
subroutine matmodel
use globals_m
use dfnc_m
use binio_m

implicit none
integer :: iz, i, j, k, l, j1, k1, l1, j2, k2, l2

if ( ip == 0 ) print '(a)', 'Material model'

! Input
mr = 0.
s1 = 0.
s2 = 0.
doi: do i = 1, nin
ifreadfile: if ( readfile(i) ) then
  i1 = i1cell
  i2 = i2cell + 1
  select case ( inkey(i) )
  case ( 'rho' ); call bread3( 'data/rho', mr, i1, i2 )
  case ( 'vp'  ); call bread3( 'data/vp',  s1, i1, i2 )
  case ( 'vs'  ); call bread3( 'data/vs',  s2, i1, i2 )
  end select
else
  i1 = max( i1in(i,:), i1cell )
  i2 = min( i2in(i,:), i2cell + 1 )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  select case ( inkey(i) )
  case ( 'rho' ); mr(j1:j2,k1:k2,l1:l2) = inval(i)
  case ( 'vp'  ); s1(j1:j2,k1:k2,l1:l2) = inval(i)
  case ( 'vs'  ); s2(j1:j2,k1:k2,l1:l2) = inval(i)
  end select
end if ifreadfile
end do doi

! Material extremes
vpmin = minval( s1, s1 > 0. ); vpmax = maxval( s1 )
vsmin = minval( s2, s2 > 0. ); vsmax = maxval( s2 )

! Lame parameters
s2 = mr * s2 * s2
s1 = mr * ( s1 * s1 ) - 2. * s2

! Save mu at hypocenter
if ( hypop ) mu0 = s2(i0(1),i0(2),i0(3))

! Average Lame parameters onto cell centers
lam = 0.
mu = 0.
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
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

! Cell volume
s2 = 0.
do iz = 1, noper
  i1 = max( i1oper(iz,:),     i1cell )
  i2 = min( i2oper(iz,:) - 1, i2cell )
  call dfnc( s2, oper(iz), x, x, dx, 1, 1, i1, i2 )
end do
if ( ifn /=0 ) then
  i = i0(ifn)
  select case( ifn )
  case( 1 ); s2(i,:,:) = 0;
  case( 2 ); s2(:,i,:) = 0;
  case( 3 ); s2(:,:,i) = 0;
  end select
end if

! Node volume
s1 = 0.
i1 = i1node
i2 = i2node
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  s1(j,k,l) = 0.125 * &
    ( s2(j,k,l) + s2(j-1,k-1,l-1) &
    + s2(j-1,k,l) + s2(j,k-1,l-1) &
    + s2(j,k-1,l) + s2(j-1,k,l-1) &
    + s2(j,k,l-1) + s2(j-1,k-1,l) )
end forall

! Hourglass constant - FIXME off by factor of 8?
y = 6. * dx * dx * ( lam + 2. * mu )
where ( y /= 0. ) y = 4. * mu * ( lam + mu ) / y * s2

! Divide Lame parameters by cell volume
where ( s2 /= 0. ) s2 = 1. / s2
lam = lam * s2
mu = mu * s2

! Node mass ratio
mr = mr * s1
where ( mr /= 0. ) mr = 1. / mr

s1 = 0.
s2 = 0.

end subroutine
end module

