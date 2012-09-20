! time integration
module time_integration
implicit none
contains

subroutine step_time
use globals
use utilities
use field_io_mod
use statistics
integer :: i, j, k, l
real :: u, v

! status
if (master) then
    if (verb) then
        write (*, '(a,i6)') 'Time step', it
    else
        write (*, '(a)', advance='no') '.'
        if (modulo(it, 50) == 0 .or. it == nt) write (*, '(i6)') it
    end if
end if

! save previous slip velocity
if (ifn /= 0) then
    select case (ifn)
    case (1); t2(1,:,:,:) = vv(irup+1,:,:,:) - vv(irup,:,:,:)
    case (2); t2(:,1,:,:) = vv(:,irup+1,:,:) - vv(:,irup,:,:)
    case (3); t2(:,:,1,:) = vv(:,:,irup+1,:) - vv(:,:,irup,:)
    end select
    f2 = sqrt(sum(t2 * t2, 4))
end if

! time integration
tm = tm0 + dt * (it - 1)
do i = 1, 3
    !$omp parallel do schedule(static) private(j, k, l, u, v)
    do l = 1, nm(3)
    do k = 1, nm(2)
    do j = 1, nm(1)
        v = vv(j,k,l,i) + dt * w1(j,k,l,i)
        u = uu(j,k,l,i) + dt * v
        vv(j,k,l,i) = v
        uu(j,k,l,i) = u
        w1(j,k,l,i) = u + gam(j,k,l) * v
    end do
    end do
    end do
    !$omp end parallel do
end do

! velocity I/O
call field_io('<>', 'v1', vv(:,:,:,1))
call field_io('<>', 'v2', vv(:,:,:,2))
call field_io('<>', 'v3', vv(:,:,:,3))
if (modulo(it, itstats) == 0) then
    call vector_norm(s1, vv, i1core, i2core, (/ 1, 1, 1 /))
    call set_halo(s1, -1.0, i1core, i2core)
    vmaxloc = maxloc(s1)
    vmax = s1(vmaxloc(1),vmaxloc(2),vmaxloc(3))
end if
call field_io('>', 'vm2', s1)

! displacement I/O
call field_io('<>', 'u1', uu(:,:,:,1))
call field_io('<>', 'u2', uu(:,:,:,2))
call field_io('<>', 'u3', uu(:,:,:,3))
if (modulo(it, itstats) == 0) then
    call vector_norm(s1, uu, i1core, i2core, (/ 1, 1, 1 /))
    call set_halo(s1, -1.0, i1core, i2core)
    umaxloc = maxloc(s1)
    umax = s1(umaxloc(1),umaxloc(2),umaxloc(3))
end if
call field_io('>', 'um2', s1)

! rupture time integration
if (ifn /= 0) then
    select case (ifn)
    case (1); t1(1,:,:,:) = vv(irup+1,:,:,:) - vv(irup,:,:,:)
    case (2); t1(:,1,:,:) = vv(:,irup+1,:,:) - vv(:,irup,:,:)
    case (3); t1(:,:,1,:) = vv(:,:,irup+1,:) - vv(:,:,irup,:)
    end select
    f1 = sqrt(sum(t1 * t1, 4))
    sl = sl + dt * f1
    psv = max(psv, f1)
    if (svtol > 0.0) then
        where (f1 >= svtol .and. trup > 1e8)
            trup = tm - dt * (0.5 + (svtol - f1) / (f2 - f1))
        end where
        where (f1 >= svtol)
            tarr = 1e9
        end where
        where (f1 < svtol .and. f2 >= svtol)
            tarr = tm - dt * (0.5 + (svtol - f1) / (f2 - f1))
        end where
    end if
    select case (ifn)
    case (1); t2(1,:,:,:) = uu(irup+1,:,:,:) - uu(irup,:,:,:)
    case (2); t2(:,1,:,:) = uu(:,irup+1,:,:) - uu(:,irup,:,:)
    case (3); t2(:,:,1,:) = uu(:,:,irup+1,:) - uu(:,:,irup,:)
    end select
    f2 = sqrt(sum(t2 * t2, 4))
    call field_io('>', 'sv1',  t1(:,:,:,1))
    call field_io('>', 'sv2',  t1(:,:,:,2))
    call field_io('>', 'sv3',  t1(:,:,:,3))
    call field_io('>', 'svm',  f1)
    call field_io('>', 'psv',  psv)
    call field_io('>', 'su1',  t2(:,:,:,1))
    call field_io('>', 'su2',  t2(:,:,:,2))
    call field_io('>', 'su3',  t2(:,:,:,3))
    call field_io('>', 'sum',  f2)
    call field_io('>', 'sl',   sl)
    call field_io('>', 'trup', trup)
    call field_io('>', 'tarr', tarr)
    call set_halo(f1,   -1.0, i1core, i2core)
    call set_halo(f2,   -1.0, i1core, i2core)
    call set_halo(tarr, -1.0, i1core, i2core)
    svmax = maxval(f1)
    sumax = maxval(f2)
    slmax = maxval(sl)
    tarrmax = maxval(tarr)
end if

end subroutine
end module

