! grid generation
module grid_generation
implicit none
contains

subroutine init_grid
use globals
use collective
use boundary_cond
use utilities
use diff_nc_op
use surf_normals
use input_output
integer :: i1(3), i2(3), i3(3), i4(3), bc(3), &
    i, j, k, l, j1, k1, l1, j2, k2, l2, b, c
real :: m(9), tol, h
logical :: err

if (sync) call barrier
if (master) print *, clock(), 'Grid generation'

! create rectangular mesh with double nodes at the fault
w1 = 0.0
i1 = i1node
i2 = i2node
do i = i1(1), i2(1); w1(i,:,:,1) = dx(1) * (i + nnoff(1) - 1); end do
do i = i1(2), i2(2); w1(:,i,:,2) = dx(2) * (i + nnoff(2) - 1); end do
do i = i1(3), i2(3); w1(:,:,i,3) = dx(3) * (i + nnoff(3) - 1); end do
i1 = max(i1core, irup + 1)
select case (faultnormal(2:2))
case ('x'); do i = i1(1), i2(1); w1(i,:,:,1) = dx(1) * (i + nnoff(1) - 2); end do
case ('y'); do i = i1(2), i2(2); w1(:,i,:,2) = dx(2) * (i + nnoff(2) - 2); end do
case ('z'); do i = i1(3), i2(3); w1(:,:,i,3) = dx(3) * (i + nnoff(3) - 2); end do
end select

! read grid
call field_io('<', 'x', w1(:,:,:,1))
call field_io('<', 'y', w1(:,:,:,2))
call field_io('<', 'z', w1(:,:,:,3))

! add random noise except at boundaries and in pml
if (gridnoise > 0.0) then
    call random_number(w2)
    w2 = sqrt(sum(dx * dx)) * gridnoise * (w2 - 0.5)
    i1 = i1pml + 1
    i2 = i2pml - 1
    call set_halo(w2(:,:,:,1), 0.0, i1, i2)
    call set_halo(w2(:,:,:,2), 0.0, i1, i2)
    call set_halo(w2(:,:,:,3), 0.0, i1, i2)
    i1 = i1bc + 1
    i2 = i2bc - 1
    call set_halo(w2(:,:,:,1), 0.0, i1, i2)
    call set_halo(w2(:,:,:,2), 0.0, i1, i2)
    call set_halo(w2(:,:,:,3), 0.0, i1, i2)
    i1 = max(i1core, irup)
    i2 = min(i2core, irup + 1)
    select case (faultnormal(2:2))
    case ('x'); w2(i1(1):i2(1),:,:,:) = 0.0
    case ('y'); w2(:,i1(2):i2(2),:,:) = 0.0
    case ('z'); w2(:,:,i1(3):i2(3),:) = 0.0
    end select
    w1 = w1 + w2
end if

! grid expansion
if (rexpand > 1.0) then
    i1 = n1expand - nnoff
    i2 = nn - n2expand + 1 - nnoff
    i3 = i1node
    i4 = i2node
    do j = i3(1), min(i4(1), i1(1))
        i = i1(1) - j
        w1(j,:,:,1) = w1(j,:,:,1) + &
            dx(1) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do j = max(i3(1), i2(1)), i4(1)
        i = j - i2(1)
        w1(j,:,:,1) = w1(j,:,:,1) - &
            dx(1) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do k = i3(2), min(i4(2), i1(2))
        i = i1(2) - k
        w1(:,k,:,2) = w1(:,k,:,2) + &
            dx(2) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do k = max(i3(2), i2(2)), i4(2)
        i = k - i2(2)
        w1(:,k,:,2) = w1(:,k,:,2) - &
            dx(2) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do l = i3(3), min(i4(3), i1(3))
        i = i1(3) - l
        w1(:,:,l,3) = w1(:,:,l,3) + &
            dx(3) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do l = max(i3(3), i2(3)), i4(3)
        i = l - i2(3)
        w1(:,:,l,3) = w1(:,:,l,3) - &
            dx(3) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
end if

! affine grid transformation
m = affine
!$omp parallel do schedule(static) private(j, k, l)
do l = 1, nm(3)
do k = 1, nm(2)
do j = 1, nm(1)
    w2(j,k,l,1) = m(1) * w1(j,k,l,1) + m(2) * w1(j,k,l,2) + m(3) * w1(j,k,l,3)
    w2(j,k,l,2) = m(4) * w1(j,k,l,1) + m(5) * w1(j,k,l,2) + m(6) * w1(j,k,l,3)
    w2(j,k,l,3) = m(7) * w1(j,k,l,1) + m(8) * w1(j,k,l,2) + m(9) * w1(j,k,l,3)
