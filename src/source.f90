! Kinematic source
module m_source
implicit none
integer, private, allocatable :: src_nt(:)
real, private, allocatable :: src_xi(:,:), src_dt(:), src_t0(:), &
  src_w1(:,:), src_w2(:,:), src_history(:)
contains

! Initialize finite source
subroutine finite_source_init
use m_globals
use m_collective
use m_util
integer :: n, i, fh
if ( nsource == 0 ) return
if ( master ) write( 0, * ) 'Finite source initialize'
n = abs( nsource )
allocate( src_xi(n,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, src_xi(:,1), 'r', 'in/src_xi1',     n, 0, mpin, verb )
call rio1( fh, src_xi(:,2), 'r', 'in/src_xi2',     n, 0, mpin, verb )
call rio1( fh, src_xi(:,3), 'r', 'in/src_xi3',     n, 0, mpin, verb )
do i = 1, 3
  src_xi(:,i) = src_xi(:,i) - 0.5 - nnoff(i)
  if ( all( src_xi(:,i) < (-1.+i1cell(i)) ) .or. &
       all( src_xi(:,i) > ( 1.+i2cell(i)) ) ) then
    nsource = 0
    deallocate( src_xi )
    return
  end if
end do
allocate( src_nt(n), src_dt(n), src_t0(n), src_w1(n,3), src_w2(n,3) )
call rio1( fh, src_w1(:,1), 'r', 'in/src_w11',     n, 0, mpin, verb )
call rio1( fh, src_w1(:,2), 'r', 'in/src_w22',     n, 0, mpin, verb )
call rio1( fh, src_w1(:,3), 'r', 'in/src_w33',     n, 0, mpin, verb )
call rio1( fh, src_w2(:,1), 'r', 'in/src_w23',     n, 0, mpin, verb )
call rio1( fh, src_w2(:,2), 'r', 'in/src_w31',     n, 0, mpin, verb )
call rio1( fh, src_w2(:,3), 'r', 'in/src_w12',     n, 0, mpin, verb )
call rio1( fh, src_t0,      'r', 'in/src_t0',      n, 0, mpin, verb )
call rio1( fh, src_dt,      'r', 'in/src_nt',      n, 0, mpin, verb )
src_nt = int( src_dt + 0.5 )
call rio1( fh, src_dt,      'r', 'in/src_dt',      n, 0, mpin, verb )
n = sum( src_nt )
allocate( src_history(n) )
call rio1( fh, src_history, 'r', 'in/src_history', n, 0, mpin, verb )
end subroutine

! Add finite source to strain/stress tensor
subroutine finite_source
use m_globals
integer :: i1(3), i2(3), i, j, k, l, isrc, itoff
real :: xi(3), t, h, w
if ( nsource == 0 ) return
if ( verb ) write( 0, * ) 'Finite source'
itoff = 0
do isrc = 1, abs( nsource )
  i = ( tm - src_t0(isrc) ) / src_dt(isrc) + 1.5
  xi = src_xi(isrc,:)
  i1 = max( i1cell, int( xi )     )
  i2 = min( i2cell, int( xi ) + 1 )
  if ( i >= 1 .and. all( i2 >= i1 ) ) then
    i = min( i, src_nt(isrc) - 1 )
    t = src_t0(isrc) + src_dt(isrc) * ( i - 1 )
    h = min( 1., ( tm - t ) / src_dt(isrc) )
    h = ( 1.0 - h ) * src_history(itoff+i) + h * src_history(itoff+i+1)
    do l = i1(3), i2(3)
    do k = i1(2), i2(2)
    do j = i1(1), i2(1)
      w = h * vc(j,k,l) * ( 1.0 - abs( (xi(1) - j) * (xi(2) - k) * (xi(3) - l) ) )
      do i = 1, 3
        w1(j,k,l,i) = w1(j,k,l,i) - w * src_w1(isrc,i)
        w2(j,k,l,i) = w2(j,k,l,i) - w * src_w2(isrc,i)
      end do
    end do
    end do
    end do
  end if
  itoff = itoff + src_nt(isrc)
end do
end subroutine

! Add point source to strain/stress tensor
subroutine point_source
use m_globals
use m_util
integer :: i1(3), i2(3), i, j, k, l
real :: xi(3), f, w
if ( tfunc == '' ) return
xi = ihypo - 0.5 - nnoff
i1 = max( i1cell, int( xi )     )
i2 = min( i2cell, int( xi ) + 1 )
if ( any( i2 < i1 ) ) then
  tfunc = ''
  return
end if
if ( verb ) write( 0, * ) 'Point source'
f = time_function( tfunc, tm, dt, tsource )
do l = i1(3), i2(3)
do k = i1(2), i2(2)
do j = i1(1), i2(1)
  w = f * vc(j,k,l) * ( 1.0 - abs( (xi(1) - j) * (xi(2) - k) * (xi(3) - l) ) )
  do i = 1, 3
    w1(j,k,l,i) = w1(j,k,l,i) - w * moment1(i)
    w2(j,k,l,i) = w2(j,k,l,i) - w * moment2(i)
  end do
end do
end do
end do
end subroutine

end module

