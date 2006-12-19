! Output routines
module m_output
implicit none
contains

! initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
real :: rout
integer :: i1(3), i2(3), n(3), noff(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nc, iz, onpass
logical :: dofault, fault, cell

if ( master ) write( 0, * ) 'Output initialization'
if ( nout > nz ) stop 'too many output zones, make nz bigger'

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

do iz = 1, nout

! Output field properties
call outprops( fieldout(iz), nc, onpass, fault, cell )

! Time indices 
if ( itstats < 1 ) itstats = itstats + nt + 1
if ( i1out(iz,4) < 0 ) i1out(iz,4) = nt + i1out(iz,4) + 1
if ( i2out(iz,4) < 0 ) i2out(iz,4) = nt + i2out(iz,4) + 1
if ( ditout(iz)  < 0 ) ditout(iz)  = nt + ditout(iz)  + 1
if ( onpass == 0 ) then
  ditout(iz) = 1
  i1out(iz,4) = 0
  i2out(iz,4) = 0
end if
i2out(iz,4) = min( i2out(iz,4), nt )
if ( fault .and. faultnormal == 0 ) ditout(iz) = nt + 1

! Spacial indices
n = nn + 2 * nhalo
noff = nnoff - nhalo
select case( outtype(iz) )
case( 'z' )
  i1 = i1out(iz,1:3)
  i2 = i2out(iz,1:3)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  if ( cell ) i2 = i2 - 1
  if ( fault .and. faultnormal /= 0 ) then
    i = abs( faultnormal )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
  end if
case( 'x' )
  i1out(iz,4) = 0
  i2out(iz,4) = nt
  if ( fault ) then
    i1 = nnoff
    rout = 2 * dx * dx
    if ( dofault ) then
      i = abs( faultnormal )
      i1 = 1
      i2 = nm
      i1(i) = ihypo(i)
      i2(i) = ihypo(i)
      j1 = i1(1); j2 = i2(1)
      k1 = i1(2); k2 = i2(2)
      l1 = i1(3); l2 = i2(3)
      do i = 1, 3
        t2(:,:,:,i) = xout(iz,i) - x(j1:j2,k1:k2,l1:l2,i)
      end do
      i = abs( faultnormal )
      f2 = sum( t2 * t2, 4 )
      rout = 2 * dx * dx + maxval( f2 )
      call sethalo( f2, rout, i1node, i2node )
      call reduceloc( rout, i1, f2, 'allmin', n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      i1 = i1node
      i2 = i2cell
      j1 = i1(1); j2 = i2(1)
      k1 = i1(2); k2 = i2(2)
      l1 = i1(3); l2 = i2(3)
      forall( j=j1:j2, k=k1:k2, l=l1:l2, i=1:3 )
        w2(j,k,l,i) = xout(iz,i) - 0.125 * &
          ( x(j,k,l,i) + x(j+1,k+1,l+1,i) &
          + x(j+1,k,l,i) + x(j,k+1,l+1,i) &
          + x(j,k+1,l,i) + x(j+1,k,l+1,i) &
          + x(j,k,l+1,i) + x(j+1,k+1,l,i) )
      end forall
      s2 = sum( w2 * w2, 4 )
      rout = 2 * dx * dx + maxval( s2 )
      call sethalo( s2, rout, i1node, i2cell )
    else
      do i = 1, 3
        w2(:,:,:,i) = xout(iz,i) - x(:,:,:,i)
      end do
      s2 = sum( w2 * w2, 4 )
      rout = 2 * dx * dx + maxval( s2 )
      call sethalo( s2, rout, i1node, i2node )
    end if
    call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) ditout(iz) = nt + 1
end select

! Save indices
if ( any( i2 < i1 ) ) stop 'bad output indices'
i1out(iz,1:3) = i1
i2out(iz,1:3) = i2

! Split collective i/o
i1 = max( i1, i1node )
i2 = min( i2, i2node )
if ( cell ) i2 = min( i2, i2cell )
i = ditout(iz)
if ( any( i2 < i1 ) ) i = nt + 1
call splitio( iz, nout, i )
 
end do

end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine output( pass )
use m_globals
use m_collective
use m_outprops
use m_util
integer, intent(in) :: pass
real, save :: vstats(4), fstats(8)
real :: gvstats(4), gfstats(8), rr
integer :: i1(3), i2(3), i3(3), i4(3), n(3), noff(3), i, onpass, nc, ic, ir, iz
logical :: dofault, fault, cell

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output
if ( it > 0 ) then
  select case( pass )
  case( 1 )
    s1 = sqrt( sum( v * v, 4 ) )
    s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
    pv = max( pv, s1 )
  case( 2 )
    s1 = sqrt( sum( u * u, 4 ) )
    s2 = sqrt( sum( w1 * w1, 4 ) )
  end select
end if

! Volume stats
if ( it > 0 .and. modulo( it, itstats ) == 0 ) then
  select case( pass )
  case( 1 )
    call sethalo( s1, -1., i1node, i2node )
    call sethalo( s2, -1., i1cell, i2cell )
    vstats(1) = maxval( s1 )
    vstats(2) = maxval( s2 )
    n = nn + 2 * nhalo
    noff = nnoff - nhalo
    call reduceloc( rr, i1, s1, 'max', n, noff, 0 )
    if ( master ) then
      call iwrite( 'stats/vmax1', i1(1), it / itstats )
      call iwrite( 'stats/vmax2', i1(2), it / itstats )
      call iwrite( 'stats/vmax3', i1(3), it / itstats )
    end if
  case( 2 )
    call sethalo( s1, -1., i1node, i2node )
    call sethalo( s2, -1., i1node, i2node )
    vstats(3) = maxval( s1 )
    vstats(4) = maxval( s2 )
    call rreduce1( gvstats, vstats, 'max', 0 )
    if ( master ) then
      call rwrite( 'stats/vmax', gvstats(1), it / itstats )
      call rwrite( 'stats/wmax', gvstats(2), it / itstats )
      call rwrite( 'stats/umax', gvstats(3), it / itstats )
      call rwrite( 'stats/amax', gvstats(4), it / itstats )
      rr = gvstats(3)
      if ( rr > dx / 10. ) write( 0, * ) 'warning: u !<< dx', rr, dx
    end if
  end select
end if

! Write fault stats
if ( it > 0 .and. modulo( it, itstats ) == 0 .and. dofault ) then
  select case( pass )
  case( 1 )
    call sethalo( f1,   -1., i1node, i2node )
    call sethalo( f2,   -1., i1node, i2node )
    call sethalo( tarr, -1., i1node, i2node )
    fstats(1) = maxval( f1 )
    fstats(2) = maxval( f2 )
    fstats(3) = maxval( sl )
    fstats(4) = maxval( tarr )
  case( 2 )
    call sethalo( ts, -1., i1node, i2node )
    call sethalo( f2, -1., i1node, i2node )
    fstats(5) = maxval( ts )
    fstats(6) = maxval( f2 )
    rr = 2. * minval( tn ) - 1.
    call sethalo( tn, rr, i1node, i2node )
    fstats(7) = maxval( tn )
    rr = 2. * fstats(7) + 1.
    call sethalo( tn, rr, i1node, i2node )
    fstats(8) = -minval( tn )
    call rreduce1( gfstats, fstats, 'max', ifn )
    if ( master ) then
      call rwrite( 'stats/svmax',   gfstats(1), it / itstats )
      call rwrite( 'stats/sumax',   gfstats(2), it / itstats )
      call rwrite( 'stats/slmax',   gfstats(3), it / itstats )
      call rwrite( 'stats/tarrmax', gfstats(4), it / itstats )
      call rwrite( 'stats/tsmax',   gfstats(5), it / itstats )
      call rwrite( 'stats/samax',   gfstats(6), it / itstats )
      call rwrite( 'stats/tnmax',   gfstats(7), it / itstats )
      call rwrite( 'stats/tnmin',  -gfstats(8), it / itstats )
    end if
    fstats(1) = efric
    fstats(2) = estrain
    fstats(3) = moment
    call rreduce1( gfstats, fstats, 'sum', ifn )
    if ( master ) then
      rr = -999.
      if ( gfstats(3) > 0. ) rr = ( log10( gfstats(3) ) - 9.05 ) / 1.5
      call rwrite( 'stats/efric',   gfstats(1), it / itstats )
      call rwrite( 'stats/estrain', gfstats(2), it / itstats )
      call rwrite( 'stats/moment',  gfstats(3), it / itstats )
      call rwrite( 'stats/mw',      rr,         it / itstats ) 
    end if
  end select
end if

doiz: do iz = 1, nout

! Interval
if ( it < i1out(iz,4) .or. it > i2out(iz,4) ) cycle doiz
if ( modulo( it - i1out(iz,4), ditout(iz) ) /= 0 ) cycle doiz

! Pass
call outprops( fieldout(iz), nc, onpass, fault, cell )
i1 = i1out(iz,1:3)
i2 = i2out(iz,1:3)
i3 = max( i1, i1node )
i4 = min( i2, i2node )
if ( cell ) i4 = min( i4, i2cell )
if ( any( i3 > i4 ) ) then 
  ditout(iz) = nt + 1
  cycle doiz
end if
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if
if ( pass /= onpass ) cycle doiz

! Binary output
do ic = 1, nc
  ir = 1
  write( str, '(i2.2,a,a)' ) iz, '/', fieldout(iz)
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( i2out(iz,4) > 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = ( it - i1out(iz,4) ) / ditout(iz) + 1
  else
    write( str, '(a,i6.6)' ) trim( str ), it
  end if
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i3, i4, iz )
  case( 'rho'  ); call scalario( 'w', str, mr,       ir, i1, i2, i3, i4, iz )
  case( 'vp'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'vs'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
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

end do doiz

! Interation counter
if ( master .and. pass == 2 ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

