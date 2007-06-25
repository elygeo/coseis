! Output routines
module m_output
implicit none
real, private, allocatable :: iobuffer(:,:)
integer, private, allocatable :: jb(:)
contains

! Initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
real :: rout, x0(3)
integer :: i1(3), i2(3), n(3), noff(3), &
  i, j1, k1, l1, j2, k2, l2, nc, iz, onpass, nbuff
logical :: dofault, fault, cell

if ( master ) write( 0, * ) 'Output initialization'
if ( nout > nz ) stop 'too many output zones, make nz bigger'
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( itstats < 1 ) itstats = itstats + nt + 1
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
  x0 = xout(iz,:)
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
      call radius( s2, w1, x0, i1, i2 )
      f2 = s2(i1(1):i2(1),i1(2):i2(2),i1(3):i2(3))
      rout = 2 * dx * dx + maxval( f2 )
      call scalarsethalo( f2, rout, i1core, i2core )
      call reduceloc( rout, i1, f2, 'allmin', n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      i1 = max( i1core, i1cell )
      i2 = min( i2core, i2cell )
      call radius( s2, w2, x0, i1, i2 )
      rout = 2 * dx * dx + maxval( s2 )
      call scalarsethalo( s2, rout, i1, i2 )
    else
      call radius( s2, w1, x0, i1core, i2core )
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
  allocate( iobuffer(itio,nbuff), jb(nbuff) )
  iobuffer = 0.
  jb = 0
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
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, onpass, nc, ic, nr, ir, iz, id, mpio
integer, save :: jv = 0, jf = 0
logical :: dofault, fault, cell

! Staus
if ( master .and. ( it == 0 .or. debug == 2 ) ) write( 0, '(a,i2)' ) ' Output pass', pass

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3master(i) ) dofault = .true.
end if

! Volume stats
if ( it > 0 .and. modulo( it, itstats ) == 0 ) then
  select case( pass )
  case( 1 )
    jv = jv + 1
    call vectornorm( s1, vv, i1core, i2core )
    call tensornorm( s2, w1, w2, i1core, i2core )
    call scalarsethalo( s1, -1., i1core, i2core )
    call scalarsethalo( s2, -1., i1core, i2core )
    vstats(jv,1) = maxval( s1 )
    vstats(jv,2) = maxval( s2 )
  case( 2 )
    call vectornorm( s1, uu, i1core, i2core )
    call vectornorm( s2, w1, i1core, i2core )
    call scalarsethalo( s1, -1., i1core, i2core )
    call scalarsethalo( s2, -1., i1core, i2core )
    vstats(jv,3) = maxval( s1 )
    vstats(jv,4) = maxval( s2 )
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rreduce2( gvstats, vstats, 'max', 0 )
      if ( master ) then
        gvstats = sqrt( gvstats )
        call rwrite1( 'stats/vmax', gvstats(:jv,1), it / itstats )
        call rwrite1( 'stats/wmax', gvstats(:jv,2), it / itstats )
        call rwrite1( 'stats/umax', gvstats(:jv,3), it / itstats )
        call rwrite1( 'stats/amax', gvstats(:jv,4), it / itstats )
        rr = maxval( gvstats(:jv,3) )
        if ( rr > dx / 10. ) write( 0, * ) 'warning: u !<< dx', rr, dx
      end if
      jv = 0
    end if
  end select
end if

