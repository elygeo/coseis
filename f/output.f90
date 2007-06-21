! Output routines
module m_output
implicit none
real, private, allocatable :: iobuffer(:,:)
integer, private, allocatable :: jbuff(:)
contains

! Initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
real :: rout
integer :: i1(3), i2(3), n(3), noff(3), i, j1, k1, l1, j2, k2, l2, nc, iz, onpass, nbuff
logical :: dofault, fault, cell

if ( master ) write( 0, * ) 'Output initialization'
if ( nout > nz ) stop 'too many output zones, make nz bigger'
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( modulo( itcheck, itio ) /= 0 ) itcheck = ( itcheck / itio + 1 ) * itio
nbuff = 0
ibuff = 0

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3master(i) ) dofault = .true.
end if

doiz: do iz = 1, nout

! Output field properties
call outprops( fieldout(iz), nc, onpass, fault, cell )
if ( fault .and. faultnormal == 0 ) then
  write( 0, * ) 'No fault to output for ', trim( fieldout(iz) )
  stop
elseif ( fault .and. .not. dofault ) then
  i1out(iz,4) = nt + 1
  cycle doiz
end if

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

! Spatial indices
n = nn + 2 * nhalo
noff = nnoff + nhalo
select case( outtype(iz) )
case( 'z' )
  i1 = i1out(iz,1:3)
  i2 = i2out(iz,1:3)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  if ( cell ) i2 = i2 - 1
  if ( fault ) then
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
      call scalarsethalo( f2, rout, i1core, i2core )
      call reduceloc( rout, i1, f2, 'allmin', n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      s2 = ( w2(:,:,:,1) - xout(iz,1) ) * ( w2(:,:,:,1) - xout(iz,1) ) &
         + ( w2(:,:,:,2) - xout(iz,2) ) * ( w2(:,:,:,2) - xout(iz,2) ) &
         + ( w2(:,:,:,3) - xout(iz,3) ) * ( w2(:,:,:,3) - xout(iz,3) )
      rout = 2 * dx * dx + maxval( s2 )
      i1 = max( i1core, i1cell )
      i2 = min( i2core, i2cell )
      call scalarsethalo( s2, rout, i1, i2 )
    else
      s2 = ( w1(:,:,:,1) - xout(iz,1) ) * ( w1(:,:,:,1) - xout(iz,1) ) &
         + ( w1(:,:,:,2) - xout(iz,2) ) * ( w1(:,:,:,2) - xout(iz,2) ) &
         + ( w1(:,:,:,3) - xout(iz,3) ) * ( w1(:,:,:,3) - xout(iz,3) )
      rout = 2 * dx * dx + maxval( s2 )
      call scalarsethalo( s2, rout, i1core, i2core )
    end if
    call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) i1out(iz,4) = nt + 1
end select

! Save indices
if ( any( i2 < i1 ) ) then
  write( 0, '(a,i3.3,a,a,6i7)' ) 'Error in output indices: ', iz, ' ', fieldout(iz), i1, i2
  stop
end if
i1out(iz,1:3) = i1
i2out(iz,1:3) = i2

! Buffer timer series
i1 = max( i1, i1core )
i2 = min( i2, i2core )
if ( all( i1 == i2 ) .and. i1out(iz,4) <= i2out(iz,4) ) then
  ibuff(iz) = nbuff + 1
  nbuff = nbuff + nc
end if

end do doiz

! Allocate buffer
if ( nbuff > 0 ) then
  allocate( iobuffer(itio,nbuff), jbuff(nbuff) )
  iobuffer = 0.
  jbuff = 0
end if

end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine output( pass )
use m_globals
use m_collective
use m_outprops
use m_util
integer, intent(in) :: pass
real, save :: vstats(itio,4), fstats(itio,8), estats(itio,4)
real :: gvstats(itio,4), gfstats(itio,8), gestats(itio,4), rr
integer :: i1(3), i2(3), i3(3), i4(3), i, onpass, nc, ic, ir, iz, mpio
logical :: dofault, fault, cell

! Debug
if ( master .and. debug > 1 ) write( 0, * ) 'Output pass ', pass

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3master(i) ) dofault = .true.
end if

