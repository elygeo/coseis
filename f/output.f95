!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use parallelio_m

implicit none
save
real :: dwt(4), courant, amax, vmax, umax, wmax, svmax, slmax,
integer :: iz, nc, reclen, wt_rate, hh, mm, ss, n(3), err, &
  iamax(3), ivmax(3), iumax(3), iwmax(3), isvmax(3), islmax(3)
character, intent(in) :: pass
character :: onpass, endian
character(160) :: str
logical :: fault, cell, static, init = .true., test

ifinit: if ( init ) then

init = .false.
call system_clock( count_rate=wt_rate )
if ( itcheck < 0 ) itcheck = itcheck + nt + 1

! Look for previus checkpoint files
write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if
call imin( it )

! Read checkpoint file if found, if not, setup output
if ( it /= 0 ) then
  if ( master ) print '(a,i6)', 'Checkpoint found, starting from step ', it
  i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
  write( str, '(a,i6.6,i6.6)' ) 'out/ckp/', i, it
  inquire( iolength=reclen ) v, u, sv, sl, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  open( 9, &
    file=str, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 9, rec=1 ) v, u, sv, sl, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
else
  if ( master ) then
    inquire( file='out/timestep', exist=test )
    if ( err /= 0 ) then
      print '(a)', 'Error: previous output found. use -d flag to overwrite'
      stop
    end if
    print '(a)', 'Initialize output'
    call system( 'mkdir out/ckp' )
    call system( 'mkdir out/stats' )
    do iz = 1, nout
      write( str, '(a,i2.2)' ) 'out/', iz
      call system( 'mkdir ' // str )
    end do
    courant = dt * vp2 * sqrt( 3. ) / abs( dx )
    endian = 'l'
    if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
    write( str, '(a,i2.2,a)' ) 'out/meta.m'
    open(  9, file=str, status='new' )
    write( 9, * ) 'rho1    =   ', rho1      ';% minimum density'
    write( 9, * ) 'vp1     =   ', vp1       ';% minimum Vp'
    write( 9, * ) 'vs1     =   ', vs1       ';% minimum Vp'
    write( 9, * ) 'rho2    =   ', rho2      ';% maximum density'
    write( 9, * ) 'vp2     =   ', vp2       ';% maximum Vp'
    write( 9, * ) 'vs2     =   ', vs2       ';% maximum Vp'
    write( 9, * ) 'rho     =   ', rho       ';% hypocenter density'
    write( 9, * ) 'vp      =   ', vp        ';% hypocenter Vp'
    write( 9, * ) 'vs      =   ', vs        ';% hypocenter Vp'
    write( 9, * ) 'courant =   ', courant,  ';% stability condition'
    write( 9, * ) 'xhypo   = [ ', xhypo, '  ];% hypocenter location'
    write( 9, * ) 'nout    =   ', nout,     ';% number output zones'
    write( 9, * ) 'endian  = ''', endian, ''';% byte ordert'
    close( 9 )
  end if
end if

!Initialize output
if ( nout > nz ) stop 'too many output zones, make nz bigger'

doinit: do iz = 1, nout

nc = 1
fault = .false.
field = fieldout(iz)
select case( field )
case( 'x'    ); nc = 3
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3
case( 'w'    ); nc = 6
case( 'sv'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'trup' ); fault = .true.
end select

if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
call zone( i1out(i,:), i2out(i,:), nn, noff, ihypo, ifn )
if ( field(1:1) = 'w' ) i2out(i,:) = i2out(i,:) - 1
i1 = i1out(iz,:)
i2 = i2out(iz,:)

if ( ipout(iz) == 0 ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/meta.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'field = ''', fieldout(iz), ''';% variable name'
  write( 9, * ) 'nc    =   ', nc,             ';% number of components'
  write( 9, * ) 'i1    = [ ', i1 - noff,    ' ];% start index'
  write( 9, * ) 'i2    = [ ', i2 - noff,    ' ];% end index'
  write( 9, * ) 'dit   =   ', ditout(iz),     ';% interval'
  close( 9 )
end if

if ( any( i2 < i1 ) ) ditout(iz) = 0
call iosplit( iz, ditout(iz) )

end do doinit

if ( master ) then
  print '(a)', 'Time       Amax        Vmax        Umax        Wall Time'
end if

return

end if ifinit

!------------------------------------------------------------------------------!

! Magnitudes
if ( pass == 'w' )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  if ( dostats == 1 ) then
    i1 = maxloc( s1 )
    i1 = maxloc( s2 )
    umax = s1(i1(1),i1(2),i1(3))
    wmax = s2(i1(1),i1(2),i1(3))
    iumax = i1 - noff 
    iwmax = i1 - noff
    call rmax( umax, iumax, imaster )
    call rmax( wmax, iwmax, imaster )
    if ( umax > dx / 10. ) print *, 'Warning: u !<< dx'
  end if
else
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  if ( dostats == 1 ) then
    i1 = maxloc( s1 )
    i1 = maxloc( s2 )
    amax  = s1(i1(1),i1(2),i1(3))
    vmax  = s2(i1(1),i1(2),i1(3))
    iamax  = i1 - noff 
    ivmax  = i1 - noff
    call rmax( amax, iamax, imaster )
    call rmax( vmax, ivmax, imaster )
    if ( ifn /= 0 ) then
      i1 = maxloc( sv )
      i1 = maxloc( sl )
      svmax = sv(i1(1),i1(2),i1(3))
      slmax = sv(i1(1),i1(2),i1(3))
      isvmax = i1 - noff
      islmax = i1 - noff
      isvmax(ifn) = ihypo(ifn)
      islmax(ifn) = ihypo(ifn)
      call rmax( svmax, isvmax, imaster )
      call rmax( slmax, islmax, imaster )
    end if
  end if
end if
end if

! Write output
doiz: do iz = 1, nout

if ( ditout(iz) == 0 .or. mod( it, ditout(iz) ) /= 0 ) cycle doiz

onpass = 'a'

if ( onpass /= pass ) cycle doiz

i1 = i1out(iz,:)
i2 = i2out(iz,:)

! FIXME global size, then bounds on local size

if ( ditout(iz) == 0 ) cycle doiz

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
  case( 'x'    ); call iovector( 'w', str, x,  i,    i1, i2, n, noff, iz )
  case( 'a'    ); call iovector( 'w', str, w1, i,    i1, i2, n, noff, iz )
  case( 'v'    ); call iovector( 'w', str, v,  i,    i1, i2, n, noff, iz )
  case( 'u'    ); call iovector( 'w', str, u,  i,    i1, i2, n, noff, iz )
  case( 'w'    );
    if ( i < 4 )  call iovector( 'w', str, w1, i,    i1, i2, n, noff, iz )
    if ( i > 3 )  call iovector( 'w', str, w2, i-3,  i1, i2, n, noff, iz )
  case( 'am'   ); call ioscalar( 'w', str, s1,       i1, i2, n, noff, iz )
  case( 'vm'   ); call ioscalar( 'w', str, s2,       i1, i2, n, noff, iz )
  case( 'um'   ); call ioscalar( 'w', str, s1,       i1, i2, n, noff, iz )
  case( 'wm'   ); call ioscalar( 'w', str, s2,       i1, i2, n, noff, iz )
  case( 'sv'   ); call ioscalar( 'w', str, sv,       i1, i2, n, noff, iz )
  case( 'sl'   ); call ioscalar( 'w', str, sl,       i1, i2, n, noff, iz )
  case( 'trup' ); call ioscalar( 'w', str, trup,     i1, i2, n, noff, iz )
  case default; stop 'fieldout'
  end select
end do

end do doiz

if ( pass == 'w' ) return

!------------------------------------------------------------------------------!

! Write checkpoint
if ( itcheck /= 0 .and. mod( it, itcheck ) == 0 ) then
  inquire( iolength=reclen ) v, u, sv, sl, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  i = ip3(1) + np(1) * ( ip3(2) + np(2) * ip3(3) )
  write( str, '(a,i6.6,i6.6)') 'out/ckp/', i, it
  open( 9, &
    file=str, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='replace' )
  write( 9, rec=1 ) v, u, sv, sl, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
  open( 9, file=str, status='replace' )
  write( 9, * ) it
  close( 9 )
end if

! Metadata
if ( master ) then
  open(  9, file='out/timestep', status='replace' )
  write( 9, * ) it
  close( 9 )
  call system_clock( wt(2) )
  dwt = real( wt(2) - wt(1) ) / real( wt_rate )
  wt(1) = wt(2)
  write( str, '(a,i6.6,a)' ) 'out/stats/', it, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) t, amax, vmax, umax, wmax, svmax, slmax, dwt
  write( 9, * ) 't      = ', t,      ';% time'
  if ( dostats == 1 ) then
    write( 9, * ) 'amax   = ', amax,   ';% max acceleration'
    write( 9, * ) 'vmax   = ', amax,   ';% max velocity'
    write( 9, * ) 'umax   = ', amax,   ';% max displacement'
    write( 9, * ) 'wmax   = ', amax,   ';% max stress (frobenius norm)'
    write( 9, * ) 'svmax  = ', slmax,  ';% max slip velocity'
    write( 9, * ) 'slmax  = ', slmax,  ';% max slip path length'
    write( 9, * ) 'iamax  = ', iamax,  ';% max acceleration node'
    write( 9, * ) 'ivmax  = ', ivmax,  ';% max velocity node'
    write( 9, * ) 'iumax  = ', ivmax,  ';% max displacement node'
    write( 9, * ) 'iwmax  = ', iamax,  ';% max stress node'
    write( 9, * ) 'isvmax = ', islmax, ';% max slip velocity node'
    write( 9, * ) 'islmax = ', islmax, ';% max slip path length node'
  end if
  close( 9 )
end if

end subroutine
end module

