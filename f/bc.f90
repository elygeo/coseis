! Boundary conditions, see defaults.m for description
module m_bc
implicit none
contains

! Scalar field
subroutine scalarbc( f, bc1, bc2, i1bc, i2bc, cell )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), cell
integer, dimension(3) :: i1, i2, b1, b2, nm
integer :: j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /) - cell
i1 = i1bc - 1
i2 = i2bc + 1 - cell
b1 = abs( bc1 )
b2 = abs( bc2 )
where ( bc1 == 0 .or. bc1 == 10 ) b1 = -1
where ( bc2 == 0 .or. bc2 == 10 ) b2 = -1
b1 = b1 + cell
b2 = b2 + cell
where ( nm <= 1 .or. i1 < 1 .or. i1 > nm ) b1 = 99
where ( nm <= 1 .or. i2 < 1 .or. i2 > nm ) b2 = 99
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Vacuum
if ( b1(1) == 0 ) f(j1,:,:) = 0.
if ( b1(2) == 0 ) f(:,k1,:) = 0.
if ( b1(3) == 0 ) f(:,:,l1) = 0.
if ( b2(1) == 0 ) f(j2,:,:) = 0.
if ( b2(2) == 0 ) f(:,k2,:) = 0.
if ( b2(3) == 0 ) f(:,:,l2) = 0.

! Mirror
if ( b1(1) == 2 ) f(j1,:,:) = f(j1+1,:,:)
if ( b1(2) == 2 ) f(:,k1,:) = f(:,k1+1,:)
if ( b1(3) == 2 ) f(:,:,l1) = f(:,:,l1+1)
if ( b2(1) == 2 ) f(j2,:,:) = f(j2-1,:,:)
if ( b2(2) == 2 ) f(:,k2,:) = f(:,k2-1,:)
if ( b2(3) == 2 ) f(:,:,l2) = f(:,:,l2-1)

end subroutine

! Vector/tensor field
subroutine vectorbc( f, bc1, bc2, i1bc, i2bc, tensor )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), tensor
integer, dimension(3) :: i1, i2, b1, b2, s1, s2, nm
integer :: j1, k1, l1, j2, k2, l2, cell, normal, tangent
cell = abs( tensor )
nm = (/ size(f,1), size(f,2), size(f,3) /) - cell
i1 = i1bc - 1
i2 = i2bc + 1 - cell
b1 = abs( bc1 )
b2 = abs( bc2 )
where ( bc1 == 0 .or. bc1 == 10 ) b1 = -1
where ( bc2 == 0 .or. bc2 == 10 ) b2 = -1
b1 = b1 + cell
b2 = b2 + cell
where ( nm <= 1 .or. i1 < 1 .or. i1 > nm ) b1 = 99
where ( nm <= 1 .or. i2 < 1 .or. i2 > nm ) b2 = 99
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Vacuum
if ( b1(1) == 0 ) f(j1,:,:,:) = 0.
if ( b1(2) == 0 ) f(:,k1,:,:) = 0.
if ( b1(3) == 0 ) f(:,:,l1,:) = 0.
if ( b2(1) == 0 ) f(j2,:,:,:) = 0.
if ( b2(2) == 0 ) f(:,k2,:,:) = 0.
if ( b2(3) == 0 ) f(:,:,l2,:) = 0.

! Mirror
s1 = sign( 1, bc1 )
s2 = sign( 1, bc2 )
if ( tensor == 0 ) then
  normal = -1
  tangent = 1
else
  normal = 1
  tangent = tensor
end if
if ( b1(1) == 2 ) then
  f(j1,:,:,1) = normal  * s1(1) * f(j1+1,:,:,1)
  f(j1,:,:,2) = tangent * s1(1) * f(j1+1,:,:,2)
  f(j1,:,:,3) = tangent * s1(1) * f(j1+1,:,:,3)
end if
if ( b1(2) == 2 ) then
  f(:,k1,:,1) = tangent * s1(2) * f(:,k1+1,:,1)
  f(:,k1,:,2) = normal  * s1(2) * f(:,k1+1,:,2)
  f(:,k1,:,3) = tangent * s1(2) * f(:,k1+1,:,3)
end if
if ( b1(3) == 2 ) then
  f(:,:,l1,1) = tangent * s1(3) * f(:,:,l1+1,1)
  f(:,:,l1,2) = tangent * s1(3) * f(:,:,l1+1,2)
  f(:,:,l1,3) = normal  * s1(3) * f(:,:,l1+1,3)
end if
if ( b2(1) == 2 ) then
  f(j2,:,:,1) = normal  * s2(1) * f(j2-1,:,:,1)
  f(j2,:,:,2) = tangent * s2(1) * f(j2-1,:,:,2)
  f(j2,:,:,3) = tangent * s2(1) * f(j2-1,:,:,3)
end if
if ( b2(2) == 2 ) then
  f(:,k2,:,1) = tangent * s2(2) * f(:,k2-1,:,1)
  f(:,k2,:,2) = normal  * s2(2) * f(:,k2-1,:,2)
  f(:,k2,:,3) = tangent * s2(2) * f(:,k2-1,:,3)
end if
if ( b2(3) == 2 ) then
  f(:,:,l2,1) = tangent * s2(3) * f(:,:,l2-1,1)
  f(:,:,l2,2) = tangent * s2(3) * f(:,:,l2-1,2)
  f(:,:,l2,3) = normal  * s2(3) * f(:,:,l2-1,3)
end if

end subroutine

end module

