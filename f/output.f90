! Output routines
module m_output
implicit none
contains

! Initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
real :: rout
integer :: i1(3), i2(3), n(3), noff(3), i, j1, k1, l1, j2, k2, l2, nc, iz, onpass
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
if ( i1out(iz,4) < 0 ) i1out(iz,4) = nt + i1out(iz,4) + 1
if ( i2out(iz,4) < 0 ) i2out(iz,4) = nt + i2out(iz,4) + 1
if ( ditout(iz)  < 0 ) ditout(iz)  = nt + ditout(iz)  + 1
if ( onpass == 0 ) then
  ditout(iz) = 1
  i1out(iz,4) = 0
  i2out(iz,4) = 0
end if
i2out(iz,4) = min( i2out(iz,4), nt )
if ( fault .and. faultnormal == 0 ) i1out(iz,4) = nt + 1

! Spatial indices
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
  ditout(iz) = 1
  i1out(iz,4) = 0
  i2out(iz,4) = nt
  if ( onpass == 0 ) i2out(iz,4) = 0
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
      t2 = w2(j1:j2,k1:k2,l1:l2,:)
      f2 = ( t2(:,:,:,1) - xout(iz,1) ) * ( t2(:,:,:,1) - xout(iz,1) ) &
         + ( t2(:,:,:,2) - xout(iz,2) ) * ( t2(:,:,:,2) - xout(iz,2) ) &
         + ( t2(:,:,:,3) - xout(iz,3) ) * ( t2(:,:,:,3) - xout(iz,3) )
      rout = 2 * dx * dx + maxval( f2 )
      call scalarsethalo( f2, rout, i1node, i2node )
      call reduceloc( rout, i1, f2, 'allmin', n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      s2 = ( w2(:,:,:,1) - xout(iz,1) ) * ( w2(:,:,:,1) - xout(iz,1) ) &
         + ( w2(:,:,:,2) - xout(iz,2) ) * ( w2(:,:,:,2) - xout(iz,2) ) &
         + ( w2(:,:,:,3) - xout(iz,3) ) * ( w2(:,:,:,3) - xout(iz,3) )
      rout = 2 * dx * dx + maxval( s2 )
      call scalarsethalo( s2, rout, i1node, i2cell )
      i1 = i1node
      i2 = i2cell
    else
      s2 = ( w1(:,:,:,1) - xout(iz,1) ) * ( w1(:,:,:,1) - xout(iz,1) ) &
         + ( w1(:,:,:,2) - xout(iz,2) ) * ( w1(:,:,:,2) - xout(iz,2) ) &
         + ( w1(:,:,:,3) - xout(iz,3) ) * ( w1(:,:,:,3) - xout(iz,3) )
      rout = 2 * dx * dx + maxval( s2 )
      call scalarsethalo( s2, rout, i1node, i2node )
    end if
    call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) i1out(iz,4) = nt + 1
end select

! Save indices
if ( any( i2 < i1 ) ) then
  write( 0, '(a,i3.3,x,a,6i7)' ) 'Error in output indices: ', iz, fieldout(iz), i1, i2
  stop
end if
i1out(iz,1:3) = i1
i2out(iz,1:3) = i2

! Buffer 