! Prepare output
if ( it > 0 ) then
  i = modulo( it-1, itio ) + 1
  select case( pass )
  case( 1 )
    s1 = sum( vv * vv, 4 )
    s2 = sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 )
    i1 = max( i1core, i1cell )
    i2 = min( i2core, i2cell )
    call scalarsethalo( s1, 0., i1core, i2core )
    call scalarsethalo( s2, 0., i1, i2 )
    pv = max( pv, s1 )
    vstats(i,1) = maxval( s1 )
    vstats(i,2) = maxval( s2 )
  case( 2 )
    s1 = sum( uu * uu, 4 )
    s2 = sum( w1 * w1, 4 )
    call scalarsethalo( s1, -1., i1core, i2core )
    call scalarsethalo( s2, -1., i1core, i2core )
    vstats(i,3) = maxval( s1 )
    vstats(i,4) = maxval( s2 )
    !if ( any( vstats > huge( rr ) ) ) stop 'unstable solution'
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rreduce2( gvstats, vstats, 'max', 0 )
      gvstats = sqrt( gvstats )
      if ( master ) then
        call rwrite1( 'stats/vmax', gvstats(:i,1), it )
        call rwrite1( 'stats/wmax', gvstats(:i,2), it )
        call rwrite1( 'stats/umax', gvstats(:i,3), it )
        call rwrite1( 'stats/amax', gvstats(:i,4), it )
        rr = maxval( gvstats(:,3) )
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
    call scalarsethalo( f1,   -1., i1core, i2core )
    call scalarsethalo( f2,   -1., i1core, i2core )
    call scalarsethalo( tarr, -1., i1core, i2core )
    fstats(i,1) = maxval( f1 )
    fstats(i,2) = maxval( f2 )
    fstats(i,3) = maxval( sl )
    fstats(i,4) = maxval( tarr )
  case( 2 )
    call scalarsethalo( ts, -1., i1core, i2core )
    call scalarsethalo( f2, -1., i1core, i2core )
    fstats(i,5) = maxval( ts )
    fstats(i,6) = maxval( f2 )
    rr = -2. * abs( minval( tn ) ) - 1.
    call scalarsethalo( tn, rr, i1core, i2core )
    fstats(i,7) = maxval( tn )
    rr = 2. * abs( fstats(i,7) ) + 1.
    call scalarsethalo( tn, rr, i1core, i2core )
    fstats(i,8) = -minval( tn )
    estats(i,1) = efric
    estats(i,2) = estrain
    estats(i,3) = moment
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rreduce2( gfstats, fstats, 'allmax', ifn )
      call rreduce2( gestats, estats, 'allsum', ifn )
      gfstats(:,8) = -gfstats(:,8)
      gestats(:,4) = -999
      do i = 1, itio
        if ( gestats(i,3) > 0. ) gestats(i,4) = ( log10( gestats(i,3) ) - 9.05 ) / 1.5
      end do
      if ( master ) then
        i = modulo( it-1, itio ) + 1
        call rwrite1( 'stats/svmax',   gfstats(:i,1), it )
        call rwrite1( 'stats/sumax',   gfstats(:i,2), it )
        call rwrite1( 'stats/slmax',   gfstats(:i,3), it )
        call rwrite1( 'stats/tarrmax', gfstats(:i,4), it )
        call rwrite1( 'stats/tsmax',   gfstats(:i,5), it )
        call rwrite1( 'stats/samax',   gfstats(:i,6), it )
        call rwrite1( 'stats/tnmax',   gfstats(:i,7), it )
        call rwrite1( 'stats/tnmin',   gfstats(:i,8), it )
        call rwrite1( 'stats/efric',   gestats(:i,1), it )
        call rwrite1( 'stats/estrain', gestats(:i,2), it )
        call rwrite1( 'stats/moment',  gestats(:i,3), it )
        call rwrite1( 'stats/mw',      gestats(:i,4), it ) 
        i1 = ihypo
        i1(ifn) = 1  
        open( 1, file='stats/tarrhypo', status='replace' )
        write( 1, * ) tarr(i1(1),i1(2),i1(3))
        close( 1 )
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
if ( pass /= onpass ) cycle doiz

! Indices
ir = ( it - i1out(iz,4) ) / ditout(iz) + 1
i1 = i1out(iz,1:3)
i2 = i2out(iz,1:3)
i3 = max( i1, i1core )
i4 = min( i2, i2core )
if ( any( i3 > i4 ) ) then
  i1out(iz,4) = nt + 1
  if ( all( i1 == i2 ) ) cycle doiz
  nc = 1
