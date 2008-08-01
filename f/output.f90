! Output routines
module m_output
implicit none
integer, private :: jv, jf
integer, private, allocatable :: jb(:)
real, private, allocatable, dimension(:,:) :: &
  vstats, fstats, estats, gvstats, gfstats, gestats, iobuffer
contains

! Initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
type( t_io ), pointer :: o
real :: rout, x0(3)
integer :: i1(3), i2(3), di(3), n(3), noff(3), i, nc, iz, onpass
logical :: dofault, fault, cell

if ( master ) write( 0, * ) 'Output initialization'

! I/O intervals
if ( itstats < 1 ) itstats = itstats + nt + 1
if ( itio    < 1 ) itio    = itio    + nt + 1
if ( itcheck < 1 ) itcheck = itcheck + nt + 1
if ( modulo( itcheck, itio ) /= 0 ) itcheck = ( itcheck / itio + 1 ) * itio

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3root(i) ) dofault = .true.
end if

o => out0
doiz: do while( associated( o%next ) )
o => o%next

! Output field properties
call outprops( o%field, nc, onpass, fault, cell )
if ( fault .and. .not. dofault ) then
  o%i1(4) = nt + 1
  cycle doiz
end if

! Time indices 
if ( o%i1(4) < 0 ) o%i1(4) = nt + o%i1(4) + 1
if ( o%i2(4) < 0 ) o%i2(4) = nt + o%i2(4) + 1
if ( o%di(4) < 0 ) o%di(4) = nt + o%di(4) + 1
if ( onpass == 0 ) then
  o%di(4) = 1
  o%i1(4) = 0
  o%i2(4) = 0
end if
o%i2(4) = min( o%i2(4), nt )

! Spatial indices
n = nn + 2 * nhalo
noff = nnoff + nhalo
select case( o%otype )
case( 'z' )
  i1 = o%i1(1:3)
  i2 = o%i2(1:3)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  if ( cell ) i2 = i2 - 1
  if ( fault ) then
    i = abs( faultnormal )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
  end if
  if ( any( i2 < i1 ) ) o%i1(4) = nt + 1
case( 'x' )
  x0 = o%x0
  o%di(4) = 1
  o%i1(4) = 0
  o%i2(4) = nt
  if ( onpass == 0 ) o%i2(4) = 0
  rout = huge( rout )
  if ( fault ) then
    i1 = nnoff
    if ( dofault ) then
      i = abs( faultnormal )
      i1 = 1
      i2 = nm
      i1(i) = ihypo(i)
      i2(i) = ihypo(i)
      call radius( s2, w1, x0, i1, i2 )
      f2 = s2(i1(1):i2(1),i1(2):i2(2),i1(3):i2(3))
      call scalarsethalo( f2, rout, i1node, i2node )
      call reduceloc( rout, i1, f2, 'allmin', n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      i1 = max( i1core, i1cell )
      i2 = min( i2core, i2cell )
      call radius( s2, w2, x0, i1, i2 )
      call scalarsethalo( s2, rout, i1, i2 )
    else
      call radius( s2, w1, x0, i1core, i2core )
      call scalarsethalo( s2, rout, i1core, i2core )
    end if
    call reduceloc( rout, i1, s2, 'allmin', n, noff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) o%i1(4) = nt + 1
end select

! Save paramters and allocate buffer
di = o%di(1:3)
o%it = 0
o%ib = 1
o%i1(1:3) = i1
o%i2(1:3) = i2
where( i1 < i1core ) i1 = i1 + ( ( i1core - i1 - 1 ) / di + 1 ) * di
where( i2 > i2core ) i2 = i1 + (   i2core - i1     ) / di       * di
o%i3 = i1
o%i4 = i2
n = i2 - i1 + 1
allocate( o%buff(n(1),n(2),n(3),o%nt,nc,2) )

end do doiz

! Allocate stats buffers
allocate( vstats(itio,4), fstats(itio,8), estats(itio,3), &
  gvstats(itio,4), gfstats(itio,8), gestats(itio,3) )
jv = 0
jf = 0
vstats = 0.
fstats = 0.
estats = 0.
gvstats = 0.
gfstats = 0.
gestats = 0.

end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine output( pass )
use m_globals
use m_collective
use m_outprops
use m_util
use m_debug_out
integer, intent(in) :: pass
integer :: i1(3), i2(3), i3(3), i4(3), i, j, k, l, onpass, nc, ic, nr, ir, iz, id, mpio
real :: rr
logical :: dofault, fault, cell
type( t_io ), pointer :: o

! Stats
if ( master .and. ( it == 0 .or. debug == 2 ) ) write( 0, '(a,i2)' ) ' Output pass', pass
if ( debug > 2 ) call debug_out( pass )

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ip3(i) == ip3root(i) ) dofault = .true.
end if

