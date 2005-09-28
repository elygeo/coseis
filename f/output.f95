!------------------------------------------------------------------------------!
! Write output

module output_m
use globals_m
use collective_m
use collectiveio_m
contains
subroutine output( pass )
use zone_m

implicit none
save
real :: dtwall, courant, amax, vmax, umax, wmax, svmax, slmax
integer :: i, i1(3), i2(3), iz, nc, n(3), noff(3), reclen, twall(2), &
  twall_rate, amaxi(3), vmaxi(3), umaxi(3), wmaxi(3), svmaxi(3), slmaxi(3)
character, intent(in) :: pass
character :: onpass, endian
logical :: fault, static, init = .true., test

ifinit: if ( init ) then !--------------------------------------!

init = .false.
if ( nout > nz ) stop 'too many output zones, make nz bigger'

ifit0: if ( it == 0 .and. master ) then

  print '(a)', 'Initialize output'

  ! Check for previus run
  inquire( file='out/timestep', exist=test )
  if ( test ) then
    print '(a)', 'Error: previous output found. use -d flag to overwrite'
    stop
  end if
 
  ! Metadata
  endian = 'l'
  if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
  courant = dt * vp2 * sqrt( 3. ) / abs( dx )
  write( str, '(a,i2.2,a)' ) 'out/meta.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) ' rho1    = ',   rho1,     '; % minimum density'
  write( 9, * ) ' rho2    = ',   rho2,     '; % maximum density'
  write( 9, * ) ' rho     = ',   rho,      '; % hypocenter density'
  write( 9, * ) ' vp1     = ',   vp1,      '; % minimum Vp'
  write( 9, * ) ' vp2     = ',   vp2,      '; % maximum Vp'
  write( 9, * ) ' vp      = ',   vp,       '; % hypocenter Vp'
  write( 9, * ) ' vs1     = ',   vs1,      '; % minimum Vs'
  write( 9, * ) ' vs2     = ',   vs2,      '; % maximum Vs'
  write( 9, * ) ' vs      = ',   vs,       '; % hypocenter Vs'
  write( 9, * ) ' courant = ',   courant,  '; % stability condition'
  write( 9, * ) ' xhypo   = [ ', xhypo,  ' ]; % hypocenter location'
  write( 9, * ) ' nout    = ',   nout,     '; % number output zones'
  write( 9, * ) ' endian  = ''', endian, '''; % byte order'
  close( 9 )

end if ifit0

doiz0: do iz = 1, nout

  ! Properties
  nc = 1; fault = .false.
  select case( fieldout(iz) )
  case( 'x'    ); nc = 3
  case( 'a'    ); nc = 3
  case( 'v'    ); nc = 3
  case( 'u'    ); nc = 3
  case( 'w'    ); nc = 6
  case( 'sv'   ); fault = .true.
  case( 'sl'   ); fault = .true.
  case( 'trup' ); fault = .true.
  end select
  
  ! Interval 
  if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1

  ! Zone
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
 
  ! Split collective i/o
  if ( any( i2 < i1 ) ) ditout(iz) = 0
  call iosplit( iz, ditout(iz) )

end do doiz0

! Column names
if ( master ) then
  print '(a)', '  Step  Amax          Vmax          Umax          Wall Time'
  call system_clock( count_rate=twall_rate )
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
    svmaxi(ifn) = ihypo(ifn)
    slmaxi(ifn) = ihypo(ifn)
    call globalmaxloc( svmax, svmaxi, nnoff )
    call globalmaxloc( slmax, slmaxi, nnoff )
  end if
end if

doiz: do iz = 1, nout !--------------------------------------!

if ( ditout(iz) == 0 .or. mod( it, ditout(iz) ) /= 0 ) cycle doiz

! Properties
nc = 1; fault = .false.; onpass = 'a'
select case( fieldout(iz) )
case( 'x'    ); nc = 3
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3; onpass = 'w'
case( 'w'    ); nc = 6; onpass = 'w'
case( 'um'   ); onpass = 'w'
case( 'wm'   ); onpass = 'w'
case( 'sv'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'trup' ); fault = .true.
end select

! Select pass
if ( pass /= onpass ) cycle doiz

! Mesh is static, so only write first time arround
if ( fieldout(iz) == 'x' ) ditout(iz) = 0

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
n = i2 - i1 + 1
if ( fault ) then
  i1(ifn) = 1
  i2(ifn) = 1
end if
i1 = max( i1, i1node )
i2 = min( i2, i2node )

! Binary output
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( fieldout(iz) ), i, it
  select case( fieldout(iz) )
  case( 'x'    ); call iovector( 'w', str, x,  i,   i1, i2, n, nnoff, iz )
  case( 'a'    ); call iovector( 'w', str, w1, i,   i1, i2, n, nnoff, iz )
  case( 'v'    ); call iovector( 'w', str, v,  i,   i1, i2, n, nnoff, iz )
  case( 'u'    ); call iovector( 'w', str, u,  i,   i1, i2, n, nnoff, iz )
  case( 'w'    );
    if ( i < 4 )  call iovector( 'w', str, w1, i,   i1, i2, n, nnoff, iz )
    if ( i > 3 )  call iovector( 'w', str, w2, i-3, i1, i2, n, nnoff, iz )
  case( 'am'   ); call ioscalar( 'w', str, s1,      i1, i2, n, nnoff, iz )
  case( 'vm'   ); call ioscalar( 'w', str, s2,      i1, i2, n, nnoff, iz )
  case( 'um'   ); call ioscalar( 'w', str, s1,      i1, i2, n, nnoff, iz )
  case( 'wm'   ); call ioscalar( 'w', str, s2,      i1, i2, n, nnoff, iz )
  case( 'sv'   ); call ioscalar( 'w', str, sv,      i1, i2, n, nnoff, iz )
  case( 'sl'   ); call ioscalar( 'w', str, sl,      i1, i2, n, nnoff, iz )
  case( 'trup' ); call ioscalar( 'w', str, trup,    i1, i2, n, nnoff, iz )
  case default; stop 'fieldout'
  end select
end do

end do doiz !--------------------------------------!

! Stop if not on acceleration pass
if ( pass == 'w' ) return

! Metadata
if ( master ) then
  call system_clock( twall(2) )
  dtwall = real( twall(2) - twall(1) ) / real( twall_rate )
  twall(1) = twall(2)
  print '(i6,5es14.6)', it, amax, vmax, umax, dtwall
  open(  9, file='out/timestep', status='replace' )
  write( 9, '(i6,5es14.6)' ) it, t, amax, vmax, umax, dtwall
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

