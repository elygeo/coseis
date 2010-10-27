! acceleration calculation
module m_acceleration
implicit none
contains

subroutine acceleration
use m_globals
use m_diffcn
use m_source
use m_hourglass
use m_bc
use m_rupture
use m_util
use m_fieldio
use m_stats
use m_collective
integer :: i1(3), i2(3), i, j, k, l, ic, iid, id, iq, p
real :: rr

if ( verb ) write( *, '(a)' ) 'Acceleration'
call set_halo( s1, 0.0, i1node, i2node )

! loop over component and derivative direction
doic: do ic  = 1, 3
doid: do iid = 1, 3; id = modulo( ic + iid - 2, 3 ) + 1

! elastic region
! f_i = w_ij,j
i1 = i1node
i2 = i2node
if ( ic == id ) then
    call diffcn( s1, w1, ic, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
else
    i = 6 - ic - id
    call diffcn( s1, w2, i, id, i1, i2, oplevel, bb, xx, dx1, dx2, dx3, dx )
end if

! pml region
! p'_ij + d_j*p_ij = w_ij,j (no summation convention)
! f_i = sum_j( p_ij' )
select case( id )
case( 1 )
    do j = i1(1), min( i2(1), i1pml(1) )
        i = j - i1(1) + 1
        p = j + nnoff(1)
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p1(i,k,l,ic)
            p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
    do j = max( i1(1), i2pml(1) ), i2(1)
        i = i2(1) - j + 1
        p = nn(1) - j - nnoff(1) + 1
        do l = i1(3), i2(3)
        do k = i1(2), i2(2)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p4(i,k,l,ic)
            p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
case( 2 )
    do k = i1(2), min( i2(2), i1pml(2) )
        i = k - i1(2) + 1
        p = k + nnoff(2)
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p2(j,i,l,ic)
            p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
    do k = max( i1(2), i2pml(2) ), i2(2)
        i = i2(2) - k + 1
        p = nn(2) - k - nnoff(2) + 1
        do l = i1(3), i2(3)
        do j = i1(1), i2(1)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p5(j,i,l,ic)
            p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
case( 3 )
    do l = i1(3), min( i2(3), i1pml(3) )
        i = l - i1(3) + 1
        p = l + nnoff(3)
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p3(j,k,i,ic)
            p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
    do l = max( i1(3), i2pml(3) ), i2(3)
        i = i2(3) - l + 1
        p = nn(3) - l - nnoff(3) + 1
        do k = i1(2), i2(2)
        do j = i1(1), i2(1)
            s1(j,k,l) = dn2(p) * s1(j,k,l) + dn1(p) * p6(j,k,i,ic)
            p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s1(j,k,l)
        end do
        end do
    end do
end select

! add contribution to force vector
if ( ic == id ) then
    w1(:,:,:,ic) = s1
else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s1
end if

end do doid
end do doic

! hourglass control. only viscous in pml
if ( any( hourglass > 0.0 ) ) then
call set_halo( s1, 0.0, i1cell, i2cell )
call set_halo( s2, 0.0, i1node, i2node )
w2 = hourglass(1) * uu + dt * hourglass(2) * vv
do iq = 1, 4
do ic = 1, 3
    i1 = max( i1pml,     i1cell )
    i2 = min( i2pml - 1, i2cell )
    call hourglassnc( s1, w2, iq, ic, i1, i2 )
    s1 = yy * s1
    i1 = max( i1pml + 1, i1node )
    i2 = min( i2pml - 1, i2node )
    call hourglasscn( s2, s1, iq, i1, i2 )
    if ( hourglass(2) > 0.0 .and. npml > 0 ) then
        do i = 1, 3
            i1 = i1cell
            i2 = i2cell
            i2(i) = min( i2(i), i1pml(i) )
            call hourglassnc( s1, vv, iq, ic, i1, i2 )
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                s1(j,k,l) = dt * hourglass(2) * yy(j,k,l) * s1(j,k,l)
            end do
            end do
            end do
            i1 = i1cell
            i2 = i2cell
            i1(i) = max( i1(i), i2pml(i) - 1 )
            call hourglassnc( s1, vv, iq, ic, i1, i2 )
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                s1(j,k,l) = dt * hourglass(2) * yy(j,k,l) * s1(j,k,l)
            end do
            end do
            end do
        end do
        do i = 1, 3
            i1 = i1node
            i2 = i2node
            i2(i) = min( i2(i), i1pml(i) )
            call hourglasscn( s2, s1, iq, i1, i2 )
            i1 = i1node
            i2 = i2node
            i1(i) = max( i1(i), i2pml(i) )
            call hourglasscn( s2, s1, iq, i1, i2 )
        end do
    end if
    w1(:,:,:,ic) = w1(:,:,:,ic) - s2
end do
end do
end if

! add source to force
if ( source == 'force' ) then
    call finite_source
    call vector_point_source
end if

! nodal force input
call fieldio( '<', 'f1', w1(:,:,:,1) )
call fieldio( '<', 'f2', w1(:,:,:,2) )
call fieldio( '<', 'f3', w1(:,:,:,3) )

! boundary conditions
call vector_bc( w1, bc1, bc2, i1bc, i2bc )

! spontaneous rupture
call rupture

! swap halo
rr = timer( 2 )
call vector_swap_halo( w1, nhalo )
if (sync) call barrier
mptimer = mptimer + timer( 2 )

! nodal force output
call fieldio( '>', 'f1', w1(:,:,:,1) )
call fieldio( '>', 'f2', w1(:,:,:,2) )
call fieldio( '>', 'f3', w1(:,:,:,3) )

! Newton's law: a_i = f_i / m
do i = 1, 3
    w1(:,:,:,i) = w1(:,:,:,i) * mr
end do

! acceleration I/O
call fieldio( '<>', 'a1', w1(:,:,:,1) )
call fieldio( '<>', 'a2', w1(:,:,:,2) )
call fieldio( '<>', 'a3', w1(:,:,:,3) )
if ( modulo( it, itstats ) == 0 ) then
    call vector_norm( s1, w1, i1core, i2core, (/ 1, 1, 1 /) )
    call set_halo( s1, -1.0, i1core, i2core )
    amax = maxval( s1 )
end if
call fieldio( '>', 'am2', s1  )

end subroutine

end module

