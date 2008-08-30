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
use m_util
real, pointer :: ps0(:,:,:), pw1(:,:,:,:), pw2(:,:,:,:)
real :: rout, x0(3)
integer :: i1(3), i2(3), di(3), n(3), noff(3), i, nc, pass
logical :: dofault, fault, cell
type( t_io ), pointer :: p

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

! Loop over output zones
p => outp0
doiz: do while( associated( p%next ) )
p => p%next

! Properties
nc = 1
fault = .false.
pass = 2
cell = .false.
select case( p%field )
case( 'x'    ); pw1 => w1;   pass = 0; nc = 3
case( 'rho'  ); ps0 => mr;   pass = 0; cell = .true.
case( 'vp'   ); ps0 => s1;   pass = 0; cell = .true.
case( 'vs'   ); ps0 => s2;   pass = 0; cell = .true.
case( 'lam'  ); ps0 => lam;  pass = 0; cell = .true.
case( 'mu'   ); ps0 => mu;   pass = 0; cell = .true.
case( 'gam'  ); ps0 => gam;  pass = 0; cell = .true.
case( 'gamt' ); ps0 => gam
case( 'mr'   ); ps0 => mr
case( 'v'    ); pw1 => vv;   nc = 3
case( 'u'    ); pw1 => uu;   nc = 3
case( 'w'    ); pw1 => w1; pw2 => w2; pass = 1; cell = .true.; nc = 6
case( 'a'    ); pw1 => w1;   nc = 3
case( 'nhat' ); pw1 => nhat; fault = .true.; pass = 0; nc = 3
case( 'mus'  ); ps0 => mus;  fault = .true.; pass = 0
case( 'mud'  ); ps0 => mud;  fault = .true.; pass = 0
case( 'dc'   ); ps0 => dc;   fault = .true.; pass = 0
case( 'co'   ); ps0 => co;   fault = .true.; pass = 0
case( 'sv'   ); pw1 => t1;   fault = .true.; pass = 1; nc = 3
case( 'su'   ); pw1 => t2;   fault = .true.; pass = 1; nc = 3
case( 'ts'   ); pw1 => t3;   fault = .true.; nc = 3
case( 'sa'   ); pw1 => t2;   fault = .true.; nc = 3
case( 'svm'  ); ps0 => f1;   fault = .true.; pass = 1
case( 'sum'  ); ps0 => f2;   fault = .true.; pass = 1
case( 'tsm'  ); ps0 => ts;   fault = .true.
case( 'sam'  ); ps0 => f2;   fault = .true.
case( 'tn'   ); ps0 => tn;   fault = .true.
case( 'fr'   ); ps0 => f1;   fault = .true.
case( 'sl'   ); ps0 => sl;   fault = .true.
case( 'psv'  ); ps0 => psv;  fault = .true.; pass = 1
case( 'trup' ); ps0 => trup; fault = .true.
case( 'tarr' ); ps0 => tarr; fault = .true.
case( 'pv2'  ); ps0 => pv;   pass = 1
case( 'vm2'  ); ps0 => s1;   pass = 1;
case( 'um2'  ); ps0 => s1
case( 'wm2'  ); ps0 => s2;   pass = 1; cell = .true.            
case( 'am2'  ); ps0 => s2
case default
  write( 0, * ) 'error: unknown output field: ', p%field
  stop
end select
if ( fault .and. .not. dofault ) then
  p%i1(4) = nt + 1
  cycle doiz
end if

! Time indices
if ( p%i1(4) < 0 ) p%i1(4) = nt + p%i1(4) + 1
if ( p%i2(4) < 0 ) p%i2(4) = nt + p%i2(4) + 1
if ( p%di(4) < 0 ) p%di(4) = nt + p%di(4) + 1
if ( p%pass == 0 ) then
  p%di(4) = 1
  p%i1(4) = 0
  p%i2(4) = 0
end if
p%i2(4) = min( p%i2(4), nt )
p%i3(4) = p%i1(4)
p%i4(4) = 0

! Spatial indices
n = nn + 2 * nhalo
noff = nnoff + nhalo
select case( p%mode )
case( 'z' )
  i1 = p%i1(1:3)
  i2 = p%i2(1:3)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  if ( cell ) i2 = i2 - 1
  if ( fault ) then
    i = abs( faultnormal )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
  end if
  if ( any( i2 < i1 ) ) p%i1(4) = nt + 1
