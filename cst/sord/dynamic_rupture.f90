! rupture boundary condition
module dynamic_rupture
implicit none
contains

! rupture initialization
subroutine init_rupture
use globals
use collective
use surf_normals
use utilities
use input_output
use statistics
real :: rr, xhypo(3), xi(3), w
integer :: i1(3), i2(3), i, j, k, l, root(3)

if (faultnormal == 0) return
if (sync) call barrier
if (master) print *, clock(), 'Rupture initialization'
if (ifn == 0) return

! allocate arrays
i1 = nm
i1(ifn) = 1
j = i1(1)
k = i1(2)
l = i1(3)
allocate ( &
    !ts0(j,k,l,3), & ! [ZS]
    !tp(j,k,l,3), & ! [ZS]
    !af(j,k,l), & ! [ZS]
    !bf(j,k,l), & ! [ZS]
    !v0(j,k,l), & ! [ZS]
    !f0(j,k,l), & ! [ZS]
    !ll(j,k,l), & ! [ZS]
    !fw(j,k,l), & ! [ZS]
    !vw(j,k,l), & ! [ZS]
    !psi(j,k,l), & ! [ZS]
    !svtrl(j,k,l), & ! [ZS]
    !svold(j,k,l), & ! [ZS]
    !sv0(j,k,l), & ! [ZS]
    nhat(j,k,l,3), &
    t0(j,k,l,3), &
    t1(j,k,l,3), &
    t2(j,k,l,3), &
    t3(j,k,l,3), &
    mus(j,k,l), &
    mud(j,k,l), &
    dc(j,k,l), &
    co(j,k,l), &
    area(j,k,l), &
    rhypo(j,k,l), &
    lamf(j,k,l), &
    muf(j,k,l), &
    sl(j,k,l), &
    psv(j,k,l), &
    trup(j,k,l), &
    tarr(j,k,l), &
    tn(j,k,l), &
    ts(j,k,l), &
    f1(j,k,l), &
    f2(j,k,l) &
)

! i/o
sl = 0.0
mus = 0.0
mud = 0.0
dc = 0.0
co = 0.0
t1 = 0.0
t2 = 0.0
t3 = 0.0
!f0 = 0.0 ! [ZS]
!v0 = 0.0 ! [ZS]
!fw = 0.0 ! [ZS]
!vw = 0.0 ! [ZS]
!ll = 0.0 ! [ZS]
!af = 0.0 ! [ZS]
!bf = 0.0 ! [ZS]
!psi = 0.0 ! [ZS]
call field_io('<>', 'mus', mus)
call field_io('<>', 'mud', mud)
call field_io('<>', 'dc',  dc)
call field_io('<>', 'co',  co)
call field_io('<>', 's11', t1(:,:,:,1))
call field_io('<>', 's22', t1(:,:,:,2))
call field_io('<>', 's33', t1(:,:,:,3))
call field_io('<>', 's23', t2(:,:,:,1))
call field_io('<>', 's31', t2(:,:,:,2))
call field_io('<>', 's12', t2(:,:,:,3))
call field_io('<>', 'ts',  t3(:,:,:,1))
call field_io('<>', 'td',  t3(:,:,:,2))
call field_io('<>', 'tn',  t3(:,:,:,3))
!call field_io('<>', 'f0',  f0) ! [ZS]
!call field_io('<>', 'v0',  v0) ! [ZS]
!call field_io('<>', 'fw',  fw) ! [ZS]
!call field_io('<>', 'vw',  vw) ! [ZS]
!call field_io('<>', 'll',  ll) ! [ZS]
!call field_io('<>', 'af',  af) ! [ZS]
!call field_io('<>', 'bf',  bf) ! [ZS]

! normal traction check
i1 = maxloc(t3(:,:,:,3))
rr = t3(i1(1),i1(2),i1(3),3)
i1(ifn) = irup
i1 = i1 + nnoff
if (rr > 0.0) write (0,*) 'Warning: positive normal traction: ', rr, i1

! lock fault in pml region
i1 = i1pml + 1
i2 = i2pml - 1
call set_halo(co, 1e20, i1, i2)

