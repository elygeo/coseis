! Write output
module m_output
implicit none
contains

subroutine output( pass )
use m_globals
use m_collectiveio
use m_tictoc
integer, intent(in) :: pass
real, save :: amax, vmax, umax, wmax, &
  samax, svmax, sumax, tnmax, tsmax, slmax, tarrmax
integer, save, dimension(3) :: amaxi, vmaxi, umaxi, wmaxi, &
  samaxi, svmaxi, sumaxi, tnmaxi, tsmaxi, slmaxi, tarrmaxi
integer :: onpass, i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, ic, ir, iz
logical :: fault, dofault

if ( master ) call toc( 'Output' )

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
  umaxi = maxloc( s1 )
  wmaxi = maxloc( s2 )
  umax = s1(umaxi(1),umaxi(2),umaxi(3))
  wmax = s2(wmaxi(1),wmaxi(2),wmaxi(3))
  call pmaxloc( umax, umaxi, nnoff, 0 )
  call pmaxloc( wmax, wmaxi, nnoff, 0 )
  if ( master .and. umax > dx / 10. ) call toc( 'warning: u !<< dx' )
  if ( dofault ) then
    svmaxi = maxloc( f1 )
    sumaxi = maxloc( f2 )
    svmax = f1(svmaxi(1),svmaxi(2),svmaxi(3))
    sumax = f2(sumaxi(1),sumaxi(2),sumaxi(3))
    svmaxi(i) = ihypo(i)
    sumaxi(i) = ihypo(i)
    call pmaxloc( svmax, svmaxi, nnoff, i )
    call pmaxloc( sumax, sumaxi, nnoff, i )
  end if
case( 2 )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  pv = max( pv, s2 )
  amaxi = maxloc( s1 )
  vmaxi = maxloc( s2 )
  amax = s1(amaxi(1),amaxi(2),amaxi(3))
  vmax = s2(vmaxi(1),vmaxi(2),vmaxi(3))
  call pmaxloc( amax, amaxi, nnoff, 0 )
  call pmaxloc( vmax, vmaxi, nnoff, 0 )
  if ( dofault ) then
    samaxi = maxloc( f1 )
    tnmaxi = maxloc( abs( tn ) )
    tsmaxi = maxloc( ts )
    slmaxi = maxloc( sl )
    tarrmaxi = maxloc( tarr )
    samax = f1(samaxi(1),samaxi(2),samaxi(3))
    tnmax = abs( tn(tnmaxi(1),tnmaxi(2),tnmaxi(3)) )
    tsmax = ts(tsmaxi(1),tsmaxi(2),tsmaxi(3))
    slmax = sl(slmaxi(1),slmaxi(2),slmaxi(3))
    tarrmax = tarr(tarrmaxi(1),tarrmaxi(2),tarrmaxi(3))
    samaxi(i) = ihypo(i)
    tnmaxi(i) = ihypo(i)
    tsmaxi(i) = ihypo(i)
    slmaxi(i) = ihypo(i)
    tarrmaxi(i) = ihypo(i)
    call pmaxloc( samax, samaxi, nnoff, i )
    call pmaxloc( tnmax, tnmaxi, nnoff, i )
    call pmaxloc( tsmax, tsmaxi, nnoff, i )
    call pmaxloc( slmax, slmaxi, nnoff, i )
    call pmaxloc( tarrmax, tarrmaxi, nnoff, i )
  end if
case default; stop 'output pass'
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
case default; stop 'output fieldout'
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
  case default; stop 'output fieldout'
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 1 ) return

! Check for stop file
!if ( master ) then
!  inquire( file='stop', exist=test )
!  if ( test ) then
!    itcheck = it
!    nt = it
!  end if
!  ibroadcast( itcheck )
!  ibroadcast( nt )
!end if

! Metadata
if ( master ) then
  open(  9, file='currentstep.m', status='replace' )
  write( 9, * ) 'it =  ', it, ';'
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'stats/st', it, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'it       =  ', it,   ';'
  write( 9, * ) 't        =  ', t,    ';'
  write( 9, * ) 'dt       =  ', dt,   ';'
  write( 9, * ) 'amax     =  ', amax, ';'
  write( 9, * ) 'vmax     =  ', vmax, ';'
  write( 9, * ) 'umax     =  ', umax, ';'
  write( 9, * ) 'wmax     =  ', wmax, ';'
  write( 9, * ) 'amaxi    = [', amaxi - nnoff, '];'
  write( 9, * ) 'vmaxi    = [', vmaxi - nnoff, '];'
  write( 9, * ) 'umaxi    = [', umaxi - nnoff, '];'
  write( 9, * ) 'wmaxi    = [', wmaxi - nnoff, '];'
  if ( dofault ) then
    i = abs( faultnormal )
    i1 = ihypo
    i1(i) = 1
    j = i1(1)
    k = i1(2)
    l = i1(3)
    write( 9, * ) 'samax    =  ', samax,       ';'
    write( 9, * ) 'svmax    =  ', svmax,       ';'
    write( 9, * ) 'sumax    =  ', sumax,       ';'
    write( 9, * ) 'tnmax    =  ', tnmax,       ';'
    write( 9, * ) 'tsmax    =  ', tsmax,       ';'
    write( 9, * ) 'slmax    =  ', slmax,       ';'
    write( 9, * ) 'tarrmax  =  ', tarrmax,     ';'
    write( 9, * ) 'tarrhypo =  ', tarr(j,k,l), ';'
    write( 9, * ) 'work     =  ', work,       ';'
    write( 9, * ) 'efrac    =  ', efrac,       ';'
    write( 9, * ) 'samaxi   = [', samaxi   - nnoff, '];'
    write( 9, * ) 'svmaxi   = [', svmaxi   - nnoff, '];'
    write( 9, * ) 'sumaxi   = [', sumaxi   - nnoff, '];'
    write( 9, * ) 'tnmaxi   = [', tnmaxi   - nnoff, '];'
    write( 9, * ) 'tsmaxi   = [', tsmaxi   - nnoff, '];'
    write( 9, * ) 'slmaxi   = [', slmaxi   - nnoff, '];'
    write( 9, * ) 'tarrmaxi = [', tarrmaxi - nnoff, '];'
  end if
  close( 9 )              
end if

end subroutine

end module

