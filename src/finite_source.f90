! Kinematic finite source
module m_finite_source
implicit none
integer, private, allocatable :: src_nt(:)
real, private, allocatable :: &
  src_dt(:), src_tm0(:), src_x(:,:), src_nhat(:,:), src_su(:,:)
contains

! Initialize finite source
subroutine finite_source_init
use m_globals
use m_collective
use m_util
integer :: i1(3), i2(3), ii(3), n(3), noff(3), fh, isrc, ntall
real :: x(3), r
if ( nsource <= 0 ) return
if ( master ) write( 0, * ) 'Finite source initialize'
allocate( src_nt(nsource), src_dt(nsource), src_tm0(nsource), &
  src_x(nsource,3), src_nhat(nsource,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, src_dt,        'r', 'in/src_nt',    nsource, 0, mpin, verb )
src_nt = src_dt + 0.5
ntall = sum( src_nt )
allocate( src_su(ntall,3) )
call rio1( fh, src_dt,        'r', 'in/src_dt',    nsource, 0, mpin, verb )
call rio1( fh, src_tm0,       'r', 'in/src_tm0',   nsource, 0, mpin, verb )
call rio1( fh, src_x(:,1),    'r', 'in/src_x1',    nsource, 0, mpin, verb )
call rio1( fh, src_x(:,2),    'r', 'in/src_x2',    nsource, 0, mpin, verb )
call rio1( fh, src_x(:,3),    'r', 'in/src_x3',    nsource, 0, mpin, verb )
call rio1( fh, src_nhat(:,1), 'r', 'in/src_nhat1', nsource, 0, mpin, verb )
call rio1( fh, src_nhat(:,2), 'r', 'in/src_nhat2', nsource, 0, mpin, verb )
call rio1( fh, src_nhat(:,3), 'r', 'in/src_nhat3', nsource, 0, mpin, verb )
call rio1( fh, src_su(:,1),   'r', 'in/src_su1',   ntall,   0, mpin, verb )
call rio1( fh, src_su(:,2),   'r', 'in/src_su2',   ntall,   0, mpin, verb )
call rio1( fh, src_su(:,3),   'r', 'in/src_su3',   ntall,   0, mpin, verb )
if ( locatesource == 1 ) then
  s2 = huge( r )
  n = nn + 2 * nhalo
  noff = nnoff + nhalo
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  do isrc = 1, nsource
    x = src_x(isrc,:)
    call radius( s2, w2, x, i1, i2 )
    call reduceloc( r, ii, s2, 'allmin', n, noff, 0 )
    src_x(isrc,:) = ii + nnoff
  end do
  if ( master ) then
    call rio1( fh, src_x(:,1), 'w', 'out/src_x1', nsource, 0, mpout, verb )
    call rio1( fh, src_x(:,2), 'w', 'out/src_x2', nsource, 0, mpout, verb )
    call rio1( fh, src_x(:,3), 'w', 'out/src_x3', nsource, 0, mpout, verb )
  end if
end if
end subroutine

! Add finite source to potency tensor
subroutine finite_source
use m_globals
integer :: j, k, l, i, isrc, itoff
real :: su(3), nu(3), t, h
if ( nsource <= 0 ) return
if ( verb ) write( 0, * ) 'Finite source'
itoff = 0
do isrc = 1, nsource
  i = ( tm - src_tm0(isrc) ) / src_dt(isrc) + 1.5
  if ( i >= 1 .and. i < src_nt(isrc) ) then
    t = src_tm0(isrc) + src_dt(isrc) * ( i - 1 )
    h = ( tm - t ) / src_dt(isrc)
    su = ( 1. - h ) * src_su(itoff+i,:) + h * src_su(itoff+i+1,:)
    itoff = itoff + src_nt(isrc)
    nu = src_nhat(isrc,:)
    j = src_x(isrc,1) + 0.5 - nnoff(1)
    k = src_x(isrc,2) + 0.5 - nnoff(2)
    l = src_x(isrc,3) + 0.5 - nnoff(3)
    w1(j,k,l,:) = w1(j,k,l,:) + su * nu
    w2(j,k,l,1) = w2(j,k,l,1) + 0.5 * ( su(2) * nu(3) + nu(2) * su(3) )
    w2(j,k,l,2) = w2(j,k,l,2) + 0.5 * ( su(3) * nu(1) + nu(3) * su(1) )
    w2(j,k,l,3) = w2(j,k,l,3) + 0.5 * ( su(1) * nu(2) + nu(1) * su(2) )
  end if
end do
end subroutine

end module

