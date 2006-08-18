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
real :: r1, r2
integer :: onpass, i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, ic, ir, iz
logical :: fault, dofault

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output and write stats
if ( master ) call rwrite( 'stats/t', t, it )
i1 = i1node
i2 = i1node
i1(ifn) = 1
i2(ifn) = 1 
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
select case( pass )
case( 1 )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff, 0 )
  if ( master .and. r1 > dx / 10. ) write( 0, * ) 'warning: u !<< dx'
  if ( master ) call stats( r1, i1-nnoff, 'umax', it )
  if ( master ) call stats( r2, i2-nnoff, 'wmax', it )
  if ( dofault ) then
    t2 = v(j3:j4,k3:k4,l3:l4,:) - v(j1:j2,k1:k2,l1:l2,:)
    f2 = sqrt( sum( t2 * t2, 4 ) )
    psv = max( psv, f2 )
    sl = sl + dt * f2
    call pmaxloc( r1, i1, s1, nn, nnoff, 0 )
    i1(i) = ihypo(i)
    if ( master ) call stats( r1, i1-nnoff, 'svmax', it )
    if ( it == 1 ) then
      tn = sum( t0 * nhat, 4 )
      do i = 1, 3
        t2(:,:,:,i) = tn * nhat(:,:,:,i)
      end do
      t3 = t0 - t2
      ts = sqrt( sum( t3 * t3, 4 ) )
    end if
    if ( svtol > 0. ) then
      where ( f1 >= svtol .and. trup > 1e8 )
        trup = t - dt * ( .5 + ( svtol - f1 ) / ( svm - f1 ) )
      end where
      where ( f1 >= svtol )
        tarr = 1e9
      end where
      where ( f1 < svtol .and. svm >= svtol )
        tarr = t - dt * ( .5 + ( svtol - f1 ) / ( svm - f1 ) )
      end where
    end if
    call pmaxloc( r1, i1, f1,   nn, nnoff, i, )
    call pmaxloc( r2, i2, tarr, nn, nnoff, i, )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
    if ( master ) call stats( r1, i1-nnoff, 'samax',   it )
    if ( master ) call stats( r2, i2-nnoff, 'tarrmax', it )
  end if
case( 2 )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  call pmaxloc( r1, i1, s1, nn, nnoff 0 )
  call pmaxloc( r2, i2, s2, nn, nnoff 0 )
  if ( master ) call stats( r1, s1, 'amax', it )
  if ( master ) call stats( rr, s2, 'vmax', it )
  pv = max( pv, s2 )
  if ( dofault ) then
    tn = sum( t1 * nhat, 4 )
    do i = 1, 3
      t2(:,:,:,i) = tn * nhat(:,:,:,i)
    end do
    t3 = t1 - t2
    ts = sqrt( sum( t3 * t3, 4 ) )

    call pminloc( r1, i1, tn, nn, nnoff 0 ); i1(ifn) = ihypo(ifn)
    call pmaxloc( r2, i2, tn, nn, nnoff 0 ); i1(ifn) = ihypo(ifn)
    if ( master ) call stats( r1, i1-nnoff, 'tnmin', it )
    if ( master ) call stats( r2, i2-nnoff, 'tnmax', it )
    call pmaxloc( r1, i1, t2, nn, nnoff 0 ); i1(ifn) = ihypo(ifn)
    if ( master ) call stats( r1, i1-nnoff, 'tnmax', it )

    t1 = u(j3:j4,k3:k4,l3:l4,:) - u(j1:j2,k1:k2,l1:l2,:)
    f1 = sqrt( sum( t1 * t1, 4 ) )

    r = .5 * sum( sum( ( t0(j1:j2,k1:k2,l1:l2,:) + t3(j1:j2,k1:k2,l1:l2,:) ) &
      * t1(j1:j2,k1:k2,l1:l2,:), 4 ) * area(j1:j2,k1:k2,l1:l2) )
    call psum( work, r, ifn )

    r = dt * sum( sum( t1(j1:j2,k1:k2,l1:l2,:) * t3(j1:j2,k1:k2,l1:l2,:), 4 ) &
      * area(j1:j2,k1:k2,l1:l2) )
    call psum( de, r, ifn )
    efrac = efrac + de
    if ( master ) call rwrite( 'stats/work', work, it )
    if ( master ) call rwrite( 'stats/efrac', efrac, it )
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
case( 'tn'   ); fault = .true.
case( 'tsm'  ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'f'    ); fault = .true.
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
  case( 'ts0'  ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'tsm0' ); call vectorio( 'w', str, ts,       ir, i1, i2, i1l, i2l, iz )
  case( 'tn0'  ); call vectorio( 'w', str, tn,       ir, i1, i2, i1l, i2l, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,      ir, i1, i2, i1l, i2l, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,      ir, i1, i2, i1l, i2l, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,       ir, i1, i2, i1l, i2l, iz )
  case( 'co'   ); call scalario( 'w', str, co,       ir, i1, i2, i1l, i2l, iz )
  case( 'sa'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sv'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'su'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 't'    ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'ts'   ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sam'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'svm'  ); call scalario( 'w', str, f2,       ir, i1, i2, i1l, i2l, iz )
  case( 'sum'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'tn'   ); call scalario( 'w', str, tn,       ir, i1, i2, i1l, i2l, iz )
  case( 'tsm'  ); call scalario( 'w', str, ts,       ir, i1, i2, i1l, i2l, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,       ir, i1, i2, i1l, i2l, iz )
  case( 'psv'  ); call scalario( 'w', str, psv,      ir, i1, i2, i1l, i2l, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i1l, i2l, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i1l, i2l, iz )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 1 ) return

! Metadata
if ( master ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
  if ( dofault ) then
    i = abs( faultnormal )
    i1 = ihypo
    i1(i) = 1
    j = i1(1)
    k = i1(2)
    l = i1(3)
    call rwrite( 'stats/tarrhypo', tarr(j,k,l), it )
  end if
  close( 9 )              
end if

end subroutine

end module