! Volume stats
if ( it > 0 ) then
select case( pass )
case( 1 )
  if ( modulo( it, itstats ) == 0 ) then
    jv = jv + 1
    call vectornorm( s1, vv, i1core, i2core )
    call tensornorm( s2, w1, w2, i1core, i2core )
    call scalarsethalo( s1, -1., i1core, i2core )
    call scalarsethalo( s2, -1., i1core, i2core )
    vstats(jv,1) = maxval( s1 )
    vstats(jv,2) = maxval( s2 )
  end if
case( 2 )
  if ( modulo( it, itstats ) == 0 ) then
    call vectornorm( s1, uu, i1core, i2core )
    call vectornorm( s2, w1, i1core, i2core )
    call scalarsethalo( s1, -1., i1core, i2core )
    call scalarsethalo( s2, -1., i1core, i2core )
    vstats(jv,3) = maxval( s1 )
    vstats(jv,4) = maxval( s2 )
    rr = maxval( vstats )
    if ( rr /= rr .or. rr > huge( rr ) ) stop 'NaN/Inf!'
  end if
  if ( modulo( it, itio ) == 0 .or. ( it == nt .and. jv > 0 ) ) then
    call rreduce2( gvstats, vstats, 'max', 0 )
    if ( master ) then
      gvstats = sqrt( gvstats )
      call rio1( 21, mpout, 'stats/vmax', gvstats(:jv,1), it/itstats, nt/itstats )
      call rio1( 22, mpout, 'stats/wmax', gvstats(:jv,2), it/itstats, nt/itstats )
      call rio1( 23, mpout, 'stats/umax', gvstats(:jv,3), it/itstats, nt/itstats )
      call rio1( 24, mpout, 'stats/amax', gvstats(:jv,4), it/itstats, nt/itstats )
      rr = maxval( gvstats(:jv,3) )
      if ( rr > dx / 10. ) write( 0, * ) 'warning: u !<< dx', rr, dx
    end if
    jv = 0
  end if
end select
end if

! Fault stats
if ( it > 0 .and. dofault ) then
select case( pass )
case( 1 )
  if ( modulo( it, itstats ) == 0 ) then
    jf = jf + 1
    call scalarsethalo( f1,   -1., i1core, i2core )
    call scalarsethalo( f2,   -1., i1core, i2core )
    call scalarsethalo( tarr, -1., i1core, i2core )
    fstats(jf,1) = maxval( f1 )
    fstats(jf,2) = maxval( f2 )
    fstats(jf,3) = maxval( sl )
    fstats(jf,4) = maxval( tarr )
  end if