end do
end do
end do
!$omp end parallel do
w1 = w2

! fill halo, bc=4 means copy into halo, need this for nhat
bc = 4
i1 = i1bc - 1
i2 = i2bc + 1
!call vector_swap_halo(w1, nhalo) ! this should be handled in field_io now
call vector_bc(w1, bc, bc, i1, i2)

! cell centers
call average(w2(:,:,:,1), w1(:,:,:,1), i1cell, i2cell, 1)
call average(w2(:,:,:,2), w1(:,:,:,2), i1cell, i2cell, 1)
call average(w2(:,:,:,3), w1(:,:,:,3), i1cell, i2cell, 1)
call set_halo(w2(:,:,:,1), 0.0, i1cell, i2cell)
call set_halo(w2(:,:,:,2), 0.0, i1cell, i2cell)
call set_halo(w2(:,:,:,3), 0.0, i1cell, i2cell)

! output
call field_io('>', 'x', w1(:,:,:,1))
call field_io('>', 'y', w1(:,:,:,2))
call field_io('>', 'z', w1(:,:,:,3))
call field_io('>', 'xc', w2(:,:,:,1))
call field_io('>', 'yc', w2(:,:,:,2))
call field_io('>', 'zc', w2(:,:,:,3))

! boundary surface normals
!j = nm(1)
!k = nm(2)
!l = nm(3)
!if (bc1(1) == 10) then
!    allocate (pn1(1,k,l,3), gn1(1,k,l,3))
!    pn1 = 0.0
!    gn1 = 0.0
!    i1 = i1node
!    i2 = i2node
!    i2(1) = i1(1)
!    call nodenormals(pn1, w1, dx, i1, i2, 1)
!    i1 = i1cell
!    i2 = i2cell
!    i2(1) = i1(1)
!    call cellnormals(gn1, w1, dx, i1, i2, 1)
!    if (nl3(1) < npml) then
!        root = (/0, -1, -1/)
!        call rbroadcast4(pn1, root)
!        call rbroadcast4(gn1, root)
!    end if
!end if
!if (bc2(1) == 10) then
!    allocate (pn4(1,k,l,3), gn4(1,k,l,3))
!    pn4 = 0.0
!    gn4 = 0.0
!    i1 = i1node
!    i2 = i2node
!    i1(1) = i2(1)
!    call nodenormals(pn4, w1, dx, i1, i2, 1)
!    i1 = i1cell
!    i2 = i2cell
!    i1(1) = i2(1)
!    call cellnormals(gn4, w1, dx, i1, i2, 1)
!    if (nl3(1) < npml) then
!        root = (/np3(1), -1, -1/)
!        call rbroadcast4(pn4, root)
!        call rbroadcast4(gn4, root)
!    end if
!end if

! orthogonality test
if (diffop == 'auto') then
    diffop = 'save'
    tol = 10.0 * epsilon(tol)
    j1 = i1cell(1); j2 = i2cell(1)
    k1 = i1cell(2); k2 = i2cell(2)
    l1 = i1cell(3); l2 = i2cell(3)
    if (&
    sum(abs(w1(j1+1:j2+1,:,:,2) - w1(j1:j2,:,:,2))) < tol .and. &
    sum(abs(w1(j1+1:j2+1,:,:,3) - w1(j1:j2,:,:,3))) < tol .and. &
    sum(abs(w1(:,k1+1:k2+1,:,3) - w1(:,k1:k2,:,3))) < tol .and. &
    sum(abs(w1(:,k1+1:k2+1,:,1) - w1(:,k1:k2,:,1))) < tol .and. &
    sum(abs(w1(:,:,l1+1:l2+1,1) - w1(:,:,l1:l2,1))) < tol .and. &
    sum(abs(w1(:,:,l1+1:l2+1,2) - w1(:,:,l1:l2,2))) < tol) diffop = 'rect'
end if

! operators
select case (diffop)
case ('cons')
case ('rect')
    allocate (dx1(nm(1)), dx2(nm(2)), dx3(nm(3)))
    do i = 1, nm(1)-1; dx1(i) = w1(i+1,3,3,1) - w1(i,3,3,1); end do
    do i = 1, nm(2)-1; dx2(i) = w1(3,i+1,3,2) - w1(3,i,3,2); end do
    do i = 1, nm(3)-1; dx3(i) = w1(3,3,i+1,3) - w1(3,3,i,3); end do
