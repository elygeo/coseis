! stress calculation
module stress
implicit none
contains

subroutine step_stress
use globals
use diff_nc_op
use kinematic_source
use utilities
use kernels
use field_io_mod
use statistics
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id, p, nm3, nm4,ii
real :: temp

if (verb) write (*, '(a)') 'Stress'

! loop over component and derivative direction
call set_halo(s1          , 0.0, i1cell, i2cell)
call set_halo(ws1(:,:,:,1), 0.0, i1cell, i2cell)
call set_halo(ws1(:,:,:,2), 0.0, i1cell, i2cell)
call set_halo(ws1(:,:,:,3), 0.0, i1cell, i2cell)

doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo(ic + iid - 1, 3) + 1

! elastic region: g_ij = (u_i + gamma*v_i),j
i1 = max(i1pml + 1, i1cell)
i2 = min(i2pml - 2, i2cell)

! ##########################################################################################
if (ic < id) then
ii = 6 - ic - id
call diff_nc_scale_p5(s1,w2(:,:,:,ii), w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)

! pml region, non-damped directions: g_ij = u_i,j
do i = 1, 3
if (id /= i) then
    i1 = i1cell
    i2 = i2cell
    i2(i) = min(i2(i), i1pml(i))
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    i1 = i1cell
    i2 = i2cell
    i1(i) = max(i1(i), i2pml(i) - 1)
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
end if
end do

