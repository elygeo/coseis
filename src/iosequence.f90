! Output routines
module m_io_sequence
implicit none
type t_io
  character(4) :: field
  character(2) :: mode
  integer :: i1(4), i2(4), i3(4), i4(4), nc, nb, fh(6)
  real :: x1(3), x2(3), val
  real, allocatable :: buff(:,:,:,:,:)
  type( t_io ), pointer :: next
end type t_io
real, pointer :: f(:,:,:)
type( t_io ), pointer :: pio0, prev, curr
integer, private :: fh
contains

! Initialize output
subroutine io_seq_init
use m_globals
use m_collective
use m_util
real :: rout
integer :: i1(3), i2(3), di(3)
type( t_io ), pointer :: curr, prev

! Loop over output zones
prev => pio0
dosequence: do while( associated( prev%next ) )
curr => prev%next

! Spatial indices
i1 = curr%i1(1:3) - nnoff
i2 = curr%i2(1:3) - nnoff
di = curr%di(1:3)
select case( curr%mode(2) )
case( 'x' )
  rout = huge( rout )
  call radius( s2, w1, p%x1, i1core, i2core )
  call scalarsethalo( s2, rout, i1core, i2core )
  call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  i2 = i1
  if ( rout > dx * dx ) then
    prev%next = curr%next
    cycle dosequence
  end if
case( 'X' )
  rout = huge( rout )
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  call radius( s2, w2, p%x1, i1, i2 )
  call scalarsethalo( s2, rout, i1, i2 )
  call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  i2 = i1
  if ( rout > dx * dx ) then
    prev%next = curr%next
    cycle dosequence
  end if
end select

! Save indices and allocate buffer
curr%i1(1:3) = i1
curr%i2(1:3) = i2
where( i1 < i1core ) i1 = i1 + ( ( i1core - i1 - 1 ) / di + 1 ) * di
where( i2 > i2core ) i2 = i1 + (   i2core - i1     ) / di       * di
curr%i3(1:3) = i1
curr%i4(1:3) = i2
n = i2 - i1 + 1
allocate( curr%buff(n(1),n(2),n(3),curr%nb,nc) )

! Initialize file handle
curr%fh = 0

end do dosequence
end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine stats( pass )
use m_globals
use m_collective
use m_util
use m_debug_out
integer, intent(in) :: pass
integer :: i1(4), i2(4), i3(4), i4(4), id(4), i, j, k, l, ic, iz, id, mpio
logical :: dofault, fault, cell
real :: rr
real, pointer :: f(:,:,:)
type( t_io ), pointer :: o


if ( master .and. ( it == 0 .or. debug == 2 ) ) write( 0, '(a,i2)' ) ' Output pass', pass
if ( debug > 2 ) call debug_out( pass )

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3root(i) ) dofault = .true.
end if

end subroutine

! Loop over output zones
iz = 0
o => out0
dosequence: do while( associated( p%next ) )
o => p%next
iz = iz + 1

! Pass
if ( p%di(4) < 1 .or. pass /= p%pass ) cycle dosequence

! Indices
i1 = p%i1
i2 = p%i2
i3 = p%i3
i4 = p%i4
di = p%di

! Peak velocity calculation
if ( p%field == 'pv2' .and. all( i3(1:3) <= i4(1:3) ) ) then
  if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3(1:3), i4(1:3) )
  do l = i3(3), i4(3)
  do k = i3(2), i4(2)
  do j = i3(1), i4(1)
    pv(j,k,l) = max( pv(j,k,l), s1(j,k,l) )
  end do
  end do
  end do
end if

! Time indices
if ( it < p%i1(4) .or. it > p%i2(4) ) cycle dosequence
if ( modulo( it - p%i1(4), p%di(4) ) /= 0 ) cycle dosequence
p%i4(4) = it
i4(4) = it

! Test if any thing to do on this processor, can't cycle yet though
! because all processors have to call mpi_split
if ( any( i3(1:3) > i4(1:3) ) ) then
  p%i1(4) = nt + 1
  if ( all( i1 == i2 ) ) cycle dosequence
end if

! Fault plane
mpio = mpout * 4
if ( p%fault ) then
  i = abs( faultnormal )
  mpio = mpout * i
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Compute magnitudes and buffer output
if ( all( i3 <= i4 ) ) then
  if ( modulo( it, itstats ) /= 0 ) then
    select case( p%field )
    case( 'vm2' ); call vectornorm( s1, vv, i3(1:3), i4(1:3) )
    case( 'um2' ); call vectornorm( s1, uu, i3(1:3), i4(1:3) )
    case( 'wm2' ); call tensornorm( s2, w1, w2, i3(1:3), i4(1:3) )
    case( 'am2' ); call vectornorm( s2, w1, i3(1:3), i4(1:3) )
    end select
  end if
  i = ( it - i3(4) ) / di(4)
  select case( p%mode(1) )
  case( 's' )
    if ( p%mode(2) == 'c' ) then
      !call cube( f, w2, i3, i4, p%x1, p%x2, p%val ) FIXME
    else
      f(i1(1):i2(1),i1(2):i2(2),i1(3):i2(3)) = p%val
    end if
  case( 'r' )
    f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3)) = p%buff(:,:,:,i,1)
  case( 'w' )
    p%buff(:,:,:,i,1) = f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3))
  end select
end if

! Disk I/O
i1 = ( i1 - i3 ) / di + 1
i2 = ( i2 - i3 ) / di + 1
i4 = ( i4 - i3 ) / di + 1
i3 = 1
if ( i4(4) == p%nb .or. i4(4) == i2(4) ) then
  do ic = 1, p%nc
    id = 64 + 6 * ( iz - 1 ) + ic
    write( str, '(a,i2.2,a)' ) 'out/', iz, p%field
    if ( p%nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
    if ( mpout == 0 ) then
      i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
      if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
    end if
    call rio4( id, mpio, p%buff, i1, i2, i3, i4, i4 )
  end do
  p%i3(4) = it + di(4)
  p%i4(4) = 0
end if

end do dosequence

! Iteration counter
if ( master .and. pass == 2 .and. ( modulo( it, itio ) == 0 .or. it == nt ) ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