case( 2 )
  if ( modulo( it, itstats ) == 0 ) then
    call scalarsethalo( ts, -1., i1core, i2core )
    call scalarsethalo( f2, -1., i1core, i2core )
    fstats(jf,5) = maxval( ts )
    fstats(jf,6) = maxval( f2 )
    call scalarsethalo( tn, -huge(rr), i1core, i2core ); fstats(jf,7) =  maxval( tn )
    call scalarsethalo( tn,  huge(rr), i1core, i2core ); fstats(jf,8) = -minval( tn )
    call scalarsethalo( tn, 0., i1core, i2core )
    estats(jf,1) = efric
    estats(jf,2) = estrain
    estats(jf,3) = moment
    rr = maxval( fstats )
    if ( rr /= rr .or. rr > huge( rr ) ) stop 'NaN/Inf!'
  end if
  if ( modulo( it, itio ) == 0 .or. ( it == nt .and. jf > 0 ) ) then
    call rreduce2( gfstats, fstats, 'max', ifn )
    call rreduce2( gestats, estats, 'sum', ifn )
    if ( master ) then
      gfstats(:jf,8) = -gfstats(:jf,8)
      call rio1( 25, mpout, 'stats/svmax',   gfstats(:jf,1), it/itstats, nt/itstats )
      call rio1( 26, mpout, 'stats/sumax',   gfstats(:jf,2), it/itstats, nt/itstats )
      call rio1( 27, mpout, 'stats/slmax',   gfstats(:jf,3), it/itstats, nt/itstats )
      call rio1( 28, mpout, 'stats/tarrmax', gfstats(:jf,4), it/itstats, nt/itstats )
      call rio1( 29, mpout, 'stats/tsmax',   gfstats(:jf,5), it/itstats, nt/itstats )
      call rio1( 30, mpout, 'stats/samax',   gfstats(:jf,6), it/itstats, nt/itstats )
      call rio1( 31, mpout, 'stats/tnmax',   gfstats(:jf,7), it/itstats, nt/itstats )
      call rio1( 32, mpout, 'stats/tnmin',   gfstats(:jf,8), it/itstats, nt/itstats )
      call rio1( 33, mpout, 'stats/efric',   gestats(:jf,1), it/itstats, nt/itstats )
      call rio1( 34, mpout, 'stats/estrain', gestats(:jf,2), it/itstats, nt/itstats )
      call rio1( 35, mpout, 'stats/moment',  gestats(:jf,3), it/itstats, nt/itstats )
      do i = 1, jf
      if ( gestats(i,3) > 0. ) then 
        gestats(i,3) = ( log10( gestats(i,3) ) - 9.05 ) / 1.5
      else
        gestats(i,3) = -999
      end if
      end do
      call rio1( 36, mpout, 'stats/mw',      gestats(:jf,3), it/itstats, nt/itstats )
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

o => out0
doiz: do while( associated( o%next ) )
o => o%next

! Pass
if ( o%di(4) < 1 ) cycle doiz
call outprops( o%field, nc, onpass, fault, cell )
if ( pass /= onpass ) cycle doiz

! Indices
i1 = o%i1(1:3)
i2 = o%i2(1:3)
i3 = o%i3
i4 = o%i4

! Peak velocity calculation
if ( o%field == 'pv2' .and. all( i3 <= i4 ) ) then
  if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3, i4 )
  do l = i3(3), i4(3)
  do k = i3(2), i4(2)
  do j = i3(1), i4(1)
    pv(j,k,l) = max( pv(j,k,l), s1(j,k,l) )
  end do
  end do
  end do
end if

! Time indices
if ( it < o%i1(4) .or. it > o%i2(4) ) cycle doiz
if ( modulo( it - o%i1(4), o%di(4) ) /= 0 ) cycle doiz

! Test if any thing to do on this processor, can't cycle yet though
! because all processors have to call mpi_split
if ( any( i3 > i4 ) ) then
  o%i1(4) = nt + 1
  if ( all( i1 == i2 ) ) cycle doiz
end if

! Record number and number of records
ir = ( it      - o%i1(4) ) / o%di(4) + 1
nr = ( o%i2(4) - o%i1(4) ) / o%di(4) + 1

