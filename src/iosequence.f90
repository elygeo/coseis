! Output routines
module m_io_sequence
implicit none
type t_io
  character(4) :: field
  character(8) :: tfunc
  character(2) :: mode
  integer :: i1(4), i2(4), i3(4), i4(4), nb, fh
  real :: x1(3), x2(3), val, t
  real, allocatable :: buff(:,:,:,:)
  type( t_io ), pointer :: next
end type t_io
type( t_io ), pointer :: pio0, pprev, p
integer, private :: fh
contains

! Initialize output
subroutine io_seq_init
use m_globals
use m_collective
use m_util
real :: rout
integer :: i1(3), i2(3), di(3)

! Loop over output zones
pprev => pio0
dosequence: do while( associated( pprev%next ) )
p => pprev%next

! Spatial indices
i1 = p%i1(1:3) - nnoff
i2 = p%i2(1:3) - nnoff
di = p%di(1:3)
select case( p%mode(2) )
case( 'x' )
  p%mode(2) = 'i'
  rout = huge( rout )
  call radius( s2, w1, p%x1, i1core, i2core )
  call scalarsethalo( s2, rout, i1core, i2core )
  call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  i2 = i1
  if ( rout > dx * dx ) then
    pprev%next => p%next
    deallocate( p )
    cycle dosequence
  end if
case( 'X' )
  p%mode(2) = 'i'
  rout = huge( rout )
  i1 = max( i1core, i1cell )
  i2 = min( i2core, i2cell )
  call radius( s2, w2, p%x1, i1, i2 )
  call scalarsethalo( s2, rout, i1, i2 )
  call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  i2 = i1
  if ( rout > dx * dx ) then
    pprev%next => p%next
    deallocate( p )
    cycle dosequence
  end if
end select

! Save indices
p%i1(1:3) = i1
p%i2(1:3) = i2
where( i1 < i1core ) i1 = i1 + ( ( i1core - i1 - 1 ) / di + 1 ) * di
where( i2 > i2core ) i2 = i1 + (   i2core - i1     ) / di       * di
p%i3(1:3) = i1
p%i4(1:3) = i2
p%fh = 0

end do dosequence
end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine ioseq( pass, p, cell, f )
use m_globals
use m_collective
use m_util
use m_debug_out
character(3), intent(in) :: pass
type( t_io ), pointer, intent(in) :: p
logical, intent(in) :: cell
real, pointer, intent(in) :: f(:,:,:)
integer :: i1(4), i2(4), i3(4), i4(4), id(4), i, j, k, l, ic, iz, id, mpio
real :: rr

! TODO allocate dellallocate

! FIXME debug
n = i2 - i1 + 1
allocate( p%buff(n(1),n(2),n(3),p%nb) )

i1 = p%i1
i2 = p%i2
i3 = p%i3
i4 = p%i4
di = p%di

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
    f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3)) = p%val
  case( 'c' )
! FIXME 
    call cube( f, w1, i3, i4, p%x1, p%x2, p%val )
  case( 'C' )
! FIXME
    call cube( f, w2, i3, i4, p%x1, p%x2, p%val )
  case( 'r' )
    f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3)) = p%buff(:,:,:,i,1)
  case( 'w' )
    p%buff(:,:,:,i,1) = f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3))
  case( 't' )
    select case( p%tfunc )
    case( 'delta'  )
      if ( it == 0 ) ft = 1.
    case( 'brune' )
      ft = exp( -tm / p%t ) * tm / ( p%t * p%t )
    case( 'ricker1' )
      t = tm - p%t
      ft = t * exp( -2. * ( pi * t / p%t ) ** 2. )
    case( 'ricker2' )
      t = ( pi * ( tm - p%t ) / p%t ) ** 2.
      ft = ( 1. - 2. * t ) * exp( -t )
    case default 
      write( 0, * ) 'invalid tfunc: ', trim( p%tfunc )
      stop
    end select
    f(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3)) = ft * p%val
  end select
end if

! Disk I/O
i1 = ( i1 - i3 ) / di + 1
i2 = ( i2 - i3 ) / di + 1
i4 = ( i4 - i3 ) / di + 1
i3 = 1
if ( i4(4) == p%nb .or. i4(4) == i2(4) ) then
  id = 64 + 6 * ( iz - 1 ) + ic
  write( str, '(a,i2.2,a)' ) 'out/', iz, p%field
  if ( mpout == 0 ) then
    i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
    if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
  end if
  call rio4( id, mpio, p%buff, i1, i2, i3, i4, i4 )
  p%i3(4) = it + di(4)
  p%i4(4) = 0
end if

! Iteration counter
if ( master .and. pass == 2 .and. ( modulo( it, itio ) == 0 .or. it == nt ) ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