case( 'x' )
  x0 = p%x1
  p%di(4) = 1
  p%i1(4) = 0
  p%i2(4) = nt
  if ( p%pass == 0 ) p%i2(4) = 0
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
  if ( rout > dx * dx ) p%i1(4) = nt + 1
end select

! Save paramters and allocate buffer
di = p%di(1:3)
p%nc = nc
p%i1(1:3) = i1
p%i2(1:3) = i2
where( i1 < i1core ) i1 = i1 + ( ( i1core - i1 - 1 ) / di + 1 ) * di
where( i2 > i2core ) i2 = i1 + (   i2core - i1     ) / di       * di
p%i3(1:3) = i1
p%i4(1:3) = i2
n = i2 - i1 + 1
allocate( p%buff(n(1),n(2),n(3),p%nb,nc) )

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
integer :: i1(4), i2(4), i3(4), i4(4), id(4), i, j, k, l, ic, iz, id, mpio
logical :: dofault, fault, cell
real :: rr
real, pointer :: f(:,:,:)
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

! Loop over output zones
iz = 0
o => out0
doiz: do while( associated( p%next ) )
o => p%next
iz = iz + 1

! Pass
if ( p%di(4) < 1 .or. pass /= p%pass ) cycle doiz

! Indices
i1 = p%i1
i2 = p%i2
i3 = p%i3
i4 = p%i4
di = p%di

! Peak velocity calculation
if ( p%field == 'pv2' .and. all( i3(1:3) <= i4(1:3) ) ) then
  if ( modulo( it, itstats ) /= 0 ) call vectornorm( s1, vv, i3(1:3), i4(1:3) )
  do l = i3(3), i4(3)
  do k = i3(2), i4(2)
  do j = i3(1), i4(1)
    pv(j,k,l) = max( pv(j,k,l), s1(j,k,l) )
  end do
  end do
  end do
end if

! Time indices
if ( it < p%i1(4) .or. it > p%i2(4) ) cycle doiz
if ( modulo( it - p%i1(4), p%di(4) ) /= 0 ) cycle doiz
p%i4(4) = it
i4(4) = it

! Test if any thing to do on this processor, can't cycle yet though
! because all processors have to call mpi_split
if ( any( i3(1:3) > i4(1:3) ) ) then
  p%i1(4) = nt + 1
  if ( all( i1 == i2 ) ) cycle doiz
end if

! Fault plane
mpio = mpout * 4
if ( p%fault ) then
  i = abs( faultnormal )
  mpio = mpout * i
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Compute magnitudes and buffer output
if ( all( i3 <= i4 ) ) then
  if ( modulo( it, itstats ) /= 0 ) then
    select case( p%field )
    case( 'vm2' ); call vectornorm( s1, vv, i3(1:3), i4(1:3) )
    case( 'um2' ); call vectornorm( s1, uu, i3(1:3), i4(1:3) )
    case( 'wm2' ); call tensornorm( s2, w1, w2, i3(1:3), i4(1:3) )
    case( 'am2' ); call vectornorm( s2, w1, i3(1:3), i4(1:3) )
    end select
  end if
  i = ( it - i3(4) ) / di(4)
  do ic = 1, p%nc
    if ( nc == 1 ) then
      p%buff(:,:,:,i,1)  = p%ps0(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3))
    elseif ( ic < 4 ) then
      p%buff(:,:,:,i,ic) = p%pw1(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3),ic)
    else
      p%buff(:,:,:,i,ic) = p%pw2(i3(1):i4(1):di(1),i3(2):i4(2):di(2),i3(3):i4(3):di(3),ic-3)
    end if
  end do
end if

! Write to disk
i1 = ( i1 - i3 ) / di + 1
i2 = ( i2 - i3 ) / di + 1
i4 = ( i4 - i3 ) / di + 1
i3 = 1
if ( i4(4) == p%nb .or. i4(4) == i2(4) ) then
  do ic = 1, p%nc
    id = 64 + 6 * ( iz - 1 ) + ic
    write( str, '(a,i2.2,a)' ) 'out/', iz, p%field
    if ( p%nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
    if ( mpout == 0 ) then
      i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
      if ( any( i1 /= i3 .or. i2 /= i4 ) ) write( str, '(a,i6.6)' ) trim( str ), i
    end if
    call rio4( id, mpio, p%buff, i1, i2, i3, i4, i4 )
  end do
  p%i3(4) = it + di(4)
  p%i4(4) = 0
end if

end do doiz

! Iteration counter
if ( master .and. pass == 2 .and. ( modulo( it, itio ) == 0 .or. it == nt ) ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