! Fault plane
mpio = mpout * 4
if ( fault ) then
  i = abs( faultnormal )
  mpio = mpout * i
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Binary output
do ic = 1, nc
  id = 64 + 6 * ( iz - 1 ) + ic
  write( str, '(a,i2.2,a)' ) 'out/', iz, o%field
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( mpout == 0 ) then
    i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
    if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
  end if
  select case( o%field )
  case( 'x'    ); call rio4( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'rho'  ); call rio3( id, mpio, rr, str, mr,       i1, i2, i3, i4, i4, ir, nr )
  case( 'vp'   ); call rio3( id, mpio, rr, str, s1,       i1, i2, i3, i4, i4, ir, nr )
  case( 'vs'   ); call rio3( id, mpio, rr, str, s2,       i1, i2, i3, i4, i4, ir, nr )
  case( 'lam'  ); call rio3( id, mpio, rr, str, lam,      i1, i2, i3, i4, i4, ir, nr )
  case( 'mu'   ); call rio3( id, mpio, rr, str, mu,       i1, i2, i3, i4, i4, ir, nr )
  case( 'gam'  ); call rio3( id, mpio, rr, str, gam,      i1, i2, i3, i4, i4, ir, nr )
  case( 'gamt' ); call rio3( id, mpio, rr, str, gam,      i1, i2, i3, i4, i4, ir, nr )
  case( 'mr'   ); call rio3( id, mpio, rr, str, mr,       i1, i2, i3, i4, i4, ir, nr )
  case( 'v'    ); call rio4( id, mpio, rr, str, vv, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'u'    ); call rio4( id, mpio, rr, str, uu, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'w'    );
   if ( ic < 4 )  call rio4( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, i4, ir, nr )
   if ( ic > 3 )  call rio4( id, mpio, rr, str, w2, ic-3, i1, i2, i3, i4, i4, ir, nr )
  case( 'a'    ); call rio4( id, mpio, rr, str, w1, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'nhat' ); call rio4( id, mpio, rr, str, nhat, ic, i1, i2, i3, i4, i4, ir, nr )
  case( 'mus'  ); call rio3( id, mpio, rr, str, mus,      i1, i2, i3, i4, i4, ir, nr )
  case( 'mud'  ); call rio3( id, mpio, rr, str, mud,      i1, i2, i3, i4, i4, ir, nr )
  case( 'dc'   ); call rio3( id, mpio, rr, str, dc,       i1, i2, i3, i4, i4, ir, nr )
  case( 'co'   ); call rio3( id, mpio, rr, str, co,       i1, i2, i3, i4, i4, ir, nr )
  case( 'sv'   ); call rio4( id, mpio, rr, str, t1, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'su'   ); call rio4( id, mpio, rr, str, t2, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'ts'   ); call rio4( id, mpio, rr, str, t3, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'sa'   ); call rio4( id, mpio, rr, str, t2, ic,   i1, i2, i3, i4, i4, ir, nr )
  case( 'svm'  ); call rio3( id, mpio, rr, str, f1,       i1, i2, i3, i4, i4, ir, nr )
  case( 'sum'  ); call rio3( id, mpio, rr, str, f2,       i1, i2, i3, i4, i4, ir, nr )
  case( 'tsm'  ); call rio3( id, mpio, rr, str, ts,       i1, i2, i3, i4, i4, ir, nr )
  case( 'sam'  ); call rio3( id, mpio, rr, str, f2,       i1, i2, i3, i4, i4, ir, nr )
  case( 'tn'   ); call rio3( id, mpio, rr, str, tn,       i1, i2, i3, i4, i4, ir, nr )
  case( 'fr'   ); call rio3( id, mpio, rr, str, f1,       i1, i2, i3, i4, i4, ir, nr )
  case( 'sl'   ); call rio3( id, mpio, rr, str, sl,       i1, i2, i3, i4, i4, ir, nr )
  case( 'psv'  ); call rio3( id, mpio, rr, str, psv,      i1, i2, i3, i4, i4, ir, nr )
  case( 'trup' ); call rio3( id, mpio, rr, str, trup,     i1, i2, i3, i4, i4, ir, nr )
  case( 'tarr' ); call rio3( id, mpio, rr, str, tarr,     i1, i2, i3, i4, i4, ir, nr )
  case( 'pv2'  ); call rio3( id, mpio, rr, str, pv,       i1, i2, i3, i4, i4, ir, nr )
  case( 'vm2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3, i4 )
    call rio3( id, mpio, rr, str, s1, i1, i2, i3, i4, i4, ir, nr )
  case( 'um2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, uu, i3, i4 )
    call rio3( id, mpio, rr, str, s1, i1, i2, i3, i4, i4, ir, nr )
  case( 'wm2'  )
    if ( modulo( it, itstats ) /= 0 ) call tensornorm( s2, w1, w2, i3, i4 )
    call rio3( id, mpio, rr, str, s2, i1, i2, i3, i4, i4, ir, nr )
  case( 'am2'  )
    if ( modulo( it, itstats ) /= 0 ) call vectornorm( s2, w1, i3, i4 )
    call rio3( id, mpio, rr, str, s2, i1, i2, i3, i4, i4, ir, nr )
  case default
    write( 0, * ) 'error: unknown output field: ', o%field
    stop
  end select
  if ( all( i1 == i2 .and. i3 == i4 ) ) then
    i = ibuff(iz) + ic - 1
    if ( i == 0 ) stop 'unknown buffer'
    jb(i) = jb(i) + 1
    iobuffer(jb(i),i) = rr
    if ( it == nt .or. modulo( it, itio ) == 0 ) then
      call rio1( id, mpout, str, iobuffer(:jb(i),i), ir, nr )
      jb(i) = 0
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

