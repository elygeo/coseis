! Write output
module m_output
implicit none
contains

! Write integer binary timeseries
subroutine iwrite( filename, i, ir )
character(*), intent(in) :: filename
integer, intent(in) :: i, ir
integer :: reclen
inquire( iolength=reclen ) i
open( 1, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct' )
write( 1, rec=ir ) i
close( 1 )
end subroutine

! Write real binary timeseries
subroutine rwrite( filename, r, ir )
character(*), intent(in) :: filename
real, intent(in) :: r
integer, intent(in) :: ir
integer :: reclen
inquire( iolength=reclen ) r
open( 1, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct' )
write( 1, rec=ir ) r
close( 1 )
end subroutine

! Timing
subroutine tictoc( filename, ir )
character(*), intent(in), optional :: filename
integer, intent(in), optional :: ir
integer, save :: clock0, clock1, clockrate, clockmax
integer :: clock2
real :: t
if ( .not. present( ir ) ) then
  call system_clock( clock0, clockrate, clockmax )
else
  call system_clock( clock2 )
  t = real( clock2 - clock0 ) / real( clockrate )
  if ( t < 0. ) t = real( clock2 - clock0 + clockmax ) / real( clockrate ) 
  call rwrite( '00/wt_' // filename, t, ir )
  t = real( clock2 - clock1 ) / real( clockrate )
  if ( t < 0. ) t = real( clock2 - clock1 + clockmax ) / real( clockrate ) 
  call rwrite( '00/wdt_' // filename, t, ir )
  clock1 = clock2
end if
end subroutine

! Main output routine
subroutine output( pass )
use m_globals
use m_collectiveio
integer, intent(in) :: pass
real :: r1, r2
integer :: onpass, i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, ic, ir, iz
logical :: fault, dofault

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Magnitudes
select case( pass )
case( 1 )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff, 0 )
  i1 = i1 - nnoff
  i2 = i2 - nnoff
  if ( master .and. r1 > dx / 10. ) print *, 'warning: u !<< dx'
  if ( master ) call rwrite( '00/umax',  r1,    it )
  if ( master ) call iwrite( '00/umaxj', i1(1), it )
  if ( master ) call iwrite( '00/umaxk', i1(2), it )
  if ( master ) call iwrite( '00/umaxl', i1(3), it )
  if ( master ) call rwrite( '00/wmax',  r2,    it )
  if ( master ) call iwrite( '00/wmaxj', i2(1), it )
  if ( master ) call iwrite( '00/wmaxk', i2(2), it )
  if ( master ) call iwrite( '00/wmaxl', i2(3), it )
  if ( dofault ) then
    call pmaxloc( r1, i1, f1, nn, nnoff, i )
    call pmaxloc( r2, i2, f2, nn, nnoff, i )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
    i1 = i1 - nnoff
    i2 = i2 - nnoff
    if ( master ) call rwrite( '00/svmax',  r1,    it )
    if ( master ) call iwrite( '00/svmaxj', i1(1), it )
    if ( master ) call iwrite( '00/svmaxk', i1(2), it )
    if ( master ) call iwrite( '00/svmaxl', i1(3), it )
    if ( master ) call rwrite( '00/sumax',  r2,    it )
    if ( master ) call iwrite( '00/sumaxj', i2(1), it )
    if ( master ) call iwrite( '00/sumaxk', i2(2), it )
    if ( master ) call iwrite( '00/sumaxl', i2(3), it )
  end if
case( 2 )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  pv = max( pv, s2 )
  call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff, 0 )
  i1 = i1 - nnoff
  i2 = i2 - nnoff
  if ( master ) call rwrite( '00/amax',  r1,    it )
  if ( master ) call iwrite( '00/amaxj', i1(1), it )
  if ( master ) call iwrite( '00/amaxk', i1(2), it )
  if ( master ) call iwrite( '00/amaxl', i1(3), it )
  if ( master ) call rwrite( '00/vmax',  r2,    it )
  if ( master ) call iwrite( '00/vmaxj', i2(1), it )
  if ( master ) call iwrite( '00/vmaxk', i2(2), it )
  if ( master ) call iwrite( '00/vmaxl', i2(3), it )
  if ( dofault ) then
    call pmaxloc( r1, i1, f1, nn, nnoff, i )
    call pmaxloc( r2, i2, sl, nn, nnoff, i )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
    i1 = i1 - nnoff
    i2 = i2 - nnoff
    if ( master ) call rwrite( '00/samax',  r1,    it )
    if ( master ) call iwrite( '00/samaxj', i1(1), it )
    if ( master ) call iwrite( '00/samaxk', i1(2), it )
    if ( master ) call iwrite( '00/samaxl', i1(3), it )
    if ( master ) call rwrite( '00/slmax',  r2,    it )
    if ( master ) call iwrite( '00/slmaxj', i2(1), it )
    if ( master ) call iwrite( '00/slmaxk', i2(2), it )
    if ( master ) call iwrite( '00/slmaxl', i2(3), it )
    call pminloc( r1, i1, tn, nn, nnoff, i )
    call pmaxloc( r2, i2, tn, nn, nnoff, i )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
    i1 = i1 - nnoff
    i2 = i2 - nnoff
    if ( master ) call rwrite( '00/tnmin',  r1,    it )
    if ( master ) call iwrite( '00/tnminj', i1(1), it )
    if ( master ) call iwrite( '00/tnmink', i1(2), it )
    if ( master ) call iwrite( '00/tnminl', i1(3), it )
    if ( master ) call rwrite( '00/tnmax',  r2,    it )
    if ( master ) call iwrite( '00/tnmaxj', i2(1), it )
    if ( master ) call iwrite( '00/tnmaxk', i2(2), it )
    if ( master ) call iwrite( '00/tnmaxl', i2(3), it )
    call pmaxloc( r1, i1, ts,   nn, nnoff, i )
    call pmaxloc( r2, i2, tarr, nn, nnoff, i )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
    i1 = i1 - nnoff
    i2 = i2 - nnoff
    if ( master ) call rwrite( '00/tsmax',  r1,    it )
    if ( master ) call iwrite( '00/tsmaxj', i1(1), it )
    if ( master ) call iwrite( '00/tsmaxk', i1(2), it )
    if ( master ) call iwrite( '00/tsmaxl', i1(3), it )
    if ( master ) call rwrite( '00/tarrmax',  r2,    it )
    if ( master ) call iwrite( '00/tarrmaxj', i2(1), it )
    if ( master ) call iwrite( '00/tarrmaxk', i2(2), it )
    if ( master ) call iwrite( '00/tarrmaxl', i2(3), it )
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
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3; onpass = 1
case( 'w'    ); nc = 6; onpass = 1
case( 'am'   );
case( 'vm'   );
case( 'pv'   );
case( 'um'   ); onpass = 1
case( 'wm'   ); onpass = 1
case( 'nhat' ); fault = .true.; nc = 3
case( 't0'   ); fault = .true.; nc = 3
case( 'mus'  ); fault = .true.
case( 'mud'  ); fault = .true.
case( 'dc'   ); fault = .true.
case( 'co'   ); fault = .true.
case( 'sa'   ); fault = .true.; nc = 3
case( 'sv'   ); fault = .true.; nc = 3; onpass = 1
case( 'su'   ); fault = .true.; nc = 3; onpass = 1
case( 'ts'   ); fault = .true.; nc = 3
case( 't'    ); fault = .true.; nc = 3
case( 'sam'  ); fault = .true.
case( 'svm'  ); fault = .true.; onpass = 1
case( 'sum'  ); fault = .true.; onpass = 1
case( 'tnm'  ); fault = .true.
case( 'tsm'  ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'f'    ); fault = .true.
case( 'psv'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default
  print *, 'error: unknown output field: ', fieldout(iz)
  stop
end select

! Select pass
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i1l = max( i1, i1node )
i2l = min( i2, i2node )
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i1l(i) = 1
  i2l(i) = 1
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
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'mr'   ); call scalario( 'w', str, mr,       ir, i1, i2, i1l, i2l, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,       ir, i1, i2, i1l, i2l, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,      ir, i1, i2, i1l, i2l, iz )
  case( 'y'    ); call scalario( 'w', str, y,        ir, i1, i2, i1l, i2l, iz )
  case( 'a'    ); call vectorio( 'w', str, w1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'v'    ); call vectorio( 'w', str, v,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'u'    ); call vectorio( 'w', str, u,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( 'w', str, w1, ic,   ir, i1, i2, i1l, i2l, iz )
   if ( ic > 3 )  call vectorio( 'w', str, w2, ic-3, ir, i1, i2, i1l, i2l, iz )
  case( 'am'   ); call scalario( 'w', str, s1,       ir, i1, i2, i1l, i2l, iz )
  case( 'vm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i1l, i2l, iz )
  case( 'pv'   ); call scalario( 'w', str, pv,       ir, i1, i2, i1l, i2l, iz )
  case( 'um'   ); call scalario( 'w', str, s1,       ir, i1, i2, i1l, i2l, iz )
  case( 'wm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i1l, i2l, iz )
  case( 'nhat' ); call vectorio( 'w', str, nhat, ic, ir, i1, i2, i1l, i2l, iz )
  case( 't0'   ); call vectorio( 'w', str, t0,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,      ir, i1, i2, i1l, i2l, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,      ir, i1, i2, i1l, i2l, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,       ir, i1, i2, i1l, i2l, iz )
  case( 'co'   ); call scalario( 'w', str, co,       ir, i1, i2, i1l, i2l, iz )
  case( 'sa'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sv'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'su'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'ts'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 't'    ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sam'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'svm'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'sum'  ); call scalario( 'w', str, f2,       ir, i1, i2, i1l, i2l, iz )
  case( 'tnm'  ); call scalario( 'w', str, tn,       ir, i1, i2, i1l, i2l, iz )
  case( 'tsm'  ); call scalario( 'w', str, ts,       ir, i1, i2, i1l, i2l, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,       ir, i1, i2, i1l, i2l, iz )
  case( 'f'    ); call scalario( 'w', str, f2,       ir, i1, i2, i1l, i2l, iz )
  case( 'psv'  ); call scalario( 'w', str, psv,      ir, i1, i2, i1l, i2l, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i1l, i2l, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i1l, i2l, iz )
  case default
    print *, 'error2: unknown output field: ', fieldout(iz)
    stop
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 1 ) return

! Metadata
if ( master ) then
  open(  1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
  call iwrite( '00/it', it, it )
  call rwrite( '00/t',  t,  it )
  if ( dofault ) then
    i = abs( faultnormal )
    i1 = ihypo
    i1(i) = 1
    j = i1(1)
    k = i1(2)
    l = i1(3)
    call rwrite( '00/tarrhypo', tarr(j,k,l), it )
    call rwrite( '00/work',     work,        it )
    call rwrite( '00/efrac',    efrac,       it )
  end if
  close( 9 )              
end if

end subroutine

end module

