! Finite fault source
module m_ffault
implicit none
contains

! Initialize source
subroutine ffault_init
use m_globals
use m_collective
use m_util
integer :: n(3), noff(3), i, o(3) = 0, fh

! Moment source
if ( nffault <= 0 ) return
if ( master ) write( 0, * ) 'Finite fault source initialize'
fh = -1
if ( mpin /= 0 ) fh = file_null

! Read parameters
call rio1( fh, ff_tm0,       'r', 'in/ff_tm0',   ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,1),    'r', 'in/ff_x1',    ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,2),    'r', 'in/ff_x2',    ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,3),    'r', 'in/ff_x3',    ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,1), 'r', 'in/ff_nhat1', ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,2), 'r', 'in/ff_nhat2', ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,3), 'r', 'in/ff_nhat3', ff_np, 0, mpin, verb )

! Read slip rates
n = (/ ff_np, ff_nt, 1 /)
call rio2( fh, ff_su(:,1),   'r', 'in/ff_su1',   n, n, o,  mpin, verb )
call rio2( fh, ff_su(:,2),   'r', 'in/ff_su2',   n, n, o,  mpin, verb )
call rio2( fh, ff_su(:,3),   'r', 'in/ff_su3',   n, n, o,  mpin, verb )

! Locations
if ( ff_find_locs == 0 ) then
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  n = nn + 2 * nhalo
  noff = nnoff + nhalo
  do i = 1, ff_np
    call radius( s2, w2, ff_x(i), i1, i2 )
    call reduceloc( rr, ii, s2, 'allmin', n, noff, 0 )
    ii = ii + nnoff
    ff_x(:,i) = ii
  end if
end do

! Store locations
if ( master ) then
  call rio1( fh, ff_x(:,1), 'w', 'out/ff_i1', ff_np, 0, mpin, verb )
  call rio1( fh, ff_x(:,2), 'w', 'out/ff_i2', ff_np, 0, mpin, verb )
  call rio1( fh, ff_x(:,3), 'w', 'out/ff_i3', ff_np, 0, mpin, verb )
end if

end subroutine

end module

