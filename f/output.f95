!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use binio_m

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
  if ( it == 0 ) then
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
    courant = dt * vp2 * sqrt( 3. ) / abs( dx )
    if ( all( ihypo >= i1node .and. ihypo <= i2node ) ) then
      write( str, '(a,i2.2,a)' ) 'out/meta.m'
      open(  9, file=str, status='new' )
      write( 9, * ) 'n       = [ ', nn, nt           ' ];'
      write( 9, * ) 'dx      =   ', dx                 ';'
      write( 9, * ) 'dt      =   ', dt                 ';'
      write( 9, * ) 'rho     =   ', rho                ';'
      write( 9, * ) 'vp      =   ', vp                 ';'
      write( 9, * ) 'vs      =   ', vs                 ';'
      write( 9, * ) 'courant =   ', courant,           ';'
      write( 9, * ) 'grid    =   ', grid,              ';'
      write( 9, * ) 'upward  =   ', upward,            ';'
      write( 9, * ) 'xsource = [ ', xsource,         ' ];'
      write( 9, * ) 'rfunc   = ''', trim( rfunc ),   ''';'
      write( 9, * ) 'rsource =   ', rsource,           ';'
      write( 9, * ) 'tfunc   = ''', trim( tfunc ),   ''';'
      write( 9, * ) 'tsource =   ', tsource,           ';'
      write( 9, * ) 'moment1 = [ ', moment1,         ' ];'
      write( 9, * ) 'moment2 = [ ', moment2,         ' ];'
      write( 9, * ) 'ihypo   = [ ', ihypo - noff,    ' ];'
      write( 9, * ) 'xhypo   = [ ', xhypo,           ' ];'
      write( 9, * ) 'vrup    =   ', vrup,              ';'
      write( 9, * ) 'rcrit   =   ', rcrit,             ';'
      write( 9, * ) 'trelax  =   ', trelax,            ';'
      write( 9, * ) 'nout    =   ', nout,              ';'
      close( 9 )
    end if
  else
    if ( ip == 0 ) print '(a,i6)', 'Checkpoint found, starting from step ', it
    write( str, '(a,i6.6,i6.6)' ) 'out/ckp/', ip, it
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
  end if
  call system_clock( count_rate=wt_rate )
  if ( ip == 0 ) then
    print '(a)', 'Time       Amax        Vmax        Umax        Compute     I/O'
  end if
  return
end if ifinit

!------------------------------------------------------------------------------!

doiz: do iz = 1, nout

if ( out_dit(iz) < 0 ) out_dit(iz) = nt + out_dit(iz) + 1
if ( out_dit(iz) == 0 .or. mod( it, out_dit(iz) ) /= 0 ) cycle doiz
nc = 1
onpass = 'v'
cell = .false.
fault = .false.
static = .false.
select case( out_field(iz) )
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
if ( static ) out_dit(iz) = 0
i1 = out_i1(iz,:)
i2 = out_i2(iz,:)
if ( cell ) i2 = i2 - 1
if ( any( i2 < i1 ) ) stop 'out range'

! Metadata
if ( ip == 0 ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/meta.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'field = ''', fieldout(iz), ''';'
  write( 9, * ) 'nc    =   ', nc,             ';'
  write( 9, * ) 'i1    = [ ', i1 - noff,    ' ];'
  write( 9, * ) 'i2    = [ ', i2 - noff,    ' ];'
  write( 9, * ) 'dit   =   ', ditout(iz),     ';'
  write( 9, * ) 'itout =   ', it,             ';'
  write( 9, * ) 'tout  =   ', t,              ';'
  close( 9 )
end if

if ( fault ) then
  i1(ifn) = 1
  i2(ifn) = 1
end if

! Binary output
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( out_field(iz) ), i, it
  select case( outvar(iz) )
  case( 'x'    ); call bwrite4( str, x,    i1, i2, i )
  case( 'a'    ); call bwrite4( str, w1,   i1, i2, i )
  case( 'v'    ); call bwrite4( str, v,    i1, i2, i )
  case( 'u'    ); call bwrite4( str, u,    i1, i2, i )
  case( 'w'    );
    if ( i < 4 )  call bwrite4( str, w1,   i1, i2, i )
    if ( i > 3 )  call bwrite4( str, w2,   i1, i2, i-3 )
  case( 'am'   ); call bwrite3( str, s1,   i1, i2 )
  case( 'vm'   ); call bwrite3( str, s2,   i1, i2 )
  case( 'um'   ); call bwrite3( str, s1,   i1, i2 )
  case( 'wm'   ); call bwrite3( str, s2,   i1, i2 )
  case( 'sv'   ); call bwrite3( str, sv,   i1, i2 )
  case( 'sl'   ); call bwrite3( str, sl,    i1, i2 )
  case( 'trup' ); call bwrite3( str, trup, i1, i2 )
  case default; stop 'var'
  end select
end do

end do doiz

if ( pass == 'w' ) return

!------------------------------------------------------------------------------!

! Checkpoint
if ( itcheck /= 0 .and. mod( it, itcheck ) == 0 ) then
  inquire( iolength=reclen ) v, u, sv, sl, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  write( str, '(a,i6.6,i6.6)') 'out/ckp/', ip, it
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

