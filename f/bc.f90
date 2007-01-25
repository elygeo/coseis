! Boundary conditions
module m_bc
implicit none
contains

subroutine scalarbc( f, ibc1, ibc2, nhalo, cell )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), nhalo, cell
integer :: i1(3), i2(3), nm(3), i, j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /)
i1 = 1 + nhalo
i2 = nm - nhalo - cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( nm == 1 ) i1 = 0
where ( nm == 1 ) i2 = 0

! Mirror on cell BC
if ( i1(1) == 2 ) forall( i=1:nhalo-cell ) f(j1-i-cell,:,:) = f(j1+i-1,:,:)
if ( i1(2) == 2 ) forall( i=1:nhalo-cell ) f(:,k1-i-cell,:) = f(:,k1+i-1,:)
if ( i1(3) == 2 ) forall( i=1:nhalo-cell ) f(:,:,l1-i-cell) = f(:,:,l1+i-1)
if ( i2(1) == 2 ) forall( i=1:nhalo-cell ) f(j2+i+cell,:,:) = f(j2-i+1,:,:)
if ( i2(2) == 2 ) forall( i=1:nhalo-cell ) f(:,k2+i+cell,:) = f(:,k2-i+1,:)
if ( i2(3) == 2 ) forall( i=1:nhalo-cell ) f(:,:,l2+i+cell) = f(:,:,l2-i+1)

! Mirror on node BC
if ( i1(1) == 3 ) forall( i=1:nhalo ) f(j1-i,:,:) = f(j1+i-cell,:,:)
if ( i1(2) == 3 ) forall( i=1:nhalo ) f(:,k1-i,:) = f(:,k1+i-cell,:)
if ( i1(3) == 3 ) forall( i=1:nhalo ) f(:,:,l1-i) = f(:,:,l1+i-cell)
if ( i2(1) == 3 ) forall( i=1:nhalo ) f(j2+i,:,:) = f(j2-i+cell,:,:)
if ( i2(2) == 3 ) forall( i=1:nhalo ) f(:,k2+i,:) = f(:,k2-i+cell,:)
if ( i2(3) == 3 ) forall( i=1:nhalo ) f(:,:,l2+i) = f(:,:,l2-i+cell)

! Continuing BC
if ( i1(1) == 4 ) forall( i=1:nhalo ) f(j1-i,:,:) = f(j1,:,:)
if ( i1(2) == 4 ) forall( i=1:nhalo ) f(:,k1-i,:) = f(:,k1,:)
if ( i1(3) == 4 ) forall( i=1:nhalo ) f(:,:,l1-i) = f(:,:,l1)
if ( i2(1) == 4 ) forall( i=1:nhalo ) f(j2+i,:,:) = f(j2,:,:)
if ( i2(2) == 4 ) forall( i=1:nhalo ) f(:,k2+i,:) = f(:,k2,:)
if ( i2(3) == 4 ) forall( i=1:nhalo ) f(:,:,l2+i) = f(:,:,l2)

end subroutine

subroutine vectorbc( f, ibc1, ibc2, nhalo )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), nhalo
integer :: i1(3), i2(3), nm(3), i, j1, k1, l1, j2, k2, l2, s
nm = (/ size(f,1), size(f,2), size(f,3) /)
i1 = 1 + nhalo
i2 = nm - nhalo
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( nm == 1 ) i1 = 0
where ( nm == 1 ) i2 = 0

! Continuing BC
if ( i1(1) == 4 ) forall( i=1:nhalo ) f(j1-i,:,:,:) = f(j1,:,:,:)
if ( i1(2) == 4 ) forall( i=1:nhalo ) f(:,k1-i,:,:) = f(:,k1,:,:)
if ( i1(3) == 4 ) forall( i=1:nhalo ) f(:,:,l1-i,:) = f(:,:,l1,:)
if ( i2(1) == 4 ) forall( i=1:nhalo ) f(j2+i,:,:,:) = f(j2,:,:,:)
if ( i2(2) == 4 ) forall( i=1:nhalo ) f(:,k2+i,:,:) = f(:,k2,:,:)
if ( i2(3) == 4 ) forall( i=1:nhalo ) f(:,:,l2+i,:) = f(:,:,l2,:)

! Mirror on cell BC
if ( i1(1) == 2 ) then
  s = sign( 1, ibc1(1) )
  forall( i=1:nhalo )
    f(j1-i,:,:,1) = -s * f(j1+i-1,:,:,1)
    f(j1-i,:,:,2) =  s * f(j1+i-1,:,:,2)
    f(j1-i,:,:,3) =  s * f(j1+i-1,:,:,3)
  end forall
