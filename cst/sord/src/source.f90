! kinematic source
module m_source
implicit none
integer, private, allocatable :: src_nt(:)
real, private, allocatable :: src_xi(:,:), src_dt(:), src_t0(:), &
    src_w1(:,:), src_w2(:,:), src_history(:)
contains

! initialize finite source
subroutine finite_source_init
use m_globals
use m_collective
use m_util
integer :: n, i, fh
if ( nsource == 0 ) return
if ( master ) write( *, '(a)' ) 'Finite source initialize'
n = abs( nsource )
allocate( src_xi(n,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, src_xi(:,1), 'r', 'source/xi1.bin', n, 0, mpin, verb )
call rio1( fh, src_xi(:,2), 'r', 'source/xi2.bin', n, 0, mpin, verb )
call rio1( fh, src_xi(:,3), 'r', 'source/xi3.bin', n, 0, mpin, verb )
if ( source == 'force' ) then
    do i = 1, 3
        src_xi(:,i) = src_xi(:,i) - nnoff(i)
        if ( all( src_xi(:,i) < (-1.0 + i1node(i)) ) .or. &
             all( src_xi(:,i) > ( 1.0 + i2node(i)) ) ) then
            nsource = 0
            deallocate( src_xi )
            return
        end if
    end do
    allocate( src_nt(n), src_dt(n), src_t0(n), src_w1(n,3) )
    call rio1( fh, src_w1(:,1), 'r', 'source/w11.bin', n, 0, mpin, verb )
    call rio1( fh, src_w1(:,2), 'r', 'source/w12.bin', n, 0, mpin, verb )
    call rio1( fh, src_w1(:,3), 'r', 'source/w13.bin', n, 0, mpin, verb )
else
    do i = 1, 3
        src_xi(:,i) = src_xi(:,i) - 0.5 - nnoff(i)
        if ( all( src_xi(:,i) < (-1.0 + i1cell(i)) ) .or. &
             all( src_xi(:,i) > ( 1.0 + i2cell(i)) ) ) then
            nsource = 0
            deallocate( src_xi )
            return
        end if
    end do
    allocate( src_nt(n), src_dt(n), src_t0(n), src_w1(n,3), src_w2(n,3) )
    call rio1( fh, src_w1(:,1), 'r', 'source/w11.bin', n, 0, mpin, verb )
    call rio1( fh, src_w1(:,2), 'r', 'source/w22.bin', n, 0, mpin, verb )
    call rio1( fh, src_w1(:,3), 'r', 'source/w33.bin', n, 0, mpin, verb )
    call rio1( fh, src_w2(:,1), 'r', 'source/w23.bin', n, 0, mpin, verb )
    call rio1( fh, src_w2(:,2), 'r', 'source/w31.bin', n, 0, mpin, verb )
    call rio1( fh, src_w2(:,3), 'r', 'source/w12.bin', n, 0, mpin, verb )
end if
call rio1( fh, src_t0, 'r', 'source/t0.bin', n, 0, mpin, verb )
call rio1( fh, src_dt, 'r', 'source/dt.bin', n, 0, mpin, verb )
call iio1( fh, src_nt, 'r', 'source/nt.bin', n, 0, mpin, verb )
n = sum( src_nt )
allocate( src_history(n) )
call rio1( fh, src_history, 'r', 'source/history.bin', n, 0, mpin, verb )
end subroutine

! add finite source to force vector or strain/stress tensor
subroutine finite_source
use m_globals
integer :: i1(3), i2(3), i, j, k, l, isrc, itoff
real :: xi(3), t, h, w
if ( nsource == 0 ) return
if ( verb ) write( *, '(a)' ) 'Finite source'
itoff = 0
do isrc = 1, abs( nsource )
    i = floor( ( tm - src_t0(isrc) ) / src_dt(isrc) ) + 1
    xi = src_xi(isrc,:)
    if ( source == 'force' ) then
        i1 = max( i1node, floor( xi ) )
        i2 = min( i2node, floor( xi ) + 1 )
    else
        i1 = max( i1cell, floor( xi ) )
        i2 = min( i2cell, floor( xi ) + 1 )
    end if
    if ( i >= 0 .and. all( i2 >= i1 ) ) then
        i = min( i, src_nt(isrc) - 1 )
        t = src_t0(isrc) + src_dt(isrc) * (i - 1)
        h = min( 1.0, (tm - t) / src_dt(isrc) )
        if ( i == 0 ) then
            h = h * src_history(itoff+1)
        else
            h = (1.0 - h) * src_history(itoff+i) + h * src_history(itoff+i+1)
        end if
        if ( source == 'force' ) then
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                w = h * ((1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l)))
                do i = 1, 3
                    w1(j,k,l,i) = w1(j,k,l,i) + w * src_w1(isrc,i)
                end do
            end do
            end do
            end do
        else
            do l = i1(3), i2(3)
            do k = i1(2), i2(2)
            do j = i1(1), i2(1)
                w = h * vc(j,k,l) * ((1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l)))
                do i = 1, 3
                    w1(j,k,l,i) = w1(j,k,l,i) - w * src_w1(isrc,i)
                    w2(j,k,l,i) = w2(j,k,l,i) - w * src_w2(isrc,i)
                end do
            end do
            end do
            end do
        end if
    end if
    itoff = itoff + src_nt(isrc)
end do
end subroutine

! add point source to vector
subroutine vector_point_source
use m_globals
use m_util
integer :: i1(3), i2(3), i, j, k, l
real :: xi(3), f, w
if ( timefunction == 'none' ) return
xi = ihypo - nnoff
i1 = max( i1node, floor( xi ) )
i2 = min( i2node, floor( xi ) + 1 )
if ( any( i2 < i1 ) ) then
    timefunction = 'none'
    return
end if
if ( verb ) write( *, '(a)' ) 'Point source'
f = time_function( timefunction, tm, dt, period )
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
    w = f * ( (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l)) )
    do i = 1, 3
        w1(j,k,l,i) = w1(j,k,l,i) + w * source1(i)
    end do
end do
end do
end do
end subroutine

! add point source to strain/stress tensor
subroutine tensor_point_source
use m_globals
use m_util
integer :: i1(3), i2(3), i, j, k, l
real :: xi(3), f, w
if ( timefunction == 'none' ) return
xi = ihypo - 0.5 - nnoff
i1 = max( i1cell, floor( xi ) )
i2 = min( i2cell, floor( xi ) + 1 )
if ( any( i2 < i1 ) ) then
    timefunction = 'none'
    return
end if
if ( verb ) write( *, '(a)' ) 'Point source'
f = time_function( timefunction, tm, dt, period )
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
    w = f * vc(j,k,l) * ( (1.0-abs(xi(1)-j)) * (1.0-abs(xi(2)-k)) * (1.0-abs(xi(3)-l)) )
    do i = 1, 3
        w1(j,k,l,i) = w1(j,k,l,i) - w * source1(i)
        w2(j,k,l,i) = w2(j,k,l,i) - w * source2(i)
    end do
end do
end do
end do
end subroutine

end module