! pml region, damped direction: g'_ij = d_j*g_ij = v_i,j
select case (id)
case (1)
    i1 = i1cell
    i2 = i2cell
    i2(1) = min(i2(1), i1pml(1))
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = j - i1(1) + 1
        p = j + nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g1(i,k,l,ic)
            g1(i,k,l,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(1) = max(i1(1), i2pml(1) - 1)
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = i2(1) - j + 1
        p = nn(1) - j - nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g4(i,k,l,ic)
            g4(i,k,l,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
case (2)
    i1 = i1cell
    i2 = i2cell
    i2(2) = min(i2(2), i1pml(2))
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = k - i1(2) + 1
        p = k + nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g2(j,i,l,ic)
            g2(j,i,l,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(2) = max(i1(2), i2pml(2) - 1)
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = i2(2) - k + 1
        p = nn(2) - k - nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g5(j,i,l,ic)
            g5(j,i,l,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
case (3)
    i1 = i1cell
    i2 = i2cell
    i2(3) = min(i2(3), i1pml(3))
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = l - i1(3) + 1
        p = l + nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g3(j,k,i,ic)
            g3(j,k,i,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(3) = max(i1(3), i2pml(3) - 1)
    call diff_nc_scale_p5(s1,w2(:,:,:,ii), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = i2(3) - l + 1
        p = nn(3) - l - nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
           temp = dc2(p) *s1(j,k,l) + dc1(p) * g6(j,k,i,ic)
            g6(j,k,i,ic) =temp
            w2(j,k,l,ii) = 0.5 * temp
        end do
        end do
    end do
end select

! add contribution to strain
i = 6 - ic - id
! ##########################################################################################
elseif (ic > id) then
call diff_nc(s1, w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)

! pml region, non-damped directions: g_ij = u_i,j
do i = 1, 3
if (id /= i) then
    i1 = i1cell
    i2 = i2cell
    i2(i) = min(i2(i), i1pml(i))
    call diff_nc(s1, uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    i1 = i1cell
    i2 = i2cell
    i1(i) = max(i1(i), i2pml(i) - 1)
    call diff_nc(s1, uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
end if
end do

! pml region, damped direction: g'_ij = d_j*g_ij = v_i,j
select case (id)
case (1)
    i1 = i1cell
    i2 = i2cell
    i2(1) = min(i2(1), i1pml(1))
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = j - i1(1) + 1
        p = j + nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g1(i,k,l,ic)
            g1(i,k,l,ic) = s1(j,k,l)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(1) = max(i1(1), i2pml(1) - 1)
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = i2(1) - j + 1
        p = nn(1) - j - nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g4(i,k,l,ic)
            g4(i,k,l,ic) = s1(j,k,l)
        end do
        end do
    end do
case (2)
    i1 = i1cell
    i2 = i2cell
    i2(2) = min(i2(2), i1pml(2))
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = k - i1(2) + 1
        p = k + nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g2(j,i,l,ic)
            g2(j,i,l,ic) = s1(j,k,l)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(2) = max(i1(2), i2pml(2) - 1)
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = i2(2) - k + 1
        p = nn(2) - k - nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g5(j,i,l,ic)
            g5(j,i,l,ic) = s1(j,k,l)
        end do
        end do
    end do
case (3)
    i1 = i1cell
    i2 = i2cell
    i2(3) = min(i2(3), i1pml(3))
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = l - i1(3) + 1
        p = l + nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g3(j,k,i,ic)
            g3(j,k,i,ic) = s1(j,k,l)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(3) = max(i1(3), i2pml(3) - 1)
    call diff_nc(s1, vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = i2(3) - l + 1
        p = nn(3) - l - nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            s1(j,k,l) = dc2(p) * s1(j,k,l) + dc1(p) * g6(j,k,i,ic)
            g6(j,k,i,ic) = s1(j,k,l)
        end do
        end do
    end do
end select

! add contribution to strain
i = 6 - ic - id
    !$omp parallel do schedule(static) private(j, k, l)
    do l = 1, nm(3)
    do k = 1, nm(2)
    do j = 1, nm(1)
        w2(j,k,l,i) = w2(j,k,l,i) + 0.5 * s1(j,k,l) !* vc(j,k,l)
    end do
    end do
    end do
    !$omp end parallel do
! ##########################################################################################
else
call diff_nc(ws1(:,:,:,ic), w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)

! pml region, non-damped directions: g_ij = u_i,j
do i = 1, 3
if (id /= i) then
    i1 = i1cell
    i2 = i2cell
    i2(i) = min(i2(i), i1pml(i))
    call diff_nc(ws1(:,:,:,ic), uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    i1 = i1cell
    i2 = i2cell
    i1(i) = max(i1(i), i2pml(i) - 1)
    call diff_nc(ws1(:,:,:,ic), uu, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
end if
end do

! pml region, damped direction: g'_ij = d_j*g_ij = v_i,j
select case (id)
case (1)
    i1 = i1cell
    i2 = i2cell
    i2(1) = min(i2(1), i1pml(1))
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = j - i1(1) + 1
        p = j + nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g1(i,k,l,ic)
            g1(i,k,l,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(1) = max(i1(1), i2pml(1) - 1)
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do j = i1(1), i2(1)
        i = i2(1) - j + 1
        p = nn(1) - j - nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g4(i,k,l,ic)
            g4(i,k,l,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
case (2)
    i1 = i1cell
    i2 = i2cell
    i2(2) = min(i2(2), i1pml(2))
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = k - i1(2) + 1
        p = k + nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g2(j,i,l,ic)
            g2(j,i,l,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(2) = max(i1(2), i2pml(2) - 1)
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do k = i1(2), i2(2)
        i = i2(2) - k + 1
        p = nn(2) - k - nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g5(j,i,l,ic)
            g5(j,i,l,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
case (3)
    i1 = i1cell
    i2 = i2cell
    i2(3) = min(i2(3), i1pml(3))
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = l - i1(3) + 1
        p = l + nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g3(j,k,i,ic)
            g3(j,k,i,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
    i1 = i1cell
    i2 = i2cell
    i1(3) = max(i1(3), i2pml(3) - 1)
    call diff_nc(ws1(:,:,:,ic), vv, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx)
    do l = i1(3), i2(3)
        i = i2(3) - l + 1
        p = nn(3) - l - nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            ws1(j,k,l,ic) = dc2(p) * ws1(j,k,l,ic) + dc1(p) * g6(j,k,i,ic)
            g6(j,k,i,ic) = ws1(j,k,l,ic)
        end do
        end do
    end do
end select

! add contribution to strain
i = 6 - ic - id
end if

end do doid
end do doic

! strain
do i = 1, 3
    !$omp parallel do schedule(static) private(j, k, l)
    do l = 1, nm(3)
    do k = 1, nm(2)
    do j = 1, nm(1)
        ws1(j,k,l,i) = ws1(j,k,l,i) * vc(j,k,l)
        w2(j,k,l,i) = w2(j,k,l,i) * vc(j,k,l)
    end do
    end do
    end do
!$omp end parallel do
end do

! aZd potency source to strain
if (source == 'potency') then
    call finite_source
    call tensor_point_source
end if

! strain i/o
call field_io('<>', 'e11', ws1(:,:,:,1))
call field_io('<>', 'e22', ws1(:,:,:,2))
call field_io('<>', 'e33', ws1(:,:,:,3))
call field_io('<>', 'e23', w2(:,:,:,1))
call field_io('<>', 'e31', w2(:,:,:,2))
call field_io('<>', 'e12', w2(:,:,:,3))

! attenuation
!do j = 1, 2
!do k = 1, 2
!do l = 1, 2
!  i = j + 2 * (k - 1) + 4 * (l - 1)
!  z1(j::2,k::2,l::2,:) = c1(i) * z1(j::2,k::2,l::2,:) + c2(i) * ws1(j::2,k::2,l::2,:)
!  z2(j::2,k::2,l::2,:) = c1(i) * z2(j::2,k::2,l::2,:) + c2(i) * w2(j::2,k::2,l::2,:)
!end do
!end do
!end do

! Hook's law: w_ij = lam*g_ij*delta_ij + mu*(g_ij + g_ji)
nm3 = nm(1) * nm(2) * nm(3)
nm4 = nm3 * 3
call loop2(ws1, w2, lam, mu, nm3, nm4)

! add moment source to stress
if (source == 'moment') then
    call finite_source
    call tensor_point_source
end if

! stress i/o
call field_io('<>', 'w11', ws1(:,:,:,1))
call field_io('<>', 'w22', ws1(:,:,:,2))
call field_io('<>', 'w33', ws1(:,:,:,3))
call field_io('<>', 'w23', w2(:,:,:,1))
call field_io('<>', 'w31', w2(:,:,:,2))
call field_io('<>', 'w12', w2(:,:,:,3))
if (modulo(it, itstats) == 0) then
    call tensor_norm(s1, ws1, w2, i1core, i2core, (/ 1, 1, 1 /))
    call set_halo(s1, -1.0, i1core, i2core)
    wmaxloc = maxloc(s1)
    wmax = s1(wmaxloc(1),wmaxloc(2),wmaxloc(3))
end if
call field_io('>', 'wm2', s1)

end subroutine

! Hook's law: w_ij = lam*g_ij*delta_ij + mu*(g_ij + g_ji)
subroutine loop2(ww1, ww2, lamm, muu, nm3, nm4)
real, intent(inout) :: ww1(nm4), ww2(nm4)
real, intent(in) :: lamm(nm3), muu(nm3)
integer, intent(in) :: nm3,nm4

real :: temp, ww11,ww12,ww13,ww21,ww22,ww23,lam1,mu1
integer :: k, nm3t2

nm3t2 = nm3 * 2

!$omp parallel do schedule(static) private(k, temp, ww11,ww12,ww13,ww21,ww22,ww23,lam1,mu1)
do k = 1, nm3

  ww11 = ww1(k)
  ww12 = ww1(nm3   + k) 
  ww13 = ww1(nm3t2 + k) 
  ww21 = ww2(k)
  ww22 = ww2(nm3   + k) 
  ww23 = ww2(nm3t2 + k) 
  lam1 = lamm(k)
  mu1 = 2.0 * muu(k)

  temp = lam1 * (ww11 + ww12 + ww13)
  ww11 = mu1 * ww11 + temp
  ww12 = mu1 * ww12 + temp
  ww13 = mu1 * ww13 + temp
  ww21 = mu1 * ww21
  ww22 = mu1 * ww22
  ww23 = mu1 * ww23

  ww1(k) = ww11
  ww1(nm3   + k) = ww12 
  ww1(nm3t2 + k) = ww13
  ww2(k) = ww21
  ww2(nm3   + k) = ww22
  ww2(nm3t2 + k) = ww23
end do


end subroutine


end module

