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
integer :: iz, nc, reclen, wt_rate, hh, mm, ss, n(3), err, it0
real :: dwt(4)
character(160) :: str
logical :: fault, cell, static, init = .true., test

ifinit: if ( init ) then
  init = .false.
  if ( itcheck < 0 ) itcheck = itcheck + nt + 1
  if ( it == 0 ) then
    if ( ip == 0 ) then
      inquire( file='out/timestep', exist=test )
      if ( err /= 0 ) then
        print '(a)', 'Error: previous output found. use -d flag to overwrite'
        stop
      end if
      print '(a)', 'Initialize output'
      open(  9, file='out/xhypo', status='new' )
      write( 9, * ) xhypo
      close( 9 )
      open(  9, file='out/xsource', status='new' )
      write( 9, * ) xsource
      close( 9 )
      call system( 'mkdir out/ckp' )
      call system( 'mkdir out/stats' )
      do iz = 1, nout
        write( str, '(a,i2.2)' ) 'out/', iz
        call system( 'mkdir ' // str )
      end do
    end if
  else
    if ( ip == 0 ) print '(a,i6)', 'Checkpoint found, starting from step ', it
    write( str, '(a,i6.6,i6.6)' ) 'out/ckp/', ip, it
    inquire( iolength=reclen ) u, v, vs, us, trup, &
      p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    open( 9, &
      file=str, &
      recl=reclen, &
      form='unformatted', &
      access='direct', &
      status='old' )
    read( 9, rec=1 ) v, u, vs, us, trup, &
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

if ( itout(iz) < 0 ) itout(iz) = nt + itout(iz) + 1
if ( itout(iz) == 0 .or. mod( it, itout(iz) ) /= 0 ) cycle doiz
nc = 1
onpass = 'v'
cell = .false.
fault = .false.
static = .false.
select case( outvar(iz) )
case( 'x'    ); static = .true.; nc = 3
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); onpass = 'w'; nc = 3
case( 'w'    ); onpass = 'w'; nc = 6; cell = .true.
case( 'am'   )
case( 'vm'   )
case( 'um'   ); onpass = 'w'; 
case( 'wm'   ); onpass = 'w'; cell = .true.
case( 'vs'   ); fault = .true.
case( 'us'   ); fault = .true.
case( 'trup' ); fault = .true.
case default; stop 'var'
end select
if ( fault .and. ifn == 0 ) then
  itout(iz) = 0
  cycle doiz
end if
if ( onpass /= pass ) cycle doiz
if ( static ) itout(iz) = 0
i1 = i1out(iz,:)
i2 = i2out(iz,:)
if ( cell ) i2 = i2 - 1
if ( any( i2 < i1 ) ) stop 'out range'
if ( ip == 0 ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=str, status='replace' )
  write( 9, * ) nc, i1-noff, i2-noff, itout(iz), it, t, dx
  write( 9, * ) outvar(iz)
  close( 9 )
end if
if ( fault ) then
  i1(ifn) = 1
  i2(ifn) = 1
end if
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( outvar(iz) ), i, it
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
  case( 'vs'   ); call bwrite3( str, vs,   i1, i2 )
  case( 'us'   ); call bwrite3( str, us,   i1, i2 )
  case( 'trup' ); call bwrite3( str, trup, i1, i2 )
  case default; stop 'var'
  end select
end do

end do doiz

if ( pass == 'w' ) return

!------------------------------------------------------------------------------!

if ( itcheck /= 0 .and. mod( it, itcheck ) == 0 ) then
  inquire( iolength=reclen ) v, u, vs, us, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  write( str, '(a,i6.6,i6.6)') 'out/ckp/', ip, it
  open( 9, &
    file=str, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='replace' )
  write( 9, rec=1 ) v, u, vs, us, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'out/ckp/', ip, '.hdr'
  open( 9, file=str, status='replace' )
  write( 9, * ) it
  close( 9 )
end if

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

