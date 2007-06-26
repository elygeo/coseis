! Boundary conditions
module m_bc
implicit none
contains

subroutine scalarbc( f, bc1, bc2, i1bc, i2bc, cell )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), cell
integer :: i1(3), i2(3), n1(3), n2(3), nm(3), i, j1, k1, l1, j2, k2, l2, c
nm = (/ size(f,1), size(f,2), size(f,3) /)
i1 = i1bc
i2 = i2bc
n1 = i1 - 1
n2 = nm - i2
if ( cell /= 0 ) then
  c = 1
  i2 = i2 - 1
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( bc1 )
i2 = abs( bc2 )
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99

! Zero BC
if ( i1(1) <= 0 ) then; do i=1,n1(1); f(j1-i,:,:) = 0.; end do; end if
if ( i1(2) <= 0 ) then; do i=1,n1(2); f(:,k1-i,:) = 0.; end do; end if
if ( i1(3) <= 0 ) then; do i=1,n1(3); f(:,:,l1-i) = 0.; end do; end if
if ( i2(1) <= 0 ) then; do i=1,n2(1); f(j2+i,:,:) = 0.; end do; end if
if ( i2(2) <= 0 ) then; do i=1,n2(2); f(:,k2+i,:) = 0.; end do; end if
if ( i2(3) <= 0 ) then; do i=1,n2(3); f(:,:,l2+i) = 0.; end do; end if

! Mirror on cell BC
if ( i1(1)-c == 2 ) then; do i=1,n1(1); f(j1-i,:,:) = f(j1+i-1,:,:); end do; end if
if ( i1(2)-c == 2 ) then; do i=1,n1(2); f(:,k1-i,:) = f(:,k1+i-1,:); end do; end if
if ( i1(3)-c == 2 ) then; do i=1,n1(3); f(:,:,l1-i) = f(:,:,l1+i-1); end do; end if
if ( i2(1)-c == 2 ) then; do i=1,n2(1); f(j2+i,:,:) = f(j2-i+1,:,:); end do; end if
if ( i2(2)-c == 2 ) then; do i=1,n2(2); f(:,k2+i,:) = f(:,k2-i+1,:); end do; end if
if ( i2(3)-c == 2 ) then; do i=1,n2(3); f(:,:,l2+i) = f(:,:,l2-i+1); end do; end if

! Mirror on node BC
if ( i1(1)+c == 3 ) then; do i=1,n1(1); f(j1-i,:,:) = f(j1+i,:,:); end do; end if
if ( i1(2)+c == 3 ) then; do i=1,n1(2); f(:,k1-i,:) = f(:,k1+i,:); end do; end if
if ( i1(3)+c == 3 ) then; do i=1,n1(3); f(:,:,l1-i) = f(:,:,l1+i); end do; end if
if ( i2(1)+c == 3 ) then; do i=1,n2(1); f(j2+i,:,:) = f(j2-i,:,:); end do; end if
if ( i2(2)+c == 3 ) then; do i=1,n2(2); f(:,k2+i,:) = f(:,k2-i,:); end do; end if
if ( i2(3)+c == 3 ) then; do i=1,n2(3); f(:,:,l2+i) = f(:,:,l2-i); end do; end if

! Continuing BC
if ( i1(1) == 4 ) then; do i=1,n1(1); f(j1-i,:,:) = f(j1,:,:); end do; end if
if ( i1(2) == 4 ) then; do i=1,n1(2); f(:,k1-i,:) = f(:,k1,:); end do; end if
if ( i1(3) == 4 ) then; do i=1,n1(3); f(:,:,l1-i) = f(:,:,l1); end do; end if
if ( i2(1) == 4 ) then; do i=1,n2(1); f(j2+i,:,:) = f(j2,:,:); end do; end if
if ( i2(2) == 4 ) then; do i=1,n2(2); f(:,k2+i,:) = f(:,k2,:); end do; end if
if ( i2(3) == 4 ) then; do i=1,n2(3); f(:,:,l2+i) = f(:,:,l2); end do; end if

