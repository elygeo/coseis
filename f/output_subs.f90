! Write output
module m_output_subs
implicit none
contains

! Write integer binary timeseries
subroutine iwrite( filename, val, it )
character(*), intent(in) :: filename
integer, intent(in) :: val, it
integer :: i
inquire( iolength=i ) val
if ( it == 1 ) then
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
else
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
end if
write( 1, rec=it ) val
close( 1 )
end subroutine

! Write real binary timeseries
subroutine rwrite( filename, val, it )
character(*), intent(in) :: filename
real, intent(in) :: val
integer, intent(in) :: it
integer :: i
inquire( iolength=i ) val
if ( it == 1 ) then
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
else
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
end if
write( 1, rec=it ) val
close( 1 )
end subroutine

! Write stats
subroutine stats( rr, ii, filename, it )
use m_collective
real, intent(in) :: rr
character(*), intent(in) :: filename
integer, intent(in) :: ii(3), it
call rwrite( 'stats/' // filename, rr, it )
call iwrite( 'stats/' // filename // '1', ii(1), it )
call iwrite( 'stats/' // filename // '2', ii(2), it )
call iwrite( 'stats/' // filename // '3', ii(3), it )
end subroutine

! Write timing info
subroutine clock( filename, it )
character(*), intent(in), optional :: filename
integer, intent(in), optional :: it
integer, save :: clock0, clock1, clockrate, clockmax
integer :: clock2
real :: tt, dt
if ( .not. present( it ) ) then
  call system_clock( clock0, clockrate, clockmax )
  clock1 = clock0
else
  call system_clock( clock2 )
  tt = real( clock2 - clock0 ) / real( clockrate )
  dt = real( clock2 - clock1 ) / real( clockrate )
  if ( tt < 0. ) tt = real( clock2 - clock0 + clockmax ) / real( clockrate ) 
  if ( dt < 0. ) dt = real( clock2 - clock1 + clockmax ) / real( clockrate ) 
  call rwrite( 'clock/tt' // filename, tt, it )
  call rwrite( 'clock/dt' // filename, dt, it )
  clock1 = clock2
end if
end subroutine

! Output properties
subroutine outprops( field, nc, onpass, fault, cell )
character(*), intent(in) :: field
integer, intent(out) :: nc, onpass
logical, intent(out) :: fault, cell
nc = 1
fault = .false.
onpass = 2
cell = .false.
select case( field )
case( 'x'    ); onpass = 0; nc = 3
case( 'rho'  ); onpass = 0
case( 'mu'   ); onpass = 0; cell = .true.
case( 'lam'  ); onpass = 0; cell = .true.
case( 'v'    ); onpass = 1; nc = 3
case( 'u'    ); nc = 3
case( 'w'    ); onpass = 1; nc = 6; cell = .true.
case( 'a'    ); nc = 3
case( 'vm'   ); onpass = 1
case( 'um'   )
case( 'wm'   ); onpass = 1; cell = .true.
case( 'am'   )
case( 'pv'   )
case( 'nhat' ); fault = .true.; onpass = 0; nc = 3
case( 'ts0'  ); fault = .true.; onpass = 0; nc = 3
case( 'tsm0' ); fault = .true.; onpass = 0
case( 'tn0'  ); fault = .true.; onpass = 0
case( 'mus'  ); fault = .true.; onpass = 0
case( 'mud'  ); fault = .true.; onpass = 0
case( 'dc'   ); fault = .true.; onpass = 0
case( 'co'   ); fault = .true.; onpass = 0
case( 'sv'   ); fault = .true.; onpass = 1; nc = 3
case( 'su'   ); fault = .true.; onpass = 1; nc = 3
case( 'ts'   ); fault = .true.; nc = 3
case( 'sa'   ); fault = .true.; nc = 3
case( 'svm'  ); fault = .true.; onpass = 1
case( 'sum'  ); fault = .true.; onpass = 1
case( 'tsm'  ); fault = .true.
case( 'sam'  ); fault = .true.
case( 'tn'   ); fault = .true.
case( 'fr'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'psv'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default
  write( 0, * ) 'error: unknown output field: ', field
  stop
end select
end subroutine

end module