end if
mpio = mpout * 4
if ( fault ) then
  if ( .not. dofault ) cycle doiz
  i = abs( faultnormal )
  mpio = mpout * i
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Binary output
do ic = 1, nc
  write( str, '(a,i2.2,a)' ) 'out/', iz, fieldout(iz)
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( mpout == 0 ) then
    i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
    if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
  end if
  if ( debug > 2 ) write( 0, * ) ip, 'Writing: ', trim( str ), ir
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( iz, str, rr, w1,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'rho'  ); call scalario( iz, str, rr, mr,   i1, i2, i3, i4,       ir, mpio )
  case( 'vp'   ); call scalario( iz, str, rr, s1,   i1, i2, i3, i4,       ir, mpio )
  case( 'vs'   ); call scalario( iz, str, rr, s2,   i1, i2, i3, i4,       ir, mpio )
  case( 'gam'  ); call scalario( iz, str, rr, gam,  i1, i2, i3, i4,       ir, mpio )
  case( 'lam'  ); call scalario( iz, str, rr, lam,  i1, i2, i3, i4,       ir, mpio )
  case( 'mu'   ); call scalario( iz, str, rr, mu,   i1, i2, i3, i4,       ir, mpio )
  case( 'v'    ); call vectorio( iz, str, rr, vv,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'u'    ); call vectorio( iz, str, rr, uu,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( iz, str, rr, w1,   i1, i2, i3, i4, ic,   ir, mpio )
   if ( ic > 3 )  call vectorio( iz, str, rr, w2,   i1, i2, i3, i4, ic-3, ir, mpio )
  case( 'a'    ); call vectorio( iz, str, rr, w1,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'vm2'  ); call scalario( iz, str, rr, s1,   i1, i2, i3, i4,       ir, mpio )
  case( 'um2'  ); call scalario( iz, str, rr, s1,   i1, i2, i3, i4,       ir, mpio )
  case( 'wm2'  ); call scalario( iz, str, rr, s2,   i1, i2, i3, i4,       ir, mpio )
  case( 'am2'  ); call scalario( iz, str, rr, s2,   i1, i2, i3, i4,       ir, mpio )
  case( 'pv2'  ); call scalario( iz, str, rr, pv,   i1, i2, i3, i4,       ir, mpio )
  case( 'nhat' ); call vectorio( iz, str, rr, nhat, i1, i2, i3, i4, ic,   ir, mpio )
  case( 'mus'  ); call scalario( iz, str, rr, mus,  i1, i2, i3, i4,       ir, mpio )
  case( 'mud'  ); call scalario( iz, str, rr, mud,  i1, i2, i3, i4,       ir, mpio )
  case( 'dc'   ); call scalario( iz, str, rr, dc,   i1, i2, i3, i4,       ir, mpio )
  case( 'co'   ); call scalario( iz, str, rr, co,   i1, i2, i3, i4,       ir, mpio )
  case( 'sv'   ); call vectorio( iz, str, rr, t1,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'su'   ); call vectorio( iz, str, rr, t2,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'ts'   ); call vectorio( iz, str, rr, t1,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'sa'   ); call vectorio( iz, str, rr, t2,   i1, i2, i3, i4, ic,   ir, mpio )
  case( 'svm'  ); call scalario( iz, str, rr, f1,   i1, i2, i3, i4,       ir, mpio )
  case( 'sum'  ); call scalario( iz, str, rr, f2,   i1, i2, i3, i4,       ir, mpio )
  case( 'tsm'  ); call scalario( iz, str, rr, ts,   i1, i2, i3, i4,       ir, mpio )
  case( 'sam'  ); call scalario( iz, str, rr, f2,   i1, i2, i3, i4,       ir, mpio )
  case( 'tn'   ); call scalario( iz, str, rr, tn,   i1, i2, i3, i4,       ir, mpio )
  case( 'fr'   ); call scalario( iz, str, rr, f1,   i1, i2, i3, i4,       ir, mpio )
  case( 'sl'   ); call scalario( iz, str, rr, sl,   i1, i2, i3, i4,       ir, mpio )
  case( 'psv'  ); call scalario( iz, str, rr, psv,  i1, i2, i3, i4,       ir, mpio )
  case( 'trup' ); call scalario( iz, str, rr, trup, i1, i2, i3, i4,       ir, mpio )
  case( 'tarr' ); call scalario( iz, str, rr, tarr, i1, i2, i3, i4,       ir, mpio )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
  if ( all( i1 == i2 ) ) then
  if ( it == 0 .or. ibuff(iz) == 0 ) then
    call rwrite( str, rr, ir )
  else
    i = ibuff(iz) + ic - 1
    jbuff(i) = jbuff(i) + 1
    iobuffer(jbuff(i),i) = rr
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rwrite1( str, iobuffer(:jbuff(i),i), ir )
      jbuff(i) = 0
    end if
  end if
  end if
end do

end do doiz

! Iteration counter
if ( master .and. pass == 2 .and. ( modulo( it, itio ) == 0 .or. it == nt ) ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