! Fault stats
if ( it > 0 .and. dofault .and. modulo( it, itstats ) == 0 ) then
  select case( pass )
  case( 1 )
    jf = jf + 1
    call scalarsethalo( f1,   -1., i1core, i2core )
    call scalarsethalo( f2,   -1., i1core, i2core )
    call scalarsethalo( tarr, -1., i1core, i2core )
    fstats(jf,1) = maxval( f1 )
    fstats(jf,2) = maxval( f2 )
    fstats(jf,3) = maxval( sl )
    fstats(jf,4) = maxval( tarr )
  case( 2 )
    call scalarsethalo( ts, -1., i1core, i2core )
    call scalarsethalo( f2, -1., i1core, i2core )
    fstats(jf,5) = maxval( ts )
    fstats(jf,6) = maxval( f2 )
    rr = -2. * abs( minval( tn ) ) - 1.
    call scalarsethalo( tn, rr, i1core, i2core )
    fstats(jf,7) = maxval( tn )
    rr = 2. * abs( fstats(jf,7) ) + 1.
    call scalarsethalo( tn, rr, i1core, i2core )
    fstats(jf,8) = -minval( tn )
    estats(jf,1) = efric
    estats(jf,2) = estrain
    estats(jf,3) = moment
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rreduce2( gfstats, fstats, 'allmax', ifn )
      call rreduce2( gestats, estats, 'allsum', ifn )
      if ( master ) then
        gfstats(:jf,8) = -gfstats(:jf,8)
        gestats(:jf,4) = -999
        do i = 1, jf
          if ( gestats(i,3) > 0. ) gestats(i,4) = ( log10( gestats(i,3) ) - 9.05 ) / 1.5
        end do
        call rwrite1( 'stats/svmax',   gfstats(:jf,1), it / itstats )
        call rwrite1( 'stats/sumax',   gfstats(:jf,2), it / itstats )
        call rwrite1( 'stats/slmax',   gfstats(:jf,3), it / itstats )
        call rwrite1( 'stats/tarrmax', gfstats(:jf,4), it / itstats )
        call rwrite1( 'stats/tsmax',   gfstats(:jf,5), it / itstats )
        call rwrite1( 'stats/samax',   gfstats(:jf,6), it / itstats )
        call rwrite1( 'stats/tnmax',   gfstats(:jf,7), it / itstats )
        call rwrite1( 'stats/tnmin',   gfstats(:jf,8), it / itstats )
        call rwrite1( 'stats/efric',   gestats(:jf,1), it / itstats )
        call rwrite1( 'stats/estrain', gestats(:jf,2), it / itstats )
        call rwrite1( 'stats/moment',  gestats(:jf,3), it / itstats )
        call rwrite1( 'stats/mw',      gestats(:jf,4), it / itstats ) 
        i1 = ihypo
        i1(ifn) = 1  
        open( 1, file='stats/tarrhypo', status='replace' )
        write( 1, * ) tarr(i1(1),i1(2),i1(3))
        close( 1 )
      end if
      jf = 0
    end if
  end select
end if

doiz: do iz = 1, nout

! Pass
call outprops( fieldout(iz), nc, onpass, fault, cell )
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,1:3)
i2 = i2out(iz,1:3)
i3 = max( i1, i1core )
i4 = min( i2, i2core )

! Peak velocity calculation
if ( fieldout(iz) == 'pv2' .and. all( i3 >= i4 ) ) then
  if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3, i4 )
  forall( j=i1(1):i2(1), k=i1(2):i2(2), l=i1(3):i2(3) )
    pv(j,k,l) = max( pv(j,k,l), s1(j,k,l) )
  end forall
end if

! Time indices
if ( it < i1out(iz,4) .or. it > i2out(iz,4) ) cycle doiz
if ( modulo( it - i1out(iz,4), ditout(iz) ) /= 0 ) cycle doiz

! Test if any thing to do on this processor, can't cycle yet though
! because all processors have to call mpi_split
if ( any( i3 > i4 ) ) then
  i1out(iz,4) = nt + 1
  if ( all( i1 == i2 ) ) cycle doiz
end if

! Record number and number of records
ir = ( it          - i1out(iz,4) ) / ditout(iz) + 1
nr = ( i2out(iz,4) - i1out(iz,4) ) / ditout(iz) + 1