case ('para', 'quad', 'exac')
    allocate (xx(nm(1),nm(2),nm(3),3))
    xx = w1
case ('save')
    allocate (bb(nm(1),nm(2),nm(3),8,3))
    do i = 1, 3
    h = sign(1.0 / 12.0, product(dx))
    b = modulo(i, 3) + 1
    c = modulo(i + 1, 3) + 1
    !$omp parallel do schedule(static) private(j, k, l)
    do l = 1, nm(3)-1
    do k = 1, nm(2)-1
    do j = 1, nm(1)-1
    bb(j,k,l,1,i) = h * &
    ( (w1(j+1,k,l,b) - w1(j,k+1,l+1,b)) * (w1(j+1,k+1,l,c) - w1(j+1,k,l+1,c)) + w1(j,k+1,l+1,b) * (w1(j,k,l+1,c) - w1(j,k+1,l,c)) &
    + (w1(j,k+1,l,b) - w1(j+1,k,l+1,b)) * (w1(j,k+1,l+1,c) - w1(j+1,k+1,l,c)) + w1(j+1,k,l+1,b) * (w1(j+1,k,l,c) - w1(j,k,l+1,c)) &
    + (w1(j,k,l+1,b) - w1(j+1,k+1,l,b)) * (w1(j+1,k,l+1,c) - w1(j,k+1,l+1,c)) + w1(j+1,k+1,l,b) * (w1(j,k+1,l,c) - w1(j+1,k,l,c)) )
    bb(j,k,l,2,i) = h * &
    ( (w1(j+1,k+1,l+1,b) - w1(j,k,l,b)) * (w1(j+1,k,l+1,c) - w1(j+1,k+1,l,c)) + w1(j,k,l,b) * (w1(j,k+1,l,c) - w1(j,k,l+1,c)) &
    + (w1(j,k+1,l,b) - w1(j+1,k,l+1,b)) * (w1(j+1,k+1,l,c) - w1(j,k,l,c)) + w1(j+1,k,l+1,b) * (w1(j,k,l+1,c) - w1(j+1,k+1,l+1,c)) &
    + (w1(j,k,l+1,b) - w1(j+1,k+1,l,b)) * (w1(j,k,l,c) - w1(j+1,k,l+1,c)) + w1(j+1,k+1,l,b) * (w1(j+1,k+1,l+1,c) - w1(j,k+1,l,c)) )
    bb(j,k,l,3,i) = h * &
    ( (w1(j+1,k+1,l+1,b) - w1(j,k,l,b)) * (w1(j+1,k+1,l,c) - w1(j,k+1,l+1,c)) + w1(j,k,l,b) * (w1(j,k,l+1,c) - w1(j+1,k,l,c)) &
    + (w1(j+1,k,l,b) - w1(j,k+1,l+1,b)) * (w1(j,k,l,c) - w1(j+1,k+1,l,c)) + w1(j,k+1,l+1,b) * (w1(j+1,k+1,l+1,c) - w1(j,k,l+1,c)) &
    + (w1(j,k,l+1,b) - w1(j+1,k+1,l,b)) * (w1(j,k+1,l+1,c) - w1(j,k,l,c)) + w1(j+1,k+1,l,b) * (w1(j+1,k,l,c) - w1(j+1,k+1,l+1,c)) )
    bb(j,k,l,4,i) = h * &
    ( (w1(j+1,k+1,l+1,b) - w1(j,k,l,b)) * (w1(j,k+1,l+1,c) - w1(j+1,k,l+1,c)) + w1(j,k,l,b) * (w1(j+1,k,l,c) - w1(j,k+1,l,c)) &
    + (w1(j+1,k,l,b) - w1(j,k+1,l+1,b)) * (w1(j+1,k,l+1,c) - w1(j,k,l,c)) + w1(j,k+1,l+1,b) * (w1(j,k+1,l,c) - w1(j+1,k+1,l+1,c)) &
    + (w1(j,k+1,l,b) - w1(j+1,k,l+1,b)) * (w1(j,k,l,c) - w1(j,k+1,l+1,c)) + w1(j+1,k,l+1,b) * (w1(j+1,k+1,l+1,c) - w1(j+1,k,l,c)) )
    bb(j,k,l,5,i) = h * &
    ( (w1(j,k+1,l+1,b) - w1(j+1,k,l,b)) * (w1(j,k+1,l,c) - w1(j,k,l+1,c)) + w1(j+1,k,l,b) * (w1(j+1,k,l+1,c) - w1(j+1,k+1,l,c)) &
    + (w1(j+1,k,l+1,b) - w1(j,k+1,l,b)) * (w1(j,k,l+1,c) - w1(j+1,k,l,c)) + w1(j,k+1,l,b) * (w1(j+1,k+1,l,c) - w1(j,k+1,l+1,c)) &
    + (w1(j+1,k+1,l,b) - w1(j,k,l+1,b)) * (w1(j+1,k,l,c) - w1(j,k+1,l,c)) + w1(j,k,l+1,b) * (w1(j,k+1,l+1,c) - w1(j+1,k,l+1,c)) )
    bb(j,k,l,6,i) = h * &
    ( (w1(j,k,l,b) - w1(j+1,k+1,l+1,b)) * (w1(j,k,l+1,c) - w1(j,k+1,l,c)) + w1(j+1,k+1,l+1,b) * (w1(j+1,k+1,l,c) - w1(j+1,k,l+1,c))&
    + (w1(j+1,k,l+1,b) - w1(j,k+1,l,b)) * (w1(j+1,k+1,l+1,c) - w1(j,k,l+1,c)) + w1(j,k+1,l,b) * (w1(j,k,l,c) - w1(j+1,k+1,l,c)) &
    + (w1(j+1,k+1,l,b) - w1(j,k,l+1,b)) * (w1(j,k+1,l,c) - w1(j+1,k+1,l+1,c)) + w1(j,k,l+1,b) * (w1(j+1,k,l+1,c) - w1(j,k,l,c)) )
    bb(j,k,l,7,i) = h * &
    ( (w1(j,k,l,b) - w1(j+1,k+1,l+1,b)) * (w1(j+1,k,l,c) - w1(j,k,l+1,c)) + w1(j+1,k+1,l+1,b) * (w1(j,k+1,l+1,c) - w1(j+1,k+1,l,c))&
    + (w1(j,k+1,l+1,b) - w1(j+1,k,l,b)) * (w1(j,k,l+1,c) - w1(j+1,k+1,l+1,c)) + w1(j+1,k,l,b) * (w1(j+1,k+1,l,c) - w1(j,k,l,c)) &
    + (w1(j+1,k+1,l,b) - w1(j,k,l+1,b)) * (w1(j+1,k+1,l+1,c) - w1(j+1,k,l,c)) + w1(j,k,l+1,b) * (w1(j,k,l,c) - w1(j,k+1,l+1,c)) )
    bb(j,k,l,8,i) = h * &
    ( (w1(j,k,l,b) - w1(j+1,k+1,l+1,b)) * (w1(j,k+1,l,c) - w1(j+1,k,l,c)) + w1(j+1,k+1,l+1,b) * (w1(j+1,k,l+1,c) - w1(j,k+1,l+1,c))&
    + (w1(j,k+1,l+1,b) - w1(j+1,k,l,b)) * (w1(j+1,k+1,l+1,c) - w1(j,k+1,l,c)) + w1(j+1,k,l,b) * (w1(j,k,l,c) - w1(j+1,k,l+1,c)) &
    + (w1(j+1,k,l+1,b) - w1(j,k+1,l,b)) * (w1(j+1,k,l,c) - w1(j+1,k+1,l+1,c)) + w1(j,k+1,l,b) * (w1(j,k+1,l+1,c) - w1(j,k,l,c)) )
    end do
    end do
    end do
    !$omp end parallel do
    end do
case default; stop 'illegal operator'
end select

! cell volume
call set_halo(vc, 0.0, i1cell, i2cell)
do i = 1, 3
    call diff_nc(vc, w1, i, i, i1cell, i2cell, diffop, bb, xx, dx1, dx2, dx3, dx)
    select case (ifn)
    case (1); vc(irup,:,:) = 0.0
    case (2); vc(:,irup,:) = 0.0
    case (3); vc(:,:,irup) = 0.0
    end select
    err = minval(vc) < 0.0
end do
call field_io('>', 'vc', vc)
if (err) then
    write (0,*) 'Negative cell volume. Wrong sign in dx or problem with mesh.'
    stop
end if

end subroutine

end module