! normal vectors
i1 = i1core
i2 = i2core
i1(ifn) = irup
i2(ifn) = irup
call node_normals(nhat, w1, dx, i1, i2, ifn)
area = sign(1, faultnormal) * sqrt(sum(nhat * nhat, 4))
f1 = area
call rinvert(f1, size(f1))
do i = 1, 3
    nhat(:,:,:,i) = nhat(:,:,:,i) * f1
end do
call scalar_swap_halo(area,  nhalo)
call vector_swap_halo(nhat,  nhalo)
call field_io('>', 'nhat1', nhat(:,:,:,1))
call field_io('>', 'nhat2', nhat(:,:,:,2))
call field_io('>', 'nhat3', nhat(:,:,:,3))

! resolve prestress onto fault
do i = 1, 3
    j = modulo(i, 3) + 1
    k = modulo(i + 1, 3) + 1
    t0(:,:,:,i) = &
        t1(:,:,:,i) * nhat(:,:,:,i) + &
        t2(:,:,:,j) * nhat(:,:,:,k) + &
        t2(:,:,:,k) * nhat(:,:,:,j)
end do

! Ts2 vector
t2(:,:,:,1) = nhat(:,:,:,2) * slipvector(3) - nhat(:,:,:,3) * slipvector(2)
t2(:,:,:,2) = nhat(:,:,:,3) * slipvector(1) - nhat(:,:,:,1) * slipvector(3)
t2(:,:,:,3) = nhat(:,:,:,1) * slipvector(2) - nhat(:,:,:,2) * slipvector(1)
f1 = sqrt(sum(t2 * t2, 4))
call rinvert(f1, size(f1))
do i = 1, 3
    t2(:,:,:,i) = t2(:,:,:,i) * f1
end do

! Ts1 vector
t1(:,:,:,1) = t2(:,:,:,2) * nhat(:,:,:,3) - t2(:,:,:,3) * nhat(:,:,:,2)
t1(:,:,:,2) = t2(:,:,:,3) * nhat(:,:,:,1) - t2(:,:,:,1) * nhat(:,:,:,3)
t1(:,:,:,3) = t2(:,:,:,1) * nhat(:,:,:,2) - t2(:,:,:,2) * nhat(:,:,:,1)
f1 = sqrt(sum(t1 * t1, 4))
call rinvert(f1, size(f1))
do i = 1, 3
    t1(:,:,:,i) = t1(:,:,:,i) * f1
end do

! total pretraction
do i = 1, 3
    t0(:,:,:,i) = t0(:,:,:,i) + &
        t3(:,:,:,1) * t1(:,:,:,i) + &
        t3(:,:,:,2) * t2(:,:,:,i) + &
        t3(:,:,:,3) * nhat(:,:,:,i)
end do

! hypocentral radius needed if doing nucleation
if (rcrit > 0.0 .and. vrup > 0.0) then
    xhypo = 0.0
    xi = ihypo - nnoff
    i1 = floor(xi)
    if (all(i1 >= 1 .and. i1 < nm)) then
        do l = i1(3), i1(3)+1
        do k = i1(2), i1(2)+1
        do j = i1(1), i1(1)+1
            w = (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l))
            do i = 1, 3
                xhypo(i) = xhypo(i) + w * w1(j,k,l,i)
            end do
        end do
        end do
        end do
    end if
    root = ip3hypo
    root(ifn) = -1
    call rbroadcast1(xhypo, root)
    do i = 1, 3
        select case (ifn)
        case (1); t2(1,:,:,i) = w1(irup,:,:,i) - xhypo(i)
        case (2); t2(:,1,:,i) = w1(:,irup,:,i) - xhypo(i)
        case (3); t2(:,:,1,i) = w1(:,:,irup,i) - xhypo(i)
        end select
    end do
    rhypo = sqrt(sum(t2 * t2, 4))
end if

