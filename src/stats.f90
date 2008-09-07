! Stats
module m_stats
integer, private :: jv, jf
real, private, allocatable, dimension(:,:) :: &
  vstats, fstats, estats, gvstats, gfstats, gestats, iobuffer
contains

! Write output
subroutine stats( pass )
use m_globals
use m_collective
use m_util
integer, intent(in) :: pass
integer :: i
logical :: dofault, init = .false.
real :: rr

! Allocate buffers
if ( .not. init ) then
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
end if

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

end subroutine

end module