! Fault plane
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
  id = 6 * ( iz - 1 ) + ic
  write( str, '(a,i2.2,a)' ) 'out/', iz, fieldout(iz)
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( mpout == 0 ) then
    i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
    if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, nr, ir )
  case( 'rho'  ); call scalario( id, mpio, rr, str, mr,       i1, i2, i3, i4, nr, ir )
  case( 'vp'   ); call scalario( id, mpio, rr, str, s1,       i1, i2, i3, i4, nr, ir )
  case( 'vs'   ); call scalario( id, mpio, rr, str, s2,       i1, i2, i3, i4, nr, ir )
  case( 'gam'  ); call scalario( id, mpio, rr, str, gam,      i1, i2, i3, i4, nr, ir )
  case( 'lam'  ); call scalario( id, mpio, rr, str, lam,      i1, i2, i3, i4, nr, ir )
  case( 'mu'   ); call scalario( id, mpio, rr, str, mu,       i1, i2, i3, i4, nr, ir )
  case( 'v'    ); call vectorio( id, mpio, rr, str, vv, ic,   i1, i2, i3, i4, nr, ir )
  case( 'u'    ); call vectorio( id, mpio, rr, str, uu, ic,   i1, i2, i3, i4, nr, ir )
  case( 'w'    );                                                                   
   if ( ic < 4 )  call vectorio( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, nr, ir )
   if ( ic > 3 )  call vectorio( id, mpio, rr, str, w2, ic-3, i1, i2, i3, i4, nr, ir )
  case( 'a'    ); call vectorio( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, nr, ir )
  case( 'nhat' ); call vectorio( id, mpio, rr, str, nhat, ic, i1, i2, i3, i4, nr, ir )
  case( 'mus'  ); call scalario( id, mpio, rr, str, mus,      i1, i2, i3, i4, nr, ir )
  case( 'mud'  ); call scalario( id, mpio, rr, str, mud,      i1, i2, i3, i4, nr, ir )
  case( 'dc'   ); call scalario( id, mpio, rr, str, dc,       i1, i2, i3, i4, nr, ir )
  case( 'co'   ); call scalario( id, mpio, rr, str, co,       i1, i2, i3, i4, nr, ir )
  case( 'sv'   ); call vectorio( id, mpio, rr, str, t1, ic,   i1, i2, i3, i4, nr, ir )
  case( 'su'   ); call vectorio( id, mpio, rr, str, t2, ic,   i1, i2, i3, i4, nr, ir )
  case( 'ts'   ); call vectorio( id, mpio, rr, str, t1, ic,   i1, i2, i3, i4, nr, ir )
  case( 'sa'   ); call vectorio( id, mpio, rr, str, t2, ic,   i1, i2, i3, i4, nr, ir )
  case( 'svm'  ); call scalario( id, mpio, rr, str, f1,       i1, i2, i3, i4, nr, ir )
  case( 'sum'  ); call scalario( id, mpio, rr, str, f2,       i1, i2, i3, i4, nr, ir )
  case( 'tsm'  ); call scalario( id, mpio, rr, str, ts,       i1, i2, i3, i4, nr, ir )
  case( 'sam'  ); call scalario( id, mpio, rr, str, f2,       i1, i2, i3, i4, nr, ir )
  case( 'tn'   ); call scalario( id, mpio, rr, str, tn,       i1, i2, i3, i4, nr, ir )
  case( 'fr'   ); call scalario( id, mpio, rr, str, f1,       i1, i2, i3, i4, nr, ir )
  case( 'sl'   ); call scalario( id, mpio, rr, str, sl,       i1, i2, i3, i4, nr, ir )
  case( 'psv'  ); call scalario( id, mpio, rr, str, psv,      i1, i2, i3, i4, nr, ir )
  case( 'trup' ); call scalario( id, mpio, rr, str, trup,     i1, i2, i3, i4, nr, ir )
  case( 'tarr' ); call scalario( id, mpio, rr, str, tarr,     i1, i2, i3, i4, nr, ir )
  case( 'pv2'  ); call scalario( id, mpio, rr, str, pv,       i1, i2, i3, i4, nr, ir )
  case( 'vm2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3, i4 )
    call scalario( id, mpio, rr, str, s1, i1, i2, i3, i4, nr, ir )
  case( 'um2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, uu, i3, i4 )
    call scalario( id, mpio, rr, str, s1, i1, i2, i3, i4, nr, ir )
  case( 'wm2'  )
    if ( modulo( it, itstats ) /= 0 ) call tensornorm( s2, w1, w2, i3, i4 )
    call scalario( id, mpio, rr, str, s2, i1, i2, i3, i4, nr, ir )
  case( 'am2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s2, w1, i3, i4 )
    call scalario( id, mpio, rr, str, s2, i1, i2, i3, i4, nr, ir )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
  if ( all( i1 == i2 .and. i3 == i4 ) ) then
  if ( it == 0 .or. ibuff(iz) == 0 ) then
    call rwrite( str, rr, ir )
  else
    i = ibuff(iz) + ic - 1
    jb(i) = jb(i) + 1
    iobuffer(jb(i),i) = rr
    if ( modulo( it, itio ) == 0 .or. it == nt ) then
      call rwrite1( str, iobuffer(:jb(i),i), ir )
      jb(i) = 0
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