end if
if ( i1(2) == 2 ) then
  s = sign( 1, ibc1(2) )
  forall( i=1:nhalo )
    f(:,k1-i,:,1) =  s * f(:,k1+i-1,:,1)
    f(:,k1-i,:,2) = -s * f(:,k1+i-1,:,2)
    f(:,k1-i,:,3) =  s * f(:,k1+i-1,:,3)
  end forall
end if
if ( i1(3) == 2 ) then
  s = sign( 1, ibc1(3) )
  forall( i=1:nhalo )
    f(:,:,l1-i,1) =  s * f(:,:,l1+i-1,1)
    f(:,:,l1-i,2) =  s * f(:,:,l1+i-1,2)
    f(:,:,l1-i,3) = -s * f(:,:,l1+i-1,3)
  end forall
end if
if ( i2(1) == 2 ) then
  s = sign( 1, ibc2(1) )
  forall( i=1:nhalo )
    f(j2+i,:,:,1) = -s * f(j2-i+1,:,:,1)
    f(j2+i,:,:,2) =  s * f(j2-i+1,:,:,2)
    f(j2+i,:,:,3) =  s * f(j2-i+1,:,:,3)
  end forall
end if
if ( i2(2) == 2 ) then
  s = sign( 1, ibc2(2) )
  forall( i=1:nhalo )
    f(:,k2+i,:,1) =  s * f(:,k2-i+1,:,1)
    f(:,k2+i,:,2) = -s * f(:,k2-i+1,:,2)
    f(:,k2+i,:,3) =  s * f(:,k2-i+1,:,3)
  end forall
end if
if ( i2(3) == 2 ) then
  s = sign( 1, ibc2(3) )
  forall( i=1:nhalo )
    f(:,:,l2+i,1) =  s * f(:,:,l2-i+1,1)
    f(:,:,l2+i,2) =  s * f(:,:,l2-i+1,2)
    f(:,:,l2+i,3) = -s * f(:,:,l2-i+1,3)
  end forall
end if

! Mirror on node BC
if ( i1(1) == 3 ) then
  s = sign( 1, ibc1(1) )
  forall( i=1:nhalo )
    f(j1-i,:,:,1) = -s * f(j1+i,:,:,1)
    f(j1-i,:,:,2) =  s * f(j1+i,:,:,2)
    f(j1-i,:,:,3) =  s * f(j1+i,:,:,3)
  end forall
end if
if ( i1(2) == 3 ) then
  s = sign( 1, ibc1(2) )
  forall( i=1:nhalo )
    f(:,k1-i,:,1) =  s * f(:,k1+i,:,1)
    f(:,k1-i,:,2) = -s * f(:,k1+i,:,2)
    f(:,k1-i,:,3) =  s * f(:,k1+i,:,3)
  end forall
end if
if ( i1(3) == 3 ) then
  s = sign( 1, ibc1(3) )
  forall( i=1:nhalo )
    f(:,:,l1-i,1) =  s * f(:,:,l1+i,1)
    f(:,:,l1-i,2) =  s * f(:,:,l1+i,2)
    f(:,:,l1-i,3) = -s * f(:,:,l1+i,3)
  end forall
end if
if ( i2(1) == 3 ) then
  s = sign( 1, ibc2(1) )
  forall( i=1:nhalo )
    f(j2+i,:,:,1) = -s * f(j2-i,:,:,1)
    f(j2+i,:,:,2) =  s * f(j2-i,:,:,2)
    f(j2+i,:,:,3) =  s * f(j2-i,:,:,3)
  end forall
end if
if ( i2(2) == 3 ) then
  s = sign( 1, ibc2(2) )
  forall( i=1:nhalo )
    f(:,k2+i,:,1) =  s * f(:,k2-i,:,1)
    f(:,k2+i,:,2) = -s * f(:,k2-i,:,2)
    f(:,k2+i,:,3) =  s * f(:,k2-i,:,3)
  end forall
end if
if ( i2(3) == 3 ) then
  s = sign( 1, ibc2(3) )
  forall( i=1:nhalo )
    f(:,:,l2+i,1) =  s * f(:,:,l2-i,1)
    f(:,:,l2+i,2) =  s * f(:,:,l2-i,2)
    f(:,:,l2+i,3) = -s * f(:,:,l2-i,3)
  end forall
end if

end subroutine

end module

