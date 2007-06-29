! Boundary conditions
module m_bc
implicit none
contains

! Scalar field
subroutine scalarbc( f, bc1, bc2, i1bc, i2bc, cell )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), cell
integer :: i1(3), i2(3), nm(3), j1, k1, l1, j2, k2, l2, c
nm = (/ size(f,1), size(f,2), size(f,3) /)
if ( cell == 0 ) then
  i1 = i1bc - 1
  i2 = i2bc + 1
  c = 0
else
  i1 = i1bc - 1
  i2 = i2bc
  c = 1
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( bc1 )
i2 = abs( bc2 )
where ( i1 == 10 ) i1 = 0
where ( i2 == 10 ) i2 = 0
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99
i1 = i1 + 1 - c
i2 = i2 + 1 - c

! Zero
if ( i1(1) == 0 ) f(j1,:,:) = 0.
if ( i1(2) == 0 ) f(:,k1,:) = 0.
if ( i1(3) == 0 ) f(:,:,l1) = 0.
if ( i2(1) == 0 ) f(j2,:,:) = 0.
if ( i2(2) == 0 ) f(:,k2,:) = 0.
if ( i2(3) == 0 ) f(:,:,l2) = 0.

! Mirror
if ( i1(1) == 2 ) f(j1,:,:) = f(j1+1,:,:)
if ( i1(2) == 2 ) f(:,k1,:) = f(:,k1+1,:)
if ( i1(3) == 2 ) f(:,:,l1) = f(:,:,l1+1)
if ( i2(1) == 2 ) f(j2,:,:) = f(j2-1,:,:)
if ( i2(2) == 2 ) f(:,k2,:) = f(:,k2-1,:)
if ( i2(3) == 2 ) f(:,:,l2) = f(:,:,l2-1)

end subroutine

! Vector/tensor field
subroutine vectorbc( f, bc1, bc2, i1bc, i2bc, tensor )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), tensor
integer :: i1(3), i2(3), s1(3), s2(3), nm(3), j1, k1, l1, j2, k2, l2, a, b, c
nm = (/ size(f,1), size(f,2), size(f,3) /)
if ( tensor == 0 ) then
  i1 = i1bc - 1
  i2 = i2bc + 1
  a = -1
  b = 1
  c = 0
else
  i1 = i1bc - 1
  i2 = i2bc
  a = 1
  b = sign( 1, tensor )
  c = 1
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
s1 = sign( 1, bc1 )
s2 = sign( 1, bc2 )
i1 = abs( bc1 )
i2 = abs( bc2 )
where ( i1 == 10 ) i1 = 0
where ( i2 == 10 ) i2 = 0
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99
i1 = i1 + 1 - c
i2 = i2 + 1 - c

! Zero
if ( i1(1) == 0 ) f(j1,:,:,:) = 0.
if ( i1(2) == 0 ) f(:,k1,:,:) = 0.
if ( i1(3) == 0 ) f(:,:,l1,:) = 0.
if ( i2(1) == 0 ) f(j2,:,:,:) = 0.
if ( i2(2) == 0 ) f(:,k2,:,:) = 0.
if ( i2(3) == 0 ) f(:,:,l2,:) = 0.

! Mirror
if ( i1(1) == 2 ) then
  f(j1,:,:,1) = a * s1(1) * f(j1+1,:,:,1)
  f(j1,:,:,2) = b * s1(1) * f(j1+1,:,:,2)
  f(j1,:,:,3) = b * s1(1) * f(j1+1,:,:,3)
end if
if ( i1(2) == 2 ) then
  f(:,k1,:,1) = b * s1(2) * f(:,k1+1,:,1)
  f(:,k1,:,2) = a * s1(2) * f(:,k1+1,:,2)
  f(:,k1,:,3) = b * s1(2) * f(:,k1+1,:,3)
end if
if ( i1(3) == 2 ) then
  f(:,:,l1,1) = b * s1(3) * f(:,:,l1+1,1)
  f(:,:,l1,2) = b * s1(3) * f(:,:,l1+1,2)
  f(:,:,l1,3) = a * s1(3) * f(:,:,l1+1,3)
end if
if ( i2(1) == 2 ) then
  f(j2,:,:,1) = a * s2(1) * f(j2-1,:,:,1)
  f(j2,:,:,2) = b * s2(1) * f(j2-1,:,:,2)
  f(j2,:,:,3) = b * s2(1) * f(j2-1,:,:,3)
end if
if ( i2(2) == 2 ) then
  f(:,k2,:,1) = b * s2(2) * f(:,k2-1,:,1)
  f(:,k2,:,2) = a * s2(2) * f(:,k2-1,:,2)
  f(:,k2,:,3) = b * s2(2) * f(:,k2-1,:,3)
end if
if ( i2(3) == 2 ) then
  f(:,:,l2,1) = b * s2(3) * f(:,:,l2-1,1)
  f(:,:,l2,2) = b * s2(3) * f(:,:,l2-1,2)
  f(:,:,l2,3) = a * s2(3) * f(:,:,l2-1,3)
end if

end subroutine

end module

