! Boundary conditions
module m_bc
implicit none
contains

subroutine scalarbc( f, ibc1, ibc2, n, c )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), n(3), c
integer :: i1(3), i2(3), nm(3), i, j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /)
i1 = 1 + n
i2 = nm - n - c
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99

! Zero BC
if ( i1(1) <= 1 ) then; do i=1,n(1); f(j1-i,:,:) = 0.; end do; end if
if ( i1(2) <= 1 ) then; do i=1,n(2); f(:,k1-i,:) = 0.; end do; end if
if ( i1(3) <= 1 ) then; do i=1,n(3); f(:,:,l1-i) = 0.; end do; end if
if ( i2(1) <= 1 ) then; do i=1,n(1); f(j2+i,:,:) = 0.; end do; end if
if ( i2(2) <= 1 ) then; do i=1,n(2); f(:,k2+i,:) = 0.; end do; end if
if ( i2(3) <= 1 ) then; do i=1,n(3); f(:,:,l2+i) = 0.; end do; end if

! Mirror on cell BC
if ( i1(1) == 2 ) then; do i=1,n(1)-c; f(j1-i-c,:,:) = f(j1+i-1,:,:); end do; end if
if ( i1(2) == 2 ) then; do i=1,n(2)-c; f(:,k1-i-c,:) = f(:,k1+i-1,:); end do; end if
if ( i1(3) == 2 ) then; do i=1,n(3)-c; f(:,:,l1-i-c) = f(:,:,l1+i-1); end do; end if
if ( i2(1) == 2 ) then; do i=1,n(1)-c; f(j2+i+c,:,:) = f(j2-i+1,:,:); end do; end if
if ( i2(2) == 2 ) then; do i=1,n(2)-c; f(:,k2+i+c,:) = f(:,k2-i+1,:); end do; end if
if ( i2(3) == 2 ) then; do i=1,n(3)-c; f(:,:,l2+i+c) = f(:,:,l2-i+1); end do; end if

! Mirror on node BC
if ( i1(1) == 3 ) then; do i=1,n(1); f(j1-i,:,:) = f(j1+i-c,:,:); end do; end if
if ( i1(2) == 3 ) then; do i=1,n(2); f(:,k1-i,:) = f(:,k1+i-c,:); end do; end if
if ( i1(3) == 3 ) then; do i=1,n(3); f(:,:,l1-i) = f(:,:,l1+i-c); end do; end if
if ( i2(1) == 3 ) then; do i=1,n(1); f(j2+i,:,:) = f(j2-i+c,:,:); end do; end if
if ( i2(2) == 3 ) then; do i=1,n(2); f(:,k2+i,:) = f(:,k2-i+c,:); end do; end if
if ( i2(3) == 3 ) then; do i=1,n(3); f(:,:,l2+i) = f(:,:,l2-i+c); end do; end if

! Continuing BC
if ( i1(1) == 4 ) then; do i=1,n(1); f(j1-i,:,:) = f(j1,:,:); end do; end if
if ( i1(2) == 4 ) then; do i=1,n(2); f(:,k1-i,:) = f(:,k1,:); end do; end if
if ( i1(3) == 4 ) then; do i=1,n(3); f(:,:,l1-i) = f(:,:,l1); end do; end if
if ( i2(1) == 4 ) then; do i=1,n(1); f(j2+i,:,:) = f(j2,:,:); end do; end if
if ( i2(2) == 4 ) then; do i=1,n(2); f(:,k2+i,:) = f(:,k2,:); end do; end if
if ( i2(3) == 4 ) then; do i=1,n(3); f(:,:,l2+i) = f(:,:,l2); end do; end if

end subroutine

subroutine vectorbc( f, ibc1, ibc2, n, tensor )
implicit none
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: ibc1(3), ibc2(3), n(3), tensor
integer :: i1(3), i2(3), nm(3), s(3), a, b, c, i, j1, k1, l1, j2, k2, l2
nm = (/ size(f,1), size(f,2), size(f,3) /)
a = -1 ! sign of normal component
b = 1  ! sign of tangential components
c = abs( tensor )
if ( tensor /= 0 ) then
  a = 1
  b = tensor
end if
i1 = 1 + n
i2 = nm - n - c
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1 = abs( ibc1 )
i2 = abs( ibc2 )
where ( nm == 1 ) i1 = 99
where ( nm == 1 ) i2 = 99

! Zero BC
if ( i1(1) <= 1 ) then; do i=1,n(1); f(j1-i,:,:,:) = 0.; end do; end if
if ( i1(2) <= 1 ) then; do i=1,n(2); f(:,k1-i,:,:) = 0.; end do; end if
if ( i1(3) <= 1 ) then; do i=1,n(3); f(:,:,l1-i,:) = 0.; end do; end if
if ( i2(1) <= 1 ) then; do i=1,n(1); f(j2+i,:,:,:) = 0.; end do; end if
if ( i2(2) <= 1 ) then; do i=1,n(2); f(:,k2+i,:,:) = 0.; end do; end if
if ( i2(3) <= 1 ) then; do i=1,n(3); f(:,:,l2+i,:) = 0.; end do; end if

! Continuing BC
if ( i1(1) == 4 ) then; do i=1,n(1); f(j1-i,:,:,:) = f(j1,:,:,:); end do; end if
if ( i1(2) == 4 ) then; do i=1,n(2); f(:,k1-i,:,:) = f(:,k1,:,:); end do; end if
if ( i1(3) == 4 ) then; do i=1,n(3); f(:,:,l1-i,:) = f(:,:,l1,:); end do; end if
if ( i2(1) == 4 ) then; do i=1,n(1); f(j2+i,:,:,:) = f(j2,:,:,:); end do; end if
if ( i2(2) == 4 ) then; do i=1,n(2); f(:,k2+i,:,:) = f(:,k2,:,:); end do; end if
if ( i2(3) == 4 ) then; do i=1,n(3); f(:,:,l2+i,:) = f(:,:,l2,:); end do; end if