end subroutine

subroutine vectorbc( f, bc1, bc2, i1bc, i2bc, tensor )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: bc1(3), bc2(3), i1bc(3), i2bc(3), tensor
integer :: i1(3), i2(3), n1(3), n2(3), nm(3), i, j1, k1, l1, j2, k2, l2, a, b, c, s(3)
nm = (/ size(f,1), size(f,2), size(f,3) /)
i1 = i1bc
i2 = i2bc
n1 = i1 - 1
n2 = nm - i2
a = -1
b = 1
if ( tensor /= 0 ) then
  i2 = i2 - 1
  a = 1
  b = sign( 1, tensor )
  c = 1
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( bc1 )
i2 = abs( bc2 )
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99

! Zero BC
if ( i1(1) <= 1 ) then; do i=1,n1(1); f(j1-i,:,:,:) = 0.; end do; end if
if ( i1(2) <= 1 ) then; do i=1,n1(2); f(:,k1-i,:,:) = 0.; end do; end if
if ( i1(3) <= 1 ) then; do i=1,n1(3); f(:,:,l1-i,:) = 0.; end do; end if
if ( i2(1) <= 1 ) then; do i=1,n2(1); f(j2+i,:,:,:) = 0.; end do; end if
if ( i2(2) <= 1 ) then; do i=1,n2(2); f(:,k2+i,:,:) = 0.; end do; end if
if ( i2(3) <= 1 ) then; do i=1,n2(3); f(:,:,l2+i,:) = 0.; end do; end if

! Continuing BC
if ( i1(1) == 4 ) then; do i=1,n1(1); f(j1-i,:,:,:) = f(j1,:,:,:); end do; end if
if ( i1(2) == 4 ) then; do i=1,n1(2); f(:,k1-i,:,:) = f(:,k1,:,:); end do; end if
if ( i1(3) == 4 ) then; do i=1,n1(3); f(:,:,l1-i,:) = f(:,:,l1,:); end do; end if
if ( i2(1) == 4 ) then; do i=1,n2(1); f(j2+i,:,:,:) = f(j2,:,:,:); end do; end if
if ( i2(2) == 4 ) then; do i=1,n2(2); f(:,k2+i,:,:) = f(:,k2,:,:); end do; end if
if ( i2(3) == 4 ) then; do i=1,n2(3); f(:,:,l2+i,:) = f(:,:,l2,:); end do; end if

! Mirror on cell BC
if ( i1(1)-c == 2 ) then
  s = (/ a, b, b /) * sign( 1, bc1(1) )
  do i = 1, n1(1)
    f(j1-i,:,:,1) = s(1) * f(j1+i-1,:,:,1)
    f(j1-i,:,:,2) = s(2) * f(j1+i-1,:,:,2)
    f(j1-i,:,:,3) = s(3) * f(j1+i-1,:,:,3)
  end do
end if
if ( i1(2)-c == 2 ) then
  s = (/ b, a, b /) * sign( 1, bc1(2) )
  do i = 1, n1(2)
    f(:,k1-i,:,1) = s(1) * f(:,k1+i-1,:,1)
    f(:,k1-i,:,2) = s(2) * f(:,k1+i-1,:,2)
    f(:,k1-i,:,3) = s(3) * f(:,k1+i-1,:,3)
  end do
end if
if ( i1(3)-c == 2 ) then
  s = (/ b, b, a /) * sign( 1, bc1(3) )
  do i = 1, n1(3)
    f(:,:,l1-i,1) = s(1) * f(:,:,l1+i-1,1)
    f(:,:,l1-i,2) = s(2) * f(:,:,l1+i-1,2)
    f(:,:,l1-i,3) = s(3) * f(:,:,l1+i-1,3)
  end do
