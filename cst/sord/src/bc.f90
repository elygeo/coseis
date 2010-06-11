! boundary conditions
module m_bc
implicit none
contains

! scalar field
subroutine scalar_bc( f, bc1, bc2, i1, i2 )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1(3), i2(3)
integer :: b1(3), b2(3), nm(3), j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
b1 = abs( mod( bc1, 10 ) )
b2 = abs( mod( bc2, 10 ) )
where ( b1 == 4 ) b1 = 2
where ( b2 == 4 ) b2 = 2
where ( nm == 1 .or. i1 <  1 .or. i1 >= nm ) b1 = 99
where ( nm == 1 .or. i2 <= 1 .or. i2 >  nm ) b2 = 99
if ( b1(1) == 2 ) f(j1,:,:) = f(j1+1,:,:)
if ( b1(2) == 2 ) f(:,k1,:) = f(:,k1+1,:)
if ( b1(3) == 2 ) f(:,:,l1) = f(:,:,l1+1)
if ( b2(1) == 2 ) f(j2,:,:) = f(j2-1,:,:)
if ( b2(2) == 2 ) f(:,k2,:) = f(:,k2-1,:)
if ( b2(3) == 2 ) f(:,:,l2) = f(:,:,l2-1)
end subroutine

! vector field
subroutine vector_bc( f, bc1, bc2, i1, i2 )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1(3), i2(3)
integer :: nm(3), b1(3), b2(3), s1(3), s2(3), j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
b1 = mod( bc1, 10 )
b2 = mod( bc2, 10 )
where ( nm == 1 .or. i1 < 1 .or. i1 > nm ) b1 = 99
where ( nm == 1 .or. i2 < 1 .or. i2 > nm ) b2 = 99

! anti-mirror symmetry at the node
if ( b1(1) == -1 ) then; f(j1,:,:,2) = 0.0; f(j1,:,:,3) = 0.0; end if
if ( b1(2) == -1 ) then; f(:,k1,:,3) = 0.0; f(:,k1,:,1) = 0.0; end if
if ( b1(3) == -1 ) then; f(:,:,l1,1) = 0.0; f(:,:,l1,2) = 0.0; end if
if ( b2(1) == -1 ) then; f(j2,:,:,2) = 0.0; f(j2,:,:,3) = 0.0; end if
if ( b2(2) == -1 ) then; f(:,k2,:,3) = 0.0; f(:,k2,:,1) = 0.0; end if
if ( b2(3) == -1 ) then; f(:,:,l2,1) = 0.0; f(:,:,l2,2) = 0.0; end if

! mirror symmetry at the node
if ( b1(1) == 1 ) f(j1,:,:,1) = 0.0
if ( b1(2) == 1 ) f(:,k1,:,2) = 0.0
if ( b1(3) == 1 ) f(:,:,l1,3) = 0.0
if ( b2(1) == 1 ) f(j2,:,:,1) = 0.0
if ( b2(2) == 1 ) f(:,k2,:,2) = 0.0
if ( b2(3) == 1 ) f(:,:,l2,3) = 0.0

! rigid
if ( b1(1) == 3 ) f(j1,:,:,:) = 0.0
if ( b1(2) == 3 ) f(:,k1,:,:) = 0.0
if ( b1(3) == 3 ) f(:,:,l1,:) = 0.0
if ( b2(1) == 3 ) f(j2,:,:,:) = 0.0
if ( b2(2) == 3 ) f(:,k2,:,:) = 0.0
if ( b2(3) == 3 ) f(:,:,l2,:) = 0.0

where ( i1 >= nm ) b1 = 99
where ( i2 <= 1  ) b2 = 99

! continue
if ( b1(1) == 4 ) f(j1,:,:,:) = f(j1+1,:,:,:)
if ( b1(2) == 4 ) f(:,k1,:,:) = f(:,k1+1,:,:)
if ( b1(3) == 4 ) f(:,:,l1,:) = f(:,:,l1+1,:)
if ( b2(1) == 4 ) f(j2,:,:,:) = f(j2-1,:,:,:)
if ( b2(2) == 4 ) f(:,k2,:,:) = f(:,k2-1,:,:)
if ( b2(3) == 4 ) f(:,:,l2,:) = f(:,:,l2-1,:)

! symmetry at the cell
b1 = abs( b1 )
b2 = abs( b2 )
s1 = sign( 1, bc1 )
s2 = sign( 1, bc2 )
if ( b1(1) == 2 ) then
    f(j1,:,:,1) = -s1(1) * f(j1+1,:,:,1)
    f(j1,:,:,2) =  s1(1) * f(j1+1,:,:,2)
    f(j1,:,:,3) =  s1(1) * f(j1+1,:,:,3)
end if
if ( b1(2) == 2 ) then
    f(:,k1,:,1) =  s1(2) * f(:,k1+1,:,1)
    f(:,k1,:,2) = -s1(2) * f(:,k1+1,:,2)
    f(:,k1,:,3) =  s1(2) * f(:,k1+1,:,3)
end if
if ( b1(3) == 2 ) then
    f(:,:,l1,1) =  s1(3) * f(:,:,l1+1,1)
    f(:,:,l1,2) =  s1(3) * f(:,:,l1+1,2)
    f(:,:,l1,3) = -s1(3) * f(:,:,l1+1,3)
end if
if ( b2(1) == 2 ) then
    f(j2,:,:,1) = -s2(1) * f(j2-1,:,:,1)
    f(j2,:,:,2) =  s2(1) * f(j2-1,:,:,2)
    f(j2,:,:,3) =  s2(1) * f(j2-1,:,:,3)
end if
if ( b2(2) == 2 ) then
    f(:,k2,:,1) =  s2(2) * f(:,k2-1,:,1)
    f(:,k2,:,2) = -s2(2) * f(:,k2-1,:,2)
    f(:,k2,:,3) =  s2(2) * f(:,k2-1,:,3)
end if
if ( b2(3) == 2 ) then
    f(:,:,l2,1) =  s2(3) * f(:,:,l2-1,1)
    f(:,:,l2,2) =  s2(3) * f(:,:,l2-1,2)
    f(:,:,l2,3) = -s2(3) * f(:,:,l2-1,3)
end if

end subroutine

end module

