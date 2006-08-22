! Write output
module m_output
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
real, intent(out) :: rr
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

! Main output routine
subroutine output( pass )
use m_globals
use m_collectiveio
integer, intent(in) :: pass
real :: r1, r2, r3, r4
integer :: i1(3), i2(3), i3(3), i4(3), i, onpass, nc, ic, ir, iz
logical :: fault, dofault

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output and write stats
if ( master ) call rwrite( 'stats/t', t, it )
select case( pass )
case( 1 )
  s1 = sqrt( sum( v * v, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  pv = max( pv, s2 )
  call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff, 0 )
  if ( master ) then
    call stats( r1, i1-nnoff, 'vmax', it )
    call stats( r2, i2-nnoff, 'wmax', it )
  end if
  if ( dofault ) then
    call pmaxloc( r1, i1, f1,   nn, nnoff, i ); i1(i) = ihypo(i)
    call pmaxloc( r2, i2, f2,   nn, nnoff, i ); i2(i) = ihypo(i)
    call pmaxloc( r3, i3, sl,   nn, nnoff, i ); i3(i) = ihypo(i)
    call pmaxloc( r4, i4, tarr, nn, nnoff, i ); i4(i) = ihypo(i)
    if ( master ) then
      call stats( r1, i1-nnoff, 'svmax',   it )
      call stats( r2, i2-nnoff, 'sumax',   it )
      call stats( r3, i3-nnoff, 'slmax',   it )
      call stats( r4, i4-nnoff, 'tarrmax', it )
      i1 = ihypo
      i1(i) = 1
      call rwrite( 'stats/tarrhypo', tarr(i1(1),i1(2),i1(3)), it )
    end if
  end if
case( 2 )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) )
  call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff, 0 )
  if ( master ) then
    call stats( r1, i1-nnoff, 'umax', it )
    call stats( r2, i2-nnoff, 'amax', it )
    if ( r1 > dx / 10. ) write( 0, * ) 'warning: u !<< dx'
  end if
  if ( dofault ) then
    call pminloc( r1, i1, tn, nn, nnoff, i ); i1(ifn) = ihypo(ifn)
    call pmaxloc( r2, i2, tn, nn, nnoff, i ); i2(ifn) = ihypo(ifn)
    call pmaxloc( r3, i3, ts, nn, nnoff, i ); i3(ifn) = ihypo(ifn)
    call pmaxloc( r4, i4, f2, nn, nnoff, i ); i4(ifn) = ihypo(ifn)
    if ( master ) then
      call stats( r1, i1-nnoff, 'tnmin', it )
      call stats( r2, i2-nnoff, 'tnmax', it )
      call stats( r3, i3-nnoff, 'tsmax', it )
      call stats( r4, i4-nnoff, 'samax', it )
      call rwrite( 'stats/estrain', estrain, it )
      call rwrite( 'stats/efric', efric, it )
    end if
  end if
end select

doiz: do iz = 1, nout !--------------------------------------------------------!

if ( ditout(iz) == 0 ) then
  if ( it > 1 ) cycle doiz
else
  if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz
end if

! Properties
nc = 1
fault= .false.
onpass = 2
select case( fieldout(iz) )
case( 'x'    ); nc = 3
case( 'mr'   );
case( 'mu'   );
case( 'lam'  );
case( 'y'    );
case( 'v'    ); nc = 3; onpass = 1
case( 'u'    ); nc = 3
case( 'w'    ); nc = 6; onpass = 1
case( 'a'    ); nc = 3
case( 'vm'   ); onpass = 1
case( 'um'   )
case( 'wm'   ); onpass = 1
case( 'am'   );
case( 'pv'   );
case( 'nhat' ); fault = .true.; nc = 3
case( 'ts0'  ); fault = .true.; nc = 3; onpass = 1
case( 'tsm0' ); fault = .true.; onpass = 1
case( 'tn0'  ); fault = .true.; onpass = 1
case( 'mus'  ); fault = .true.
case( 'mud'  ); fault = .true.
case( 'dc'   ); fault = .true.
case( 'co'   ); fault = .true.
case( 'sv'   ); fault = .true.; nc = 3; onpass = 1
case( 'su'   ); fault = .true.; nc = 3; onpass = 1
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
  write( 0, * ) 'error: unknown output field: ', fieldout(iz)
  stop
end select

! Select pass
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i3 = max( i1, i1node )
i4 = min( i2, i2node )
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Binary output
do ic = 1, nc
  ir = 1
  write( str, '(i2.2,a,a,i1)' ) iz, '/', trim( fieldout(iz) ), ic
  if ( ditout(iz) > 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = it / ditout(iz)
  else
    write( str, '(i2.2,a,a,i1,i6.6)' ) iz, '/', trim( fieldout(iz) ), ic, it
  end if
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i3, i4, iz )
  case( 'mr'   ); call scalario( 'w', str, mr,       ir, i1, i2, i3, i4, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,       ir, i1, i2, i3, i4, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,      ir, i1, i2, i3, i4, iz )
  case( 'y'    ); call scalario( 'w', str, y,        ir, i1, i2, i3, i4, iz )
  case( 'v'    ); call vectorio( 'w', str, v,    ic, ir, i1, i2, i3, i4, iz )
  case( 'u'    ); call vectorio( 'w', str, u,    ic, ir, i1, i2, i3, i4, iz )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( 'w', str, w1, ic,   ir, i1, i2, i3, i4, iz )
   if ( ic > 3 )  call vectorio( 'w', str, w2, ic-3, ir, i1, i2, i3, i4, iz )
  case( 'a'    ); call vectorio( 'w', str, w1,   ic, ir, i1, i2, i3, i4, iz )
  case( 'vm'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'um'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'wm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
  case( 'am'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
  case( 'pv'   ); call scalario( 'w', str, pv,       ir, i1, i2, i3, i4, iz )
  case( 'nhat' ); call vectorio( 'w', str, nhat, ic, ir, i1, i2, i3, i4, iz )
  case( 'ts0'  ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i3, i4, iz )
  case( 'tsm0' ); call scalario( 'w', str, ts,       ir, i1, i2, i3, i4, iz )
  case( 'tn0'  ); call scalario( 'w', str, tn,       ir, i1, i2, i3, i4, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,      ir, i1, i2, i3, i4, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,      ir, i1, i2, i3, i4, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,       ir, i1, i2, i3, i4, iz )
  case( 'co'   ); call scalario( 'w', str, co,       ir, i1, i2, i3, i4, iz )
  case( 'sv'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i3, i4, iz )
  case( 'su'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i3, i4, iz )
  case( 'ts'   ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i3, i4, iz )
  case( 'sa'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i3, i4, iz )
  case( 'svm'  ); call scalario( 'w', str, f1,       ir, i1, i2, i3, i4, iz )
  case( 'sum'  ); call scalario( 'w', str, f2,       ir, i1, i2, i3, i4, iz )
  case( 'tsm'  ); call scalario( 'w', str, ts,       ir, i1, i2, i3, i4, iz )
  case( 'sam'  ); call scalario( 'w', str, f2,       ir, i1, i2, i3, i4, iz )
  case( 'tn'   ); call scalario( 'w', str, tn,       ir, i1, i2, i3, i4, iz )
  case( 'fr'   ); call scalario( 'w', str, f1,       ir, i1, i2, i3, i4, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,       ir, i1, i2, i3, i4, iz )
  case( 'psv'  ); call scalario( 'w', str, psv,      ir, i1, i2, i3, i4, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i3, i4, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i3, i4, iz )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
end do

end do doiz !------------------------------------------------------------------!

! Interation counter
if ( master .and. pass == 2 ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