! Split collective i/o
i1 = max( i1, i1node )
i2 = min( i2, i2node )
if ( cell ) i2 = min( i2, i2cell )
i = i1out(iz,4)
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
real, save :: vstats(4,itio), fstats(8,itio), estats(4,itio)
real :: gvstats(4,itio), gfstats(8,itio), gestats(4,itio), rr
integer :: i1(3), i2(3), i3(3), i4(3), n(3), noff(3), i, onpass, nc, ic, ir, iz
logical :: dofault, fault, cell, ioflush

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output
ioflush = .false.
if ( it > 0 ) then
  i = modulo( it-1, itio ) + 1
  select case( pass )
  case( 1 )
    s1 = sum( v * v, 4 )
    s2 = sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 )
    pv = max( pv, s1 )
    call scalarsethalo( s1, -1., i1node, i2node )
    call scalarsethalo( s2, -1., i1cell, i2cell )
    vstats(1,i) = sqrt( maxval( s1 ) )
    vstats(2,i) = sqrt( maxval( s2 ) )
  case( 2 )
    ioflush = ( i == itio .or. it == nt .or. modulo( it, itcheck ) == 0 )
    s1 = sum( u * u, 4 )
    s2 = sum( w1 * w1, 4 )
    call scalarsethalo( s1, -1., i1node, i2node )
    call scalarsethalo( s2, -1., i1node, i2node )
    vstats(3,i) = sqrt( maxval( s1 ) )
    vstats(4,i) = sqrt( maxval( s2 ) )
    if ( any( vstats > huge( 0. ) ) ) stop 'unstable solution'
    if ( ioflush ) then
      call rreduce2( gvstats, vstats, 'max', 0 )
      if ( master ) then
        call rwrite1( 'stats/vmax', gvstats(1,:i), it )
        call rwrite1( 'stats/wmax', gvstats(2,:i), it )
        call rwrite1( 'stats/umax', gvstats(3,:i), it )
        call rwrite1( 'stats/amax', gvstats(4,:i), it )
        rr = maxval( gvstats(3,:) )
        if ( rr > dx / 10. ) write( 0, * ) 'warning: u !<< dx', rr, dx
      end if
    end if
  end select
end if

