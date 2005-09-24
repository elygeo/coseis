!------------------------------------------------------------------------------!
! Write output

module output_m
use globals_m
use collective_m
use collectiveio_m
contains
subroutine output( pass )

implicit none
save
real :: dtwall(4), courant, amax, vmax, umax, wmax, svmax, slmax
integer :: i, i1(3), i2(3), iz, nc, n(3), noff(3), reclen, twall(2), err, &
  twall_rate, amaxi(3), vmaxi(3), umaxi(3), wmaxi(3), svmaxi(3), slmaxi(3)
character, intent(in) :: pass
character :: onpass, endian
character(160) :: str
logical :: fault, static, init = .true., test

ifinit: if ( init ) then !--------------------------------------!

init = .false.
call system_clock( count_rate=twall_rate )
if ( itcheck < 0 ) itcheck = itcheck + nt + 1

! Look for checkpoint
write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if
call globalmin( it )

ifrestart: if ( it /= 0 ) then !------------------!

! Read checkpoint
if ( master ) print '(a,i6)', 'Checkpoint found, starting from step ', it
write( str, '(a,i6.6,i6.6)' ) 'out/ckp/', ip, it
inquire( iolength=reclen ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
open( 9, &
  file=str, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 9, rec=1 ) &
  t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
close( 9 )

else if ( master ) then !------------------!

! Check for previus run
inquire( file='out/timestep', exist=test )
if ( err /= 0 ) then
  print '(a)', 'Error: previous output found. use -d flag to overwrite'
  stop
end if
print '(a)', 'Initialize output'

! Create directories
call system( 'mkdir out/ckp' )
call system( 'mkdir out/stats' )
do iz = 1, nout
  write( str, '(a,i2.2)' ) 'out/', iz
  call system( 'mkdir ' // str )
end do

! Metadata
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
courant = dt * vp2 * sqrt( 3. ) / abs( dx )
write( str, '(a,i2.2,a)' ) 'out/meta.m'
open(  9, file=str, status='new' )
write( 9, * ) ' rho1    =   ', rho1,     ';% minimum density'
write( 9, * ) ' vp1     =   ', vp1,      ';% minimum Vp'
write( 9, * ) ' vs1     =   ', vs1,      ';% minimum Vp'
write( 9, * ) ' rho2    =   ', rho2,     ';% maximum density'
write( 9, * ) ' vp2     =   ', vp2,      ';% maximum Vp'
write( 9, * ) ' vs2     =   ', vs2,      ';% maximum Vp'
write( 9, * ) ' rho     =   ', rho,      ';% hypocenter density'
write( 9, * ) ' vp      =   ', vp,       ';% hypocenter Vp'
write( 9, * ) ' vs      =   ', vs,       ';% hypocenter Vp'
write( 9, * ) ' courant =   ', courant,  ';% stability condition'
write( 9, * ) ' xhypo   = [ ', xhypo, '  ];% hypocenter location'
write( 9, * ) ' nout    =   ', nout,     ';% number output zones'
write( 9, * ) ' endian  = ''', endian, ''';% byte ordert'
close( 9 )

end if ifrestart !------------------!

if ( nout > nz ) stop 'too many output zones, make nz bigger'

doizinit: do iz = 1, nout !------------------!

select case( fieldout(iz) )
case( 'x'    ); nc = 3
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3
case( 'w'    ); nc = 6
case( 'sv'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'trup' ); fault = .true.
case default; nc = 1; fault = .false.
end select

if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
call zone( i1out(i,:), i2out(i,:), nn, nnoff, ihypo, ifn )
if ( fault ) then
  if ( ifn == 0 ) then
    ditout(iz) = 0
  else
    i1out(iz,ifn) = ihypo(ifn)
    i2out(iz,ifn) = ihypo(ifn)
  end if
end if
if ( fieldout(iz)(1:1) == 'w' ) i2out(i,:) = i2out(i,:) - 1

! Metadata
if ( master ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/meta.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) ' field = ''', fieldout(iz),        '''; % variable name'
  write( 9, * ) ' nc    = ',   nc,                    '; % # of components'
  write( 9, * ) ' i1    = [ ', i1out(iz,:) - nnoff, ' ]; % start index'
  write( 9, * ) ' i2    = [ ', i2out(iz,:) - nnoff, ' ]; % end index'
  write( 9, * ) ' dit   = ',   ditout(iz),            '; % interval'
  close( 9 )
end if

if ( any( i2 < i1 ) ) ditout(iz) = 0
call iosplit( iz, ditout(iz) )

end do doizinit !------------------!

if ( master ) then
  print '(a)', 'Time       Amax        Vmax        Umax        Wall Time'
end if

return

end if ifinit !--------------------------------------!

! Magnitudes
if ( pass == 'w' ) then
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  i1 = maxloc( s1 )
  i1 = maxloc( s2 )
  umax = s1(i1(1),i1(2),i1(3))
  wmax = s2(i1(1),i1(2),i1(3))
  call globalmaxloc( umax, umaxi, nnoff )
  call globalmaxloc( wmax, wmaxi, nnoff )
  if ( umax > dx / 10. ) print *, 'Warning: u !<< dx'
else
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  i1 = maxloc( s1 )
  i1 = maxloc( s2 )
  amax  = s1(i1(1),i1(2),i1(3))
  vmax  = s2(i1(1),i1(2),i1(3))
  call globalmaxloc( amax, amaxi, nnoff )
  call globalmaxloc( vmax, vmaxi, nnoff )
  if ( ifn /= 0 ) then
    i1 = maxloc( sv )
    i1 = maxloc( sl )
    svmax = sv(i1(1),i1(2),i1(3))
    slmax = sv(i1(1),i1(2),i1(3))
    isvmax(ifn) = ihypo(ifn)
    islmax(ifn) = ihypo(ifn)
    call globalmaxloc( svmax, svmaxi, nnoff )
    call globalmaxloc( slmax, slmaxi, nnoff )
  end if
end if

! Write output
doiz: do iz = 1, nout

if ( ditout(iz) == 0 .or. mod( it, ditout(iz) ) /= 0 ) cycle doiz

! Select pass
select case( fieldout(iz)(1:1) )
case( 'w' );  onpass = 'w'
case( 'u' );  onpass = 'w'
case default; onpass = 'a'
end select
if ( onpass /= pass ) cycle doiz

i1 = i1out(iz,:)
i2 = i2out(iz,:)
n = i2 - i1 + 1

if ( fieldout(iz) == 'x' ) ditout(iz) = 0

if ( fault ) then
  i1(ifn) = 1
  i2(ifn) = 1
end if

! Binary output
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( out_field(iz) ), i, it
  select case( fieldout(iz) )
  case( 'x'    ); call iovector( 'w', str, x,  i,    i1, i2, n, nnoff, iz )
  case( 'a'    ); call iovector( 'w', str, w1, i,    i1, i2, n, nnoff, iz )
  case( 'v'    ); call iovector( 'w', str, v,  i,    i1, i2, n, nnoff, iz )
  case( 'u'    ); call iovector( 'w', str, u,  i,    i1, i2, n, nnoff, iz )
  case( 'w'    );
    if ( i < 4 )  call iovector( 'w', str, w1, i,    i1, i2, n, nnoff, iz )
    if ( i > 3 )  call iovector( 'w', str, w2, i-3,  i1, i2, n, nnoff, iz )
  case( 'am'   ); call ioscalar( 'w', str, s1,       i1, i2, n, nnoff, iz )
  case( 'vm'   ); call ioscalar( 'w', str, s2,       i1, i2, n, nnoff, iz )
  case( 'um'   ); call ioscalar( 'w', str, s1,       i1, i2, n, nnoff, iz )
  case( 'wm'   ); call ioscalar( 'w', str, s2,       i1, i2, n, nnoff, iz )
  case( 'sv'   ); call ioscalar( 'w', str, sv,       i1, i2, n, nnoff, iz )
  case( 'sl'   ); call ioscalar( 'w', str, sl,       i1, i2, n, nnoff, iz )
  case( 'trup' ); call ioscalar( 'w', str, trup,     i1, i2, n, nnoff, iz )
  case default; stop 'fieldout'
  end select
end do

end do doiz

if ( pass == 'w' ) return

! Write checkpoint
if ( itcheck /= 0 .and. mod( it, itcheck ) == 0 ) then
  inquire( iolength=reclen ) &
    t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  write( str, '(a,i6.6,i6.6)') 'out/ckp/', ip, it
  open( 9, &
    file=str, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='replace' )
  write( 9, rec=1 ) &
    t, v, u, sl, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
  open( 9, file=str, status='replace' )
  write( 9, * ) it
  close( 9 )
end if

! Metadata
if ( master ) then
  call system_clock( twall(2) )
  dtwall = real( twall(2) - twall(1) ) / real( twall_rate )
  twall(1) = twall(2)
  print '(i6,5es14.6)', it, t, amax, vmax, umax, dtwall
  open(  9, file='out/timestep', status='replace' )
  write( 9, '(i6,5es14.6)' ), it, t, amax, vmax, umax, dtwall
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'out/stats/', it, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) ' t      = ',   t,                '; % time'
  write( 9, * ) ' dt     = ',   dt,               '; % timestep size'
  write( 9, * ) ' dtwall = ',   dtwall,           '; % wall time per step'
  write( 9, * ) ' amax   = ',   amax,             '; % max acceleration'
  write( 9, * ) ' amaxi  = [ ', amaxi - nnoff,  ' ]; % max acceleration loc'
  write( 9, * ) ' vmax   = ',   vmax,             '; % max velocity'
  write( 9, * ) ' vmaxi  = [ ', vmaxi - nnoff,  ' ]; % max velocity loc'
  write( 9, * ) ' umax   = ',   umax,             '; % max displacement'
  write( 9, * ) ' umaxi  = [ ', umaxi - nnoff,  ' ]; % max displacement loc'
  write( 9, * ) ' wmax   = ',   wmax,             '; % max stress Frobenius nrm'
  write( 9, * ) ' wmaxi  = [ ', wmaxi - nnoff,    '; % max stress loc'
  write( 9, * ) ' svmax  = ',   svmax,            '; % max slip velocity'
  write( 9, * ) ' svmaxi = [ ', svmaxi - nnoff, ' ]; % max slip velocity loc'
  write( 9, * ) ' slmax  = ',   slmax,            '; % max slip path length'
  write( 9, * ) ' slmaxi = [ ', slmaxi - nnoff, ' ]; % max slip path length loc'
  close( 9 )
end if

end subroutine
end module

