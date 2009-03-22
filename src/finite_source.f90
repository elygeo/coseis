! Kinematic finite source
module m_finite_source
implicit none
integer, private, allocatable :: src_nt(:)
real, private, allocatable :: src_dt(:), src_t0(:), &
  src_xi(:,:), src_nhat(:,:), src_svec(:,:), src_sv(:)
contains

! Initialize finite source
subroutine finite_source_init
use m_globals
use m_collective
use m_util
integer :: n, nsrc, i, isrc, itoff, fh
real :: r
if ( nsource == 0 ) return
if ( master ) write( 0, * ) 'Finite source initialize'
nsrc = abs( nsrc )
allocate( src_nt(nsrc), src_dt(nsrc), src_t0(nsrc), &
  src_xi(nsrc,3), src_nhat(nsrc,3), src_svec(nsrc,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, src_dt,        'r', 'in/src_nt',    nsrc, 0, mpin, verb )
src_nt = src_dt + 0.5
call rio1( fh, src_dt,        'r', 'in/src_dt',    nsrc, 0, mpin, verb )
call rio1( fh, src_t0,        'r', 'in/src_t0',    nsrc, 0, mpin, verb )
call rio1( fh, src_xi(:,1),   'r', 'in/src_xi1',   nsrc, 0, mpin, verb )
call rio1( fh, src_xi(:,2),   'r', 'in/src_xi2',   nsrc, 0, mpin, verb )
call rio1( fh, src_xi(:,3),   'r', 'in/src_xi3',   nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,1), 'r', 'in/src_nhat1', nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,2), 'r', 'in/src_nhat2', nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,3), 'r', 'in/src_nhat3', nsrc, 0, mpin, verb )
call rio1( fh, src_svec(:,1), 'r', 'in/src_svec1', nsrc, 0, mpin, verb )
call rio1( fh, src_svec(:,2), 'r', 'in/src_svec2', nsrc, 0, mpin, verb )
call rio1( fh, src_svec(:,3), 'r', 'in/src_svec3', nsrc, 0, mpin, verb )
n = sum( src_nt )
allocate( src_sv(n) )
call rio1( fh, src_sv,        'r', 'in/src_slip',  n,    0, mpin, verb )
itoff = 0
do isrc = 1, nsrc
  src_xi(isrc,:) = src_xi(isrc,:) / dx + 1 - nnoff
  r = 0.
  do i = 1, src_nt(isrc)
    r = r + src_sv(itoff+i) * src_dt(isrc)
    src_sv(itoff+i) = r
  end do
  itoff = itoff + src_nt(isrc)
end do
src_t0 = src_t0 + 0.5 * src_dt
end subroutine

! Add finite source to potency tensor
! FIXME registration, weightings
subroutine finite_source
use m_globals
integer :: ii(3), i, j, k, l, isrc, itoff
real :: su(3), nu(3), slip, t, h
if ( nsource == 0 ) return
if ( verb ) write( 0, * ) 'Finite source'
itoff = 0
do isrc = 1, abs( nsource )
  i = ( tm - src_t0(isrc) ) / src_dt(isrc) + 1.5
  if ( i >= 1 ) then
    i = min( i, src_nt(isrc) - 1 )
    t = src_t0(isrc) + src_dt(isrc) * ( i - 1 )
    h = min( 1., ( tm - t ) / src_dt(isrc) )
    slip = ( 1. - h ) * src_sv(itoff+i) + h * src_sv(itoff+i+1)
    su = src_svec(isrc,:) * slip
    nu = src_nhat(isrc,:)
    ii = int( src_xi(isrc,:) )
    do l = ii(3), ii(3)+1
    do k = ii(2), ii(2)+1
    do j = ii(1), ii(1)+1
      !w = src_xi
      w1(j,k,l,:) = w1(j,k,l,:) + su * nu
      w2(j,k,l,1) = w2(j,k,l,1) + 0.5 * ( su(2) * nu(3) + nu(2) * su(3) )
      w2(j,k,l,2) = w2(j,k,l,2) + 0.5 * ( su(3) * nu(1) + nu(3) * su(1) )
      w2(j,k,l,3) = w2(j,k,l,3) + 0.5 * ( su(1) * nu(2) + nu(1) * su(2) )
    end do
    end do
    end do
  end if
  itoff = itoff + src_nt(isrc)
end do
end subroutine

end module