! Write fault stats
if ( it > 0 .and. dofault ) then
  i = modulo( it-1, itio ) + 1
  select case( pass )
  case( 1 )
    call scalarsethalo( f1,   -1., i1node, i2node )
    call scalarsethalo( f2,   -1., i1node, i2node )
    call scalarsethalo( tarr, -1., i1node, i2node )
    fstats(1,i) = maxval( f1 )
    fstats(2,i) = maxval( f2 )
    fstats(3,i) = maxval( sl )
    fstats(4,i) = maxval( tarr )
  case( 2 )
    call scalarsethalo( ts, -1., i1node, i2node )
    call scalarsethalo( f2, -1., i1node, i2node )
    fstats(5,i) = maxval( ts )
    fstats(6,i) = maxval( f2 )
    rr = 2. * minval( tn ) - 1.
    call scalarsethalo( tn, rr, i1node, i2node )
    fstats(7,i) = maxval( tn )
    rr = 2. * fstats(7,i) + 1.
    call scalarsethalo( tn, rr, i1node, i2node )
    fstats(8,i) = -minval( tn )
    estats(1,i) = efric
    estats(2,i) = estrain
    estats(3,i) = moment
    if ( ioflush ) then
      call rreduce2( gfstats, fstats, 'allmax', ifn )
      call rreduce2( gestats, estats, 'allsum', ifn )
      gestats(4,:) = -999
      do i = 1, itio
        if ( gestats(3,i) > 0. ) gestats(4,i) = ( log10( gestats(3,i) ) - 9.05 ) / 1.5
      end do
      if ( master ) then
        i = modulo( it-1, itio ) + 1
        call rwrite1( 'stats/svmax',   gfstats(1,:i), it )
        call rwrite1( 'stats/sumax',   gfstats(2,:i), it )
        call rwrite1( 'stats/slmax',   gfstats(3,:i), it )
        call rwrite1( 'stats/tarrmax', gfstats(4,:i), it )
        call rwrite1( 'stats/tsmax',   gfstats(5,:i), it )
        call rwrite1( 'stats/samax',   gfstats(6,:i), it )
        call rwrite1( 'stats/tnmax',   gfstats(7,:i), it )
        call rwrite1( 'stats/tnmin',  -gfstats(8,:i), it )
        call rwrite1( 'stats/efric',   gestats(1,:i), it )
        call rwrite1( 'stats/estrain', gestats(2,:i), it )
        call rwrite1( 'stats/moment',  gestats(3,:i), it )
        call rwrite1( 'stats/mw',      gestats(4,:i), it ) 
      end if
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
if ( any( i3 > i4 ) ) then 
  i1out(iz,4) = nt + 1
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
  write( str, '(i2.2,a,a)' ) iz, '/', fieldout(iz)
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( i2out(iz,4) > 0 .and. any( i1 /= i2 ) ) write( str, '(a,i6.6)' ) trim( str ), it
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, rr, w1,   ic, i1, i2, i3, i4, iz )
  case( 'rho'  ); call scalario( 'w', str, rr, mr,       i1, i2, i3, i4, iz )
  case( 'vp'   ); call scalario( 'w', str, rr, s1,       i1, i2, i3, i4, iz )
  case( 'vs'   ); call scalario( 'w', str, rr, s2,       i1, i2, i3, i4, iz )
  case( 'mu'   ); call scalario( 'w', str, rr, mu,       i1, i2, i3, i4, iz )
  case( 'lam'  ); call scalario( 'w', str, rr, lam,      i1, i2, i3, i4, iz )
  case( 'v'    ); call vectorio( 'w', str, rr, v,    ic, i1, i2, i3, i4, iz )
  case( 'u'    ); call vectorio( 'w', str, rr, u,    ic, i1, i2, i3, i4, iz )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( 'w', str, rr, w1, ic,   i1, i2, i3, i4, iz )
   if ( ic > 3 )  call vectorio( 'w', str, rr, w2, ic-3, i1, i2, i3, i4, iz )
  case( 'a'    ); call vectorio( 'w', str, rr, w1,   ic, i1, i2, i3, i4, iz )
  case( 'vm2'  ); call scalario( 'w', str, rr, s1,       i1, i2, i3, i4, iz )
  case( 'um2'  ); call scalario( 'w', str, rr, s1,       i1, i2, i3, i4, iz )
  case( 'wm2'  ); call scalario( 'w', str, rr, s2,       i1, i2, i3, i4, iz )
  case( 'am2'  ); call scalario( 'w', str, rr, s2,       i1, i2, i3, i4, iz )
  case( 'pv2'  ); call scalario( 'w', str, rr, pv,       i1, i2, i3, i4, iz )
  case( 'nhat' ); call vectorio( 'w', str, rr, nhat, ic, i1, i2, i3, i4, iz )
  case( 'mus'  ); call scalario( 'w', str, rr, mus,      i1, i2, i3, i4, iz )
  case( 'mud'  ); call scalario( 'w', str, rr, mud,      i1, i2, i3, i4, iz )
  case( 'dc'   ); call scalario( 'w', str, rr, dc,       i1, i2, i3, i4, iz )
  case( 'co'   ); call scalario( 'w', str, rr, co,       i1, i2, i3, i4, iz )
  case( 'sv'   ); call vectorio( 'w', str, rr, t1,   ic, i1, i2, i3, i4, iz )
  case( 'su'   ); call vectorio( 'w', str, rr, t2,   ic, i1, i2, i3, i4, iz )
  case( 'ts'   ); call vectorio( 'w', str, rr, t3,   ic, i1, i2, i3, i4, iz )
  case( 'sa'   ); call vectorio( 'w', str, rr, t2,   ic, i1, i2, i3, i4, iz )
  case( 'svm'  ); call scalario( 'w', str, rr, f1,       i1, i2, i3, i4, iz )
  case( 'sum'  ); call scalario( 'w', str, rr, f2,       i1, i2, i3, i4, iz )
  case( 'tsm'  ); call scalario( 'w', str, rr, ts,       i1, i2, i3, i4, iz )
  case( 'sam'  ); call scalario( 'w', str, rr, f2,       i1, i2, i3, i4, iz )
  case( 'tn'   ); call scalario( 'w', str, rr, tn,       i1, i2, i3, i4, iz )
  case( 'fr'   ); call scalario( 'w', str, rr, f1,       i1, i2, i3, i4, iz )
  case( 'sl'   ); call scalario( 'w', str, rr, sl,       i1, i2, i3, i4, iz )
  case( 'psv'  ); call scalario( 'w', str, rr, psv,      i1, i2, i3, i4, iz )
  case( 'trup' ); call scalario( 'w', str, rr, trup,     i1, i2, i3, i4, iz )
  case( 'tarr' ); call scalario( 'w', str, rr, tarr,     i1, i2, i3, i4, iz )
  ir = ( it - i1out(iz,4) ) / ditout(iz) + 1
  if ( all( i1 == i2 ) ) call rwrite( str, rr, ir )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
end do

end do doiz

! Iteration counter
if ( master .and. pass == 2 ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

