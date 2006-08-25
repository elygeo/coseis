! Write output
module m_output
implicit none
contains

subroutine output( pass )
use m_globals
use m_output_subs
use m_collectiveio
use m_bc
integer, intent(in) :: pass
real :: r1, r2, r3, r4
integer :: i1(3), i2(3), i3(3), i4(3), n(3), noff(3), i, onpass, nc, ic, ir, iz
logical :: dofault, fault, cell

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output and write stats
n = nn + 2 * nhalo
noff = nnoff - nhalo
select case( pass )
case( 1 )
  s1 = sqrt( sum( v * v, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  pv = max( pv, s1 )
  call sethalo( s1, -1., i1node, i2node )
  call sethalo( s2, -1., i1cell, i2cell )
  call pmaxloc( r1, i1, s1, n, noff, 0 )
  call pmaxloc( r2, i2, s2, n, noff, 0 )
  if ( master ) then
    call stats( r1, i1-nnoff, 'vmax', it )
    call stats( r2, i2-nnoff, 'wmax', it )
    call rwrite( 'stats/t', t, it )
  end if
  if ( dofault ) then
    call sethalo( f1, -1., i1node, i2node )
    call sethalo( f2, -1., i1node, i2node )
    call sethalo( tarr, -1., i1node, i2node )
    call pmaxloc( r1, i1, f1,   n, noff, i ); i1(i) = ihypo(i)
    call pmaxloc( r2, i2, f2,   n, noff, i ); i2(i) = ihypo(i)
    call pmaxloc( r3, i3, sl,   n, noff, i ); i3(i) = ihypo(i)
    call pmaxloc( r4, i4, tarr, n, noff, i ); i4(i) = ihypo(i)
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
  call sethalo( s1, -1., i1node, i2node )
  call sethalo( s2, -1., i1node, i2node )
  call pmaxloc( r1, i1, s1, n, noff, 0 )
  call pmaxloc( r2, i2, s2, n, noff, 0 )
  if ( master ) then
    call stats( r1, i1-nnoff, 'umax', it )
    call stats( r2, i2-nnoff, 'amax', it )
    if ( r1 > dx / 10. ) write( 0, * ) 'warning: u !<< dx', r1, dx
  end if
  if ( dofault ) then
    call sethalo( ts, -1., i1node, i2node )
    call sethalo( f2, -1., i1node, i2node )
    call pmaxloc( r1, i1, ts, n, noff, i ); i1(ifn) = ihypo(ifn)
    call pmaxloc( r2, i2, f2, n, noff, i ); i2(ifn) = ihypo(ifn)
    r3 = 2. * minval( tn ) - 1.
    call sethalo( tn, r3, i1node, i2node )
    call pmaxloc( r3, i3, tn, n, noff, i ); i3(ifn) = ihypo(ifn)
    r4 = 2. * r3 + 1.
    call sethalo( tn, r4, i1node, i2node )
    call pminloc( r4, i4, tn, n, noff, i ); i4(ifn) = ihypo(ifn)
    if ( master ) then
      call stats( r1, i1-nnoff, 'tsmax', it )
      call stats( r2, i2-nnoff, 'samax', it )
      call stats( r3, i3-nnoff, 'tnmax', it )
      call stats( r4, i4-nnoff, 'tnmin', it )
      call rwrite( 'stats/efric', efric, it )
      call rwrite( 'stats/estrain', estrain, it )
      call rwrite( 'stats/m0', m0, it )
      r1 = -0.
      if ( m0 > 0. ) r1 = 2. / 3. * log10( m0 ) - 10.7
      call rwrite( 'stats/mw', r1, it )
    end if
  end if
end select

doiz: do iz = 1, nout !--------------------------------------------------------!

! Pass
if ( ditout(iz) /= 0 ) then
  if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz
end if
call outprops( fieldout(iz), nc, onpass, fault, cell )
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i3 = max( i1, i1node )
i4 = min( i2, i2node )
if ( cell ) i4 = min( i2, i2cell )
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
  if ( pass /= 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = it / ditout(iz)
  else
    write( str, '(i2.2,a,a,i1,i6.6)' ) iz, '/', trim( fieldout(iz) ), ic, it
  end if
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i3, i4, iz )
  case( 'rho'  ); call scalario( 'w', str, mr,       ir, i1, i2, i3, i4, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,       ir, i1, i2, i3, i4, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,      ir, i1, i2, i3, i4, iz )
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

