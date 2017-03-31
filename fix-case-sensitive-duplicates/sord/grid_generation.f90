! grid generation
module grid_generation
implicit none
contains

subroutine init_grid
use globals
use process
use boundary_cond
use utilities
use diff_nc_op
use surf_normals
use input_output
integer :: i1(3), i2(3), i3(3), i4(3), bc(3), i, j, k, l
real :: m(9), x, y, z
logical :: err

if (sync) call barrier
if (master) print *, clock(), 'Grid generation'

! create rectangular mesh with double nodes at the fault
xx = 0.0
i1 = i1node
i2 = i2node
do i = i1(1), i2(1); xx(i,:,:,1) = dx(1) * (i + nnoff(1) - 1); end do
do i = i1(2), i2(2); xx(:,i,:,2) = dx(2) * (i + nnoff(2) - 1); end do
do i = i1(3), i2(3); xx(:,:,i,3) = dx(3) * (i + nnoff(3) - 1); end do
i1 = max(i1core, irup + 1)
select case (faultnormal(2:2))
case ('x'); do i = i1(1), i2(1); xx(i,:,:,1) = dx(1) * (i + nnoff(1) - 2); end do
case ('y'); do i = i1(2), i2(2); xx(:,i,:,2) = dx(2) * (i + nnoff(2) - 2); end do
case ('z'); do i = i1(3), i2(3); xx(:,:,i,3) = dx(3) * (i + nnoff(3) - 2); end do
end select

! read grid
call field_io('<', 'x', xx(:,:,:,1))
call field_io('<', 'y', xx(:,:,:,2))
call field_io('<', 'z', xx(:,:,:,3))

! add random noise except at boundaries and in pml
if (gridnoise > 0.0) then
    call random_number(w1)
    w1 = sqrt(sum(dx * dx)) * gridnoise * (w1 - 0.5)
    i1 = i1pml + 1
    i2 = i2pml - 1
    call set_halo(w1(:,:,:,1), 0.0, i1, i2)
    call set_halo(w1(:,:,:,2), 0.0, i1, i2)
    call set_halo(w1(:,:,:,3), 0.0, i1, i2)
    i1 = i1bc + 1
    i2 = i2bc - 1
    call set_halo(w1(:,:,:,1), 0.0, i1, i2)
    call set_halo(w1(:,:,:,2), 0.0, i1, i2)
    call set_halo(w1(:,:,:,3), 0.0, i1, i2)
    i1 = max(i1core, irup)
    i2 = min(i2core, irup + 1)
    select case (faultnormal(2:2))
    case ('x'); w1(i1(1):i2(1),:,:,:) = 0.0
    case ('y'); w1(:,i1(2):i2(2),:,:) = 0.0
    case ('z'); w1(:,:,i1(3):i2(3),:) = 0.0
    end select
    xx = xx + w1
end if

! grid expansion
if (rexpand > 1.0) then
    i1 = n1expand - nnoff
    i2 = nn - n2expand + 1 - nnoff
    i3 = i1node
    i4 = i2node
    do j = i3(1), min(i4(1), i1(1))
        i = i1(1) - j
        xx(j,:,:,1) = xx(j,:,:,1) + &
            dx(1) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do j = max(i3(1), i2(1)), i4(1)
        i = j - i2(1)
        xx(j,:,:,1) = xx(j,:,:,1) - &
            dx(1) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do k = i3(2), min(i4(2), i1(2))
        i = i1(2) - k
        xx(:,k,:,2) = xx(:,k,:,2) + &
            dx(2) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do k = max(i3(2), i2(2)), i4(2)
        i = k - i2(2)
        xx(:,k,:,2) = xx(:,k,:,2) - &
            dx(2) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do l = i3(3), min(i4(3), i1(3))
        i = i1(3) - l
        xx(:,:,l,3) = xx(:,:,l,3) + &
            dx(3) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
    do l = max(i3(3), i2(3)), i4(3)
        i = l - i2(3)
        xx(:,:,l,3) = xx(:,:,l,3) - &
            dx(3) * (i + 1 - (rexpand ** (i + 1) - 1) / (rexpand - 1))
    end do
end if

! affine grid transformation
m = affine
!$omp parallel do schedule(static) private(j, k, l)
do l = 1, nm(3)
do k = 1, nm(2)
do j = 1, nm(1)
    x = m(1) * xx(j,k,l,1) + m(2) * xx(j,k,l,2) + m(3) * xx(j,k,l,3)
    y = m(4) * xx(j,k,l,1) + m(5) * xx(j,k,l,2) + m(6) * xx(j,k,l,3)
    z = m(7) * xx(j,k,l,1) + m(8) * xx(j,k,l,2) + m(9) * xx(j,k,l,3)
    xx(j,k,l,1) = x
    xx(j,k,l,2) = y
    xx(j,k,l,3) = z
end do
end do
end do
!$omp end parallel do

! fill halo, bc=4 means copy into halo, need this for nhat
bc = 4
i1 = i1bc - 1
i2 = i2bc + 1
!call vector_swap_halo(xx, nhalo) ! this should be handled in field_io now
call vector_bc(xx, bc, bc, i1, i2)

! cell centers
call average(w1(:,:,:,1), xx(:,:,:,1), i1cell, i2cell, 1)
call average(w1(:,:,:,2), xx(:,:,:,2), i1cell, i2cell, 1)
call average(w1(:,:,:,3), xx(:,:,:,3), i1cell, i2cell, 1)
call set_halo(w1(:,:,:,1), 0.0, i1cell, i2cell)
call set_halo(w1(:,:,:,2), 0.0, i1cell, i2cell)
call set_halo(w1(:,:,:,3), 0.0, i1cell, i2cell)

! output
call field_io('>', 'x', xx(:,:,:,1))
call field_io('>', 'y', xx(:,:,:,2))
call field_io('>', 'z', xx(:,:,:,3))
call field_io('>', 'xc', w1(:,:,:,1))
call field_io('>', 'yc', w1(:,:,:,2))
call field_io('>', 'zc', w1(:,:,:,3))

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
!    call nodenormals(pn1, xx, dx, i1, i2, 1)
!    i1 = i1cell
!    i2 = i2cell
!    i2(1) = i1(1)
!    call cellnormals(gn1, xx, dx, i1, i2, 1)
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
!    call nodenormals(pn4, xx, dx, i1, i2, 1)
!    i1 = i1cell
!    i2 = i2cell
!    i1(1) = i2(1)
!    call cellnormals(gn4, xx, dx, i1, i2, 1)
!    if (nl3(1) < npml) then
!        root = (/np3(1), -1, -1/)
!        call rbroadcast4(pn4, root)
!        call rbroadcast4(gn4, root)
!    end if
!end if

! cell volume
call set_halo(vc, 0.0, i1cell, i2cell)
do i = 1, 3
    call diff_nc(vc, xx, i, i, i1cell, i2cell, xx, dx)
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

