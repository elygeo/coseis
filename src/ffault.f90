! Finite fault kinematic source
! globals: ff_np, ff_nt, ff_locate 
module m_ffault
implicit none
real, private, allocatable :: ff_tm0(:), ff_x(:,:), ff_nhat(:,:), ff_su(:,:,:)
contains

! Initialize finite fault
subroutine ffault_init
use m_globals
use m_collective
use m_util
integer :: ii(3), n(3), noff(3), o(3) = 0, fh, i
real :: x(3), r
if ( ff_np <= 0 ) return
if ( master ) write( 0, * ) 'Finite fault source initialize'
allocate( ff_tm0(ff_np), ff_x(ff_np,3), ff_nhat(ff_np,3), ff_su(ff_np,ff_nt,3) )
fh = -1
if ( mpin /= 0 ) fh = file_null
call rio1( fh, ff_tm0,       'r', 'in/ff_tm0',   ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,1),    'r', 'in/ff_x1',    ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,2),    'r', 'in/ff_x2',    ff_np, 0, mpin, verb )
call rio1( fh, ff_x(:,3),    'r', 'in/ff_x3',    ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,1), 'r', 'in/ff_nhat1', ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,2), 'r', 'in/ff_nhat2', ff_np, 0, mpin, verb )
call rio1( fh, ff_nhat(:,3), 'r', 'in/ff_nhat3', ff_np, 0, mpin, verb )
n = (/ ff_np, ff_nt, 1 /)
call rio2( fh, ff_su(:,:,1), 'r', 'in/ff_su1', n, n, o, mpin, verb )
call rio2( fh, ff_su(:,:,2), 'r', 'in/ff_su2', n, n, o, mpin, verb )
call rio2( fh, ff_su(:,:,3), 'r', 'in/ff_su3', n, n, o, mpin, verb )
if ( ff_locate == 0 ) then
  s2 = huge( r )
  n = nn + 2 * nhalo
  noff = nnoff + nhalo
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  do i = 1, ff_np
    x = ff_x(i,:)
    call radius( s2, w2, x, i1, i2 )
    call reduceloc( r, ii, s2, 'allmin', n, noff, 0 )
    ff_x(i,:) = ii + nnoff
  end if
  if ( master ) then
    call rio1( fh, ff_x(:,1), 'w', 'out/ff_x1', ff_np, 0, mpin, verb )
    call rio1( fh, ff_x(:,2), 'w', 'out/ff_x2', ff_np, 0, mpin, verb )
    call rio1( fh, ff_x(:,3), 'w', 'out/ff_x3', ff_np, 0, mpin, verb )
  end if
end if
end subroutine

! Add finite fault to strain tensor
subroutine ffault
use m_globals
integer :: j, k, l, i, ii
real :: su(3), nhat(3), t, h
if ( ff_np <= 0 ) return
if ( verb ) write( 0, * ) 'Finite fault source'
loop: do ii = 1, ff_np
  i = ( tm - ff_tm0(ii) ) / ff_dt(ii) + 1.5
  if ( i < 1 .or. i >= ff_nt(ii) ) cycle loop
  t = ff_tm0(ii) + ff_dt(ii) * ( i - 1 )
  h = ( t - tm ) / ff_dt(ii)
  su = h * ff_su(ii,i,:) + ( 1. - h ) * ff_su(ii,i+1,:)
  nhat = ff_nhat(ii,:)
  j = ff_x(ii,1) + 0.5 - nnoff(1)
  k = ff_x(ii,2) + 0.5 - nnoff(2)
  l = ff_x(ii,3) + 0.5 - nnoff(3)
  w1(j,k,l,:) = w1(j,k,l,:) + su * nhat
  w2(j,k,l,1) = w2(j,k,l,1) + 0.5 * ( su(3) * nhat(2) + su(2) * nhat(3) )
  w2(j,k,l,2) = w2(j,k,l,2) + 0.5 * ( su(1) * nhat(3) + su(3) * nhat(1) )
  w2(j,k,l,3) = w2(j,k,l,3) + 0.5 * ( su(2) * nhat(1) + su(1) * nhat(2) )
end do loop
end subroutine

end module

