!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use parallel_m

implicit none
save
character, intent(in) :: pass
character :: onpass
integer :: iz, nc, reclen, wt_rate, hh, mm, ss, n(3), err
real :: dwt(4), courant
character :: endian
character(160) :: str
logical :: fault, cell, static, init = .true., test

ifinit: if ( init ) then

init = .false.
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
if ( itcheck < 0 ) itcheck = itcheck + nt + 1
call system_clock( count_rate=wt_rate )

! Look for previus checkpoint files
write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
open( 9, file=str, status='old', iostat=err )
if ( err == 0 ) then
  read( 9, * ) it
  close( 9 )
else
  it = 0
end if
pimin( it )

! Read checkpoint file if found, if not, setup output
if ( it /= 0 ) then
  if ( ip == 0 ) print '(a,i6)', 'Checkpoint found, starting from step ', it
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
  if ( ip == 0 ) then
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
  end if
  if ( all( ihypo >= i1node .and. ihypo <= i2node ) ) then
    courant = dt * vp2 * sqrt( 3. ) / abs( dx )
    write( str, '(a,i2.2,a)' ) 'out/meta.m'
    open(  9, file=str, status='new' )
    write( 9, * ) 'rho1    =   ', rho1     ';% minimum density'
    write( 9, * ) 'vp1     =   ', vp1      ';% minimum Vp'
    write( 9, * ) 'vs1     =   ', vs1      ';% minimum Vp'
    write( 9, * ) 'rho2    =   ', rho2     ';% maximum density'
    write( 9, * ) 'vp2     =   ', vp2      ';% maximum Vp'
    write( 9, * ) 'vs2     =   ', vs2      ';% maximum Vp'
    write( 9, * ) 'rho     =   ', rho      ';% hypocenter density'
    write( 9, * ) 'vp      =   ', vp       ';% hypocenter Vp'
    write( 9, * ) 'vs      =   ', vs       ';% hypocenter Vp'
    write( 9, * ) 'courant =   ', courant, ';% stability condition'
    write( 9, * ) 'xhypo   = [ ', xhypo, ' ];% hypocenter location'
    write( 9, * ) 'nout    =   ', nout,    ';% number output zones'
    close( 9 )
  end if
end if

if ( ip == 0 ) then
  print '(a)', 'Time       Amax        Vmax        Umax        Compute     I/O'
end if

return

end if ifinit

!------------------------------------------------------------------------------!

! Write output
doiz: do iz = 1, nout

if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
if ( ditout(iz) == 0 .or. mod( it, ditout(iz) ) /= 0 ) cycle doiz

nc = 1
onpass = 'v'
cell = .false.
fault = .false.
static = .false.
select case( fieldout(iz) )
case( 'x'    ); static = .true.; nc = 3
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); onpass = 'w'; nc = 3
case( 'w'    ); onpass = 'w'; nc = 6; cell = .true.
case( 'am'   )
case( 'vm'   )
case( 'um'   ); onpass = 'w'; 
case( 'wm'   ); onpass = 'w'; cell = .true.
case( 'sv'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'trup' ); fault = .true.
case default; stop 'var'
end select
if ( fault .and. ifn == 0 ) then
  out_dit(iz) = 0
  cycle doiz
end if
if ( onpass /= pass ) cycle doiz
i1 = i1out(iz,:)
i2 = i2out(iz,:)
if ( cell ) i2 = i2 - 1

! Metadata
if ( ip == 0 ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/meta.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'field = ''', fieldout(iz), ''';% variable name'
  write( 9, * ) 'nc    =   ', nc,             ';% number of components'
  write( 9, * ) 'i1    = [ ', i1 - noff,    ' ];% start index'
  write( 9, * ) 'i2    = [ ', i2 - noff,    ' ];% end index'
  write( 9, * ) 'dit   =   ', ditout(iz),     ';% interval'
  write( 9, * ) 'itout =   ', it,             ';% time step'
  write( 9, * ) 'tout  =   ', t,              ';% time'
  close( 9 )
end if

! FIXME
if ( any( i2 < i1 ) ) stop 'out range'
if ( static ) ditout(iz) = 0
if ( fault ) then
  i1(ifn) = 1
  i2(ifn) = 1
end if

! Binary output
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( out_field(iz) ), i, it
  select case( outvar(iz) )
  case( 'x'    ); call pwrite4( str, x,    i1, i2, i )
  case( 'a'    ); call pwrite4( str, w1,   i1, i2, i )
  case( 'v'    ); call pwrite4( str, v,    i1, i2, i )
  case( 'u'    ); call pwrite4( str, u,    i1, i2, i )
  case( 'w'    );
    if ( i < 4 )  call pwrite4( str, w1,   i1, i2, i )
    if ( i > 3 )  call pwrite4( str, w2,   i1, i2, i-3 )
  case( 'am'   ); call pwrite3( str, s1,   i1, i2 )
  case( 'vm'   ); call pwrite3( str, s2,   i1, i2 )
  case( 'um'   ); call pwrite3( str, s1,   i1, i2 )
  case( 'wm'   ); call pwrite3( str, s2,   i1, i2 )
  case( 'sv'   ); call pwrite3( str, sv,   i1, i2 )
  case( 'sl'   ); call pwrite3( str, sl,    i1, i2 )
  case( 'trup' ); call pwrite3( str, trup, i1, i2 )
  case default; stop 'var'
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
if ( ip == 0 ) then
  open(  9, file='out/timestep', status='replace' )
  write( 9, * ) it
  close( 9 )
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  write( str, '(a,i6.6)' ) 'out/stats/', it
  open(  9, file=str, status='replace' )
  write( 9, '(8es15.7)' ) t, amax, vmax, umax, wmax, dwt
  close( 9 )
  print '(6es12.4)', t, amax, vmax, umax, dwt(1:2) + dwt(3:4)
end if

end subroutine
end module