! resample mu on to fault plane nodes for moment calculatioin
select case (ifn)
case (1); lamf(1,:,:) = lam(irup,:,:); muf(1,:,:) = mu(irup,:,:)
case (2); lamf(:,1,:) = lam(:,irup,:); muf(:,1,:) = mu(:,irup,:)
case (3); lamf(:,:,1) = lam(:,:,irup); muf(:,:,1) = mu(:,:,irup)
end select
call rinvert(lamf, size(lamf))
call rinvert(muf, size(muf))
j = nm(1) - 1
k = nm(2) - 1
l = nm(3) - 1
if (ifn /= 1) lamf(2:j,:,:) = 0.5 * (lamf(2:j,:,:) + lamf(1:j-1,:,:))
if (ifn /= 2) lamf(:,2:k,:) = 0.5 * (lamf(:,2:k,:) + lamf(:,1:k-1,:))
if (ifn /= 3) lamf(:,:,2:l) = 0.5 * (lamf(:,:,2:l) + lamf(:,:,1:l-1))
if (ifn /= 1) muf(2:j,:,:) = 0.5 * (muf(2:j,:,:) + muf(1:j-1,:,:))
if (ifn /= 2) muf(:,2:k,:) = 0.5 * (muf(:,2:k,:) + muf(:,1:k-1,:))
if (ifn /= 3) muf(:,:,2:l) = 0.5 * (muf(:,:,2:l) + muf(:,:,1:l-1))
call rinvert(muf, size(muf))

! initial state, can be overwritten by read_checkpoint
psv   =  0.0
trup  =  1e9
tarr  =  0.0
efric =  0.0

! halos (this shoud be handled by field_io now)
!call scalar_swap_halo(mus,   nhalo)
!call scalar_swap_halo(mud,   nhalo)
!call scalar_swap_halo(dc,    nhalo)
!call scalar_swap_halo(co,    nhalo)
!call vector_swap_halo(t0,    nhalo)
!call scalar_swap_halo(rhypo, nhalo)

end subroutine

!------------------------------------------------------------------------------!

! rupture boundary condition
subroutine step_rupture
use globals
use collective
use boundary_cond
use utilities
use input_output
use statistics
integer :: i1(3), i2(3), i, j1, k1, l1, j2, k2, l2, j3, k3, l3, j4, k4, l4

if (ifn == 0) return

! indices
i1 = 1
i2 = nm
i1(ifn) = irup
i2(ifn) = irup
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(ifn) = irup + 1
i2(ifn) = irup + 1
j3 = i1(1); j4 = i2(1)
k3 = i1(2); k4 = i2(2)
l3 = i1(3); l4 = i2(3)

! trial traction for zero velocity and zero displacement
f1 = dt * dt * area * (mr(j1:j2,k1:k2,l1:l2) + mr(j3:j4,k3:k4,l3:l4))
call rinvert(f1, size(f1))
do i = 1, 3
    t1(:,:,:,i) = t0(:,:,:,i) + f1 * dt * &
        ( vv(j3:j4,k3:k4,l3:l4,i) &
        - vv(j1:j2,k1:k2,l1:l2,i) &
        + w1(j3:j4,k3:k4,l3:l4,i) * mr(j3:j4,k3:k4,l3:l4) * dt &
        - w1(j1:j2,k1:k2,l1:l2,i) * mr(j1:j2,k1:k2,l1:l2) * dt )
    t2(:,:,:,i) = t1(:,:,:,i) + f1 * &
        (uu(j3:j4,k3:k4,l3:l4,i) - uu(j1:j2,k1:k2,l1:l2,i))
end do

! shear and normal traction
tn = sum(t1 * nhat, 4)
do i = 1, 3
    t3(:,:,:,i) = t1(:,:,:,i) - tn * nhat(:,:,:,i)
end do
ts = sqrt(sum(t3 * t3, 4))

