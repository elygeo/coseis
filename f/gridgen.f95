!------------------------------------------------------------------------------!
! GRIDGEN - Grid generation

module gridgen_m
contains
subroutine gridgen
use globals_m
use binio_m
use optimize_m

implicit none
real :: theta, scl, width(3)
real, parameter :: pi = 3.14159

if ( ip == 0 ) print '(a)', 'Grid generation'

idown = 3
width = ( nn - 1 ) * dx
i1 = i1cell
i2 = i2cell + 1
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

x = 0.
if ( griddir /= '' ) then
  call bread4( griddir, 'x1', x, i1, i2, 1 )
  call bread4( griddir, 'x2', x, i1, i2, 2 )
  call bread4( griddir, 'x3', x, i1, i2, 3 )
  call optimize
else
  forall( i=j1:j2 ) x(i,:,:,1) = dx * ( i - 1 - noff(1) )
  forall( i=k1:k2 ) x(:,i,:,2) = dx * ( i - 1 - noff(2) )
  forall( i=l1:l2 ) x(:,:,i,3) = dx * ( i - 1 - noff(3) )
  if ( inrm /= 0 ) then
    i = i0(inrm) + 1
    select case( inrm )
    case( 1 ); x(i+1:j2,:,:,1) = x(i:,:,:,1) - dx
    case( 2 ); x(:,i+1:k2,:,2) = x(:,i:,:,2) - dx
    case( 3 ); x(:,:,i+1:l2,3) = x(:,:,i:,3) - dx
    end select
  end if
  noper = 1
  i1oper(1,:) = i1cell
  i2oper(1,:) = i2cell + 1
end if

select case( grid )
case( '' )
case( 'constant' )
  oper(1) = 'h'
case( 'stretch' )
  oper(1) = 'r'
  x(:,:,:,3) = 2. * x(:,:,:,3)
case( 'slant' )
  oper(1) = 'g'
  theta = 20. * pi / 180.
  scl = sqrt( cos( theta ) ** 2. + ( 1. - sin( theta ) ) ** 2. )
  scl = sqrt( 2. ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case default; stop 'grid'
end select

! Duplicate edge nodes into halo
i2 = i2node
j1 = i2(1) + 1; j2 = i2(1)
k1 = i2(2) + 1; k2 = i2(2)
l1 = i2(3) + 1; l2 = i2(3)
if( bc(1) == 0 ) x(1,:,: ,:) = x(2,:,: ,:)
if( bc(4) == 0 ) x(j1,:,:,:) = x(j2,:,:,:)
if( bc(2) == 0 ) x(:,1,: ,:) = x(:,2,: ,:)
if( bc(5) == 0 ) x(:,k1,:,:) = x(:,k2,:,:)
if( bc(3) == 0 ) x(:,:,1 ,:) = x(:,:,2 ,:)
if( bc(6) == 0 ) x(:,:,l1,:) = x(:,:,l2,:)

! Test if hypocenter is located on this processor and save location
if ( all( i1 >= i1node .and. i1 <= i2node ) ) then
  hypop = .true.
  x0 = x(i0(1),i0(2),i0(3),:);
end if

end subroutine
end module

