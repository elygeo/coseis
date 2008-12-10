! Kinematic finite source
module m_finite_source
implicit none
integer, private, allocatable :: src_nt(:)
real, private, allocatable :: src_dt(:), src_tm0(:), &
  src_x(:,:), src_nhat(:,:), src_shat(:,:), src_slip(:)
contains

! Initialize finite source
subroutine finite_source_init
use m_globals
use m_collective
use m_util
integer :: i1(3), i2(3), ii(3), mm(3), mmoff(3), nsrc, isrc, n, fh
real :: x(3), r
if ( nsource == 0 ) return
if ( master ) write( 0, * ) 'Finite source initialize'
nsrc = abs( nsrc )
allocate( src_nt(nsrc), src_dt(nsrc), src_tm0(nsrc), &
  src_x(nsrc,3), src_nhat(nsrc,3), src_shat(nsrc,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, src_dt,        'r', 'in/src_nt',    nsrc, 0, mpin, verb )
src_nt = src_dt + 0.5
call rio1( fh, src_dt,        'r', 'in/src_dt',    nsrc, 0, mpin, verb )
call rio1( fh, src_tm0,       'r', 'in/src_tm0',   nsrc, 0, mpin, verb )
call rio1( fh, src_x(:,1),    'r', 'in/src_x1',    nsrc, 0, mpin, verb )
call rio1( fh, src_x(:,2),    'r', 'in/src_x2',    nsrc, 0, mpin, verb )
call rio1( fh, src_x(:,3),    'r', 'in/src_x3',    nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,1), 'r', 'in/src_nhat1', nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,2), 'r', 'in/src_nhat2', nsrc, 0, mpin, verb )
call rio1( fh, src_nhat(:,3), 'r', 'in/src_nhat3', nsrc, 0, mpin, verb )
call rio1( fh, src_shat(:,1), 'r', 'in/src_shat1', nsrc, 0, mpin, verb )
call rio1( fh, src_shat(:,2), 'r', 'in/src_shat2', nsrc, 0, mpin, verb )
call rio1( fh, src_shat(:,3), 'r', 'in/src_shat3', nsrc, 0, mpin, verb )
n = sum( src_nt )
allocate( src_slip(n) )
call rio1( fh, src_slip,      'r', 'in/src_slip',  n,    0, mpin, verb )
if ( nsource < 0 ) then
  s2 = huge( r )
  mm = nn + 2 * nhalo
  mmoff = nnoff + nhalo
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  do isrc = 1, nsrc
    x = src_x(isrc,:)
    call radius( s2, w2, x, i1, i2 )
    call reduceloc( r, ii, s2, 'allmin', mm, mmoff, 0 )
    src_x(isrc,:) = ii + nnoff
  end do
  if ( master ) then
    call rio1( fh, src_x(:,1), 'w', 'out/src_x1', nsrc, 0, mpout, verb )
    call rio1( fh, src_x(:,2), 'w', 'out/src_x2', nsrc, 0, mpout, verb )
    call rio1( fh, src_x(:,3), 'w', 'out/src_x3', nsrc, 0, mpout, verb )
  end if
end if
end subroutine

! Add finite source to potency tensor
subroutine finite_source
use m_globals
integer :: j, k, l, i, isrc, itoff
real :: su(3), nu(3), slip, t, h
if ( nsource == 0 ) return
if ( verb ) write( 0, * ) 'Finite source'
itoff = 0
do isrc = 1, abs( nsource )
  i = ( tm - src_tm0(isrc) ) / src_dt(isrc) + 1.5
  if ( i >= 1 .and. i < src_nt(isrc) ) then
    t = src_tm0(isrc) + src_dt(isrc) * ( i - 1 )
    h = ( tm - t ) / src_dt(isrc)
    slip = ( 1. - h ) * src_slip(itoff+i) + h * src_slip(itoff+i+1)
    itoff = itoff + src_nt(isrc)
    su = src_shat(isrc,:) * slip
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

