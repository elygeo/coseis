! Boundary conditions
module m_bc
implicit none
contains

subroutine scalarbc( f, ibc1, ibc2, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), nhalo
integer :: i1(3), i2(3), n(3), i, j1, k1, l1, j2, k2, l2
n = (/ size(f,1), size(f,2), size(f,3) /)
i1 = 1 + nhalo
i2 = n - nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( n == 1 ) i1 = 0
where ( n == 1 ) i2 = 0
select case( i1(1) )
case( 2 ); forall( i=1:nhalo ) f(j1-i,:,:) = f(j1+i-1,:,:)
case( 3 ); forall( i=1:nhalo ) f(j1-i,:,:) = f(j1+i,:,:)
case( 4 ); forall( i=1:nhalo ) f(j1-i,:,:) = f(j1,:,:)
end select
select case( i2(1) )
case( 2 ); forall( i=1:nhalo ) f(j2+i,:,:) = f(j2-i+1,:,:)
case( 3 ); forall( i=1:nhalo ) f(j2+i,:,:) = f(j2-i,:,:)
case( 4 ); forall( i=1:nhalo ) f(j2+i,:,:) = f(j2,:,:)
end select
select case( i1(2) )
case( 2 ); forall( i=1:nhalo ) f(:,k1-i,:) = f(:,k1+i-1,:)
case( 3 ); forall( i=1:nhalo ) f(:,k1-i,:) = f(:,k1+i,:)
case( 4 ); forall( i=1:nhalo ) f(:,k1-i,:) = f(:,k1,:)
end select
select case( i2(2) )
case( 2 ); forall( i=1:nhalo ) f(:,k2+i,:) = f(:,k2-i+1,:)
case( 3 ); forall( i=1:nhalo ) f(:,k2+i,:) = f(:,k2-i,:)
case( 4 ); forall( i=1:nhalo ) f(:,k2+i,:) = f(:,k2,:)
end select
select case( i1(3) )
case( 2 ); forall( i=1:nhalo ) f(:,:,l1-i) = f(:,:,l1+i-1)
case( 3 ); forall( i=1:nhalo ) f(:,:,l1-i) = f(:,:,l1+i)
case( 4 ); forall( i=1:nhalo ) f(:,:,l1-i) = f(:,:,l1)
end select
select case( i2(3) )
case( 2 ); forall( i=1:nhalo ) f(:,:,l2+i) = f(:,:,l2-i+1)
case( 3 ); forall( i=1:nhalo ) f(:,:,l2+i) = f(:,:,l2-i)
case( 4 ); forall( i=1:nhalo ) f(:,:,l2+i) = f(:,:,l2)
end select
end subroutine

subroutine vectorbc( f, ibc1, ibc2, nhalo )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), nhalo
integer :: i1(3), i2(3), n(3), i, j1, k1, l1, j2, k2, l2, s
n = (/ size(f,1), size(f,2), size(f,3) /)
i1 = 1 + nhalo
i2 = n - nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( n == 1 ) i1 = 0
where ( n == 1 ) i2 = 0
s = sign( 1, ibc1(1) )
select case( i1(1) )
case( 2 )
  forall( i=1:nhalo )
    f(j1-i,:,:,1) = -s * f(j1+i-1,:,:,1)
    f(j1-i,:,:,2) =  s * f(j1+i-1,:,:,2)
    f(j1-i,:,:,3) =  s * f(j1+i-1,:,:,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(j1-i,:,:,1) = -s * f(j1+i,:,:,1)
    f(j1-i,:,:,2) =  s * f(j1+i,:,:,2)
    f(j1-i,:,:,3) =  s * f(j1+i,:,:,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(j1-i,:,:,:) = s * f(j1,:,:,:)
end select
s = sign( 1, ibc2(1) )
select case( i2(1) )
case( 2 )
  forall( i=1:nhalo )
    f(j2+i,:,:,1) = -s * f(j2-i+1,:,:,1)
    f(j2+i,:,:,2) =  s * f(j2-i+1,:,:,2)
    f(j2+i,:,:,3) =  s * f(j2-i+1,:,:,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(j2+i,:,:,1) = -s * f(j2-i,:,:,1)
    f(j2+i,:,:,2) =  s * f(j2-i,:,:,2)
    f(j2+i,:,:,3) =  s * f(j2-i,:,:,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(j2+i,:,:,:) = s * f(j2,:,:,:)
end select
s = sign( 1, ibc1(2) )
select case( i1(2) )
case( 2 )
  forall( i=1:nhalo )
    f(:,k1-i,:,1) =  s * f(:,k1+i-1,:,1)
    f(:,k1-i,:,2) = -s * f(:,k1+i-1,:,2)
    f(:,k1-i,:,3) =  s * f(:,k1+i-1,:,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(:,k1-i,:,1) =  s * f(:,k1+i,:,1)
    f(:,k1-i,:,2) = -s * f(:,k1+i,:,2)
    f(:,k1-i,:,3) =  s * f(:,k1+i,:,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(:,k1-i,:,:) = s * f(:,k1,:,:)
end select
s = sign( 1, ibc2(2) )
select case( i2(2) )
case( 2 )
  forall( i=1:nhalo )
    f(:,k2+i,:,1) =  s * f(:,k2-i+1,:,1)
    f(:,k2+i,:,2) = -s * f(:,k2-i+1,:,2)
    f(:,k2+i,:,3) =  s * f(:,k2-i+1,:,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(:,k2+i,:,1) =  s * f(:,k2-i,:,1)
    f(:,k2+i,:,2) = -s * f(:,k2-i,:,2)
    f(:,k2+i,:,3) =  s * f(:,k2-i,:,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(:,k2+i,:,:) = s * f(:,k2,:,:)
end select
s = sign( 1, ibc1(3) )
select case( i1(3) )
case( 2 )
  forall( i=1:nhalo )
    f(:,:,l1-i,1) =  s * f(:,:,l1+i-1,1)
    f(:,:,l1-i,2) =  s * f(:,:,l1+i-1,2)
    f(:,:,l1-i,3) = -s * f(:,:,l1+i-1,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(:,:,l1-i,1) =  s * f(:,:,l1+i,1)
    f(:,:,l1-i,2) =  s * f(:,:,l1+i,2)
    f(:,:,l1-i,3) = -s * f(:,:,l1+i,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(:,:,l1-i,:) = s * f(:,:,l1,:)
end select
s = sign( 1, ibc2(3) )
select case( i2(3) )
case( 2 )
  forall( i=1:nhalo )
    f(:,:,l2+i,1) =  s * f(:,:,l2-i+1,1)
    f(:,:,l2+i,2) =  s * f(:,:,l2-i+1,2)
    f(:,:,l2+i,3) = -s * f(:,:,l2-i+1,3)
  end forall
case( 3 )
  forall( i=1:nhalo )
    f(:,:,l2+i,1) =  s * f(:,:,l2-i,1)
    f(:,:,l2+i,2) =  s * f(:,:,l2-i,2)
    f(:,:,l2+i,3) = -s * f(:,:,l2-i,3)
  end forall
case( 4 )
  forall( i=1:nhalo ) f(:,:,l2+i,:) = s * f(:,:,l2,:)
end select
end subroutine

end module