! Mirror on cell BC
if ( i1(1) == 2 ) then
  s = (/ a, b, b /) * sign( 1, ibc1(1) )
  do i = 1, n(1) - c
    f(j1-i-c,:,:,1) = s(1) * f(j1+i-1,:,:,1)
    f(j1-i-c,:,:,2) = s(2) * f(j1+i-1,:,:,2)
    f(j1-i-c,:,:,3) = s(3) * f(j1+i-1,:,:,3)
  end do
end if
if ( i1(2) == 2 ) then
  s = (/ b, a, b /) * sign( 1, ibc1(2) )
  do i = 1, n(2) - c
    f(:,k1-i-c,:,1) = s(1) * f(:,k1+i-1,:,1)
    f(:,k1-i-c,:,2) = s(2) * f(:,k1+i-1,:,2)
    f(:,k1-i-c,:,3) = s(3) * f(:,k1+i-1,:,3)
  end do
end if
if ( i1(3) == 2 ) then
  s = (/ b, b, a /) * sign( 1, ibc1(3) )
  do i = 1, n(3) - c
    f(:,:,l1-i-c,1) = s(1) * f(:,:,l1+i-1,1)
    f(:,:,l1-i-c,2) = s(2) * f(:,:,l1+i-1,2)
    f(:,:,l1-i-c,3) = s(3) * f(:,:,l1+i-1,3)
  end do
end if
if ( i2(1) == 2 ) then
  s = (/ a, b, b /) * sign( 1, ibc2(1) )
  do i = 1, n(1) - c
    f(j2+i+c,:,:,1) = s(1) * f(j2-i+1,:,:,1)
    f(j2+i+c,:,:,2) = s(2) * f(j2-i+1,:,:,2)
    f(j2+i+c,:,:,3) = s(3) * f(j2-i+1,:,:,3)
  end do
end if
if ( i2(2) == 2 ) then
  s = (/ b, a, b /) * sign( 1, ibc2(2) )
  do i = 1, n(2) - c
    f(:,k2+i+c,:,1) = s(1) * f(:,k2-i+1,:,1)
    f(:,k2+i+c,:,2) = s(2) * f(:,k2-i+1,:,2)
    f(:,k2+i+c,:,3) = s(3) * f(:,k2-i+1,:,3)
  end do
end if
if ( i2(3) == 2 ) then
  s = (/ b, b, a /) * sign( 1, ibc2(3) )
  do i = 1, n(3) - c
    f(:,:,l2+i+c,1) = s(1) * f(:,:,l2-i+1,1)
    f(:,:,l2+i+c,2) = s(2) * f(:,:,l2-i+1,2)
    f(:,:,l2+i+c,3) = s(3) * f(:,:,l2-i+1,3)
  end do
end if

! Mirror on node BC
if ( i1(1) == 3 ) then
  s = (/ a, b, b /) * sign( 1, ibc1(1) )
  do i = 1, n(1)
    f(j1-i,:,:,1) = s(1) * f(j1+i-c,:,:,1)
    f(j1-i,:,:,2) = s(2) * f(j1+i-c,:,:,2)
    f(j1-i,:,:,3) = s(3) * f(j1+i-c,:,:,3)
  end do
end if
if ( i1(2) == 3 ) then
  s = (/ b, a, b /) * sign( 1, ibc1(2) )
  do i = 1, n(2)
    f(:,k1-i,:,1) = s(1) * f(:,k1+i-c,:,1)
    f(:,k1-i,:,2) = s(2) * f(:,k1+i-c,:,2)
    f(:,k1-i,:,3) = s(3) * f(:,k1+i-c,:,3)
  end do
end if
if ( i1(3) == 3 ) then
  s = (/ b, b, a /) * sign( 1, ibc1(3) )
  do i = 1, n(3)
    f(:,:,l1-i,1) = s(1) * f(:,:,l1+i-c,1)
    f(:,:,l1-i,2) = s(2) * f(:,:,l1+i-c,2)
    f(:,:,l1-i,3) = s(3) * f(:,:,l1+i-c,3)
  end do
end if
if ( i2(1) == 3 ) then
  s = (/ a, b, b /) * sign( 1, ibc2(1) )
  do i = 1, n(1)
    f(j2+i,:,:,1) = s(1) * f(j2-i+c,:,:,1)
    f(j2+i,:,:,2) = s(2) * f(j2-i+c,:,:,2)
    f(j2+i,:,:,3) = s(3) * f(j2-i+c,:,:,3)
  end do
end if
if ( i2(2) == 3 ) then
  s = (/ b, a, b /) * sign( 1, ibc2(2) )
  do i = 1, n(2)
    f(:,k2+i,:,1) = s(1) * f(:,k2-i+c,:,1)
    f(:,k2+i,:,2) = s(2) * f(:,k2-i+c,:,2)
    f(:,k2+i,:,3) = s(3) * f(:,k2-i+c,:,3)
  end do
end if
if ( i2(3) == 3 ) then
  s = (/ b, b, a /) * sign( 1, ibc2(3) )
  do i = 1, n(3)
    f(:,:,l2+i,1) = s(1) * f(:,:,l2-i+c,1)
    f(:,:,l2+i,2) = s(2) * f(:,:,l2-i+c,2)
    f(:,:,l2+i,3) = s(3) * f(:,:,l2-i+c,3)
  end do
end if

end subroutine

end module