! delay slip till after first iteration
if (it > 1) then

    ! normal traction
    tn = sum(t2 * nhat, 4)
    if (faultopening == 1) tn = min(0.0, tn)

    ! slip velocity
    do i = 1, 3
        t2(:,:,:,i) = vv(j3:j4,k3:k4,l3:l4,i) - vv(j1:j2,k1:k2,l1:l2,i)
    end do
    f2 = sum(t2 * t2, 4)

    ! slip-weakening friction law
    f1 = mud
    where (sl < dc) f1 = f1 + (1.0 - sl / dc) * (mus - mud)
    f1 = -min(0.0, tn) * f1 + co

    ! nucleation
    if (rcrit > 0.0 .and. vrup > 0.0) then
        f2 = 1.0
        if (trelax > 0.0) f2 = min((tm - rhypo / vrup) / trelax, 1.0)
        f2 = (1.0 - f2) * ts + f2 * (-tn * mud + co)
        where (rhypo < min(rcrit, tm * vrup) .and. f2 < f1) f1 = f2
    end if

    ! shear traction bounded by friction
    f2 = 1.0
    where (ts > f1) f2 = f1 / ts
    do i = 1, 3
        t3(:,:,:,i) = f2 * t3(:,:,:,i)
    end do
    ts = min(ts, f1)

    ! total traction
    do i = 1, 3
        t1(:,:,:,i) = t3(:,:,:,i) + tn * nhat(:,:,:,i)
    end do

end if

! update acceleration
do i = 1, 3
    f2 = area * (t1(:,:,:,i) - t0(:,:,:,i))
    w1(j1:j2,k1:k2,l1:l2,i) = w1(j1:j2,k1:k2,l1:l2,i) + f2
    w1(j3:j4,k3:k4,l3:l4,i) = w1(j3:j4,k3:k4,l3:l4,i) - f2
end do
call vector_bc(w1, bc1, bc2, i1bc, i2bc)

! output
!call field_io('>', 'psi', psi) ! [ZS]
call field_io('>', 't1',  t1(:,:,:,1))
call field_io('>', 't2',  t1(:,:,:,2))
call field_io('>', 't3',  t1(:,:,:,3))
call field_io('>', 'ts1', t3(:,:,:,1))
call field_io('>', 'ts2', t3(:,:,:,2))
call field_io('>', 'ts3', t3(:,:,:,3))
call field_io('>', 'tsm', ts)
call field_io('>', 'tnm', tn)
call field_io('>', 'fr',  f1)
call set_halo(ts,      -1.0, i1core, i2core); tsmax = maxval(ts)
call set_halo(tn,  huge(dt), i1core, i2core); tnmin = minval(tn)
call set_halo(tn, -huge(dt), i1core, i2core); tnmax = maxval(tn)
call set_halo(tn,       0.0, i1core, i2core)

! friction + fracture energy
t2 = vv(j3:j4,k3:k4,l3:l4,:) - vv(j1:j2,k1:k2,l1:l2,:)
f2 = sum(t1 * t2, 4) * area
call set_halo(f2, 0.0, i1core, i2core)
efric = efric + dt * sum(f2)

! strain energy
t2 = uu(j3:j4,k3:k4,l3:l4,:) - uu(j1:j2,k1:k2,l1:l2,:)
f2 = sum((t0 + t1) * t2, 4) * area
call set_halo(f2, 0.0, i1core, i2core)
estrain = 0.5 * sum(f2)

! moment (negelcts opening lambda contribution)
f2 = muf * area * sqrt(sum(t2 * t2, 4))
call set_halo(f2, 0.0, i1core, i2core)
moment = sum(f2)

! slip acceleration
do i = 1, 3
    t2(:,:,:,i) = &
        w1(j3:j4,k3:k4,l3:l4,i) * mr(j3:j4,k3:k4,l3:l4) - &
        w1(j1:j2,k1:k2,l1:l2,i) * mr(j1:j2,k1:k2,l1:l2)
end do
f2 = sqrt(sum(t2 * t2, 4))
call field_io('>', 'sa1', t2(:,:,:,1))
call field_io('>', 'sa2', t2(:,:,:,2))
call field_io('>', 'sa3', t2(:,:,:,3))
call field_io('>', 'sam', f2)
call set_halo(f2, -1.0, i1core, i2core)
samax = maxval(f2)

end subroutine

end module