end if
if ( i2(1)-c == 2 ) then
  s = (/ a, b, b /) * sign( 1, bc2(1) )
  do i = 1, n2(1)
    f(j2+i,:,:,1) = s(1) * f(j2-i+1,:,:,1)
    f(j2+i,:,:,2) = s(2) * f(j2-i+1,:,:,2)
    f(j2+i,:,:,3) = s(3) * f(j2-i+1,:,:,3)
  end do
end if
if ( i2(2)-c == 2 ) then
  s = (/ b, a, b /) * sign( 1, bc2(2) )
  do i = 1, n2(2)
    f(:,k2+i,:,1) = s(1) * f(:,k2-i+1,:,1)
    f(:,k2+i,:,2) = s(2) * f(:,k2-i+1,:,2)
    f(:,k2+i,:,3) = s(3) * f(:,k2-i+1,:,3)
  end do
end if
if ( i2(3)-c == 2 ) then
  s = (/ b, b, a /) * sign( 1, bc2(3) )
  do i = 1, n2(3)
    f(:,:,l2+i,1) = s(1) * f(:,:,l2-i+1,1)
    f(:,:,l2+i,2) = s(2) * f(:,:,l2-i+1,2)
    f(:,:,l2+i,3) = s(3) * f(:,:,l2-i+1,3)
  end do
end if

! Mirror on node BC
if ( i1(1)+c == 3 ) then
  s = (/ a, b, b /) * sign( 1, bc1(1) )
  do i = 1, n1(1)
    f(j1-i,:,:,1) = s(1) * f(j1+i,:,:,1)
    f(j1-i,:,:,2) = s(2) * f(j1+i,:,:,2)
    f(j1-i,:,:,3) = s(3) * f(j1+i,:,:,3)
  end do
end if
if ( i1(2)+c == 3 ) then
  s = (/ b, a, b /) * sign( 1, bc1(2) )
  do i = 1, n1(2)
    f(:,k1-i,:,1) = s(1) * f(:,k1+i,:,1)
    f(:,k1-i,:,2) = s(2) * f(:,k1+i,:,2)
    f(:,k1-i,:,3) = s(3) * f(:,k1+i,:,3)
  end do
end if
if ( i1(3)+c == 3 ) then
  s = (/ b, b, a /) * sign( 1, bc1(3) )
  do i = 1, n1(3)
    f(:,:,l1-i,1) = s(1) * f(:,:,l1+i,1)
    f(:,:,l1-i,2) = s(2) * f(:,:,l1+i,2)
    f(:,:,l1-i,3) = s(3) * f(:,:,l1+i,3)
  end do
end if
if ( i2(1)+c == 3 ) then
  s = (/ a, b, b /) * sign( 1, bc2(1) )
  do i = 1, n2(1)
    f(j2+i,:,:,1) = s(1) * f(j2-i,:,:,1)
    f(j2+i,:,:,2) = s(2) * f(j2-i,:,:,2)
    f(j2+i,:,:,3) = s(3) * f(j2-i,:,:,3)
  end do
end if
if ( i2(2)+c == 3 ) then
  s = (/ b, a, b /) * sign( 1, bc2(2) )
  do i = 1, n2(2)
    f(:,k2+i,:,1) = s(1) * f(:,k2-i,:,1)
    f(:,k2+i,:,2) = s(2) * f(:,k2-i,:,2)
    f(:,k2+i,:,3) = s(3) * f(:,k2-i,:,3)
  end do
end if
if ( i2(3)+c == 3 ) then
  s = (/ b, b, a /) * sign( 1, bc2(3) )
  do i = 1, n2(3)
    f(:,:,l2+i,1) = s(1) * f(:,:,l2-i,1)
    f(:,:,l2+i,2) = s(2) * f(:,:,l2-i,2)
    f(:,:,l2+i,3) = s(3) * f(:,:,l2-i,3)
  end do
end if

end subroutine

end module

