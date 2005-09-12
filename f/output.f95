!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use zone_m
use binio_m

implicit none
save
character, intent(in) :: pass
character :: onpass
integer :: iz, nc, reclen, wt_rate, hh, mm, ss, n(3), err, it0
real :: dwt(4)
character(160) :: str
logical :: fault, cell, static, init = .true.

if ( init ) then
  init = .false.
  if ( it == 0 ) then
    if ( ip == 0 ) then
      print '(a)', 'Initialize output'
      open(  9, file='out/x0', status='new', iostat=err )
      if ( err / 0 ) then
        print '(a)', 'error: previous output found. use -d flag to overwrite'
        stop
      else
      write( 9, * ) x0
      close( 9 )
      call system( 'mkdir out/ckp' )
      call system( 'mkdir out/stats' )
      do iz = 1, nout
        write( str, '(a,i2.2)' ) 'out/', iz
        call system( 'mkdir ' // str )
      end do
    end if
    if ( checkpoint < 0 ) checkpoint = checkpoint + nt + 1
  else
    if ( ip == 0 ) print '(a,i6)', 'Checkpoint found, starting from step ', it
    outinit = .false.
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
    print '(a)', '  Step  Amax        Vmax        Umax        Compute     I/O'
  end if
  return
end if

!------------------------------------------------------------------------------!

izloop: do iz = 1, nout

if ( outit(iz) < 0 ) outit(iz) = nt + outit(iz) + 1
if ( outit(iz) == 0 .or. mod( it, outit(iz) ) /= 0 ) cycle izloop
nc = 1
onpass = 'v'
cell = .false.
fault = .false.
static = .false.
select case( outvar(iz) )
case( 'rho'  ); static = .true.
case( 'lam'  ); static = .true.; cell = .true.
case( 'mu'   ); static = .true.; cell = .true.
case( 'y'    ); static = .true.; cell = .true.
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
if ( fault .and. nrmdim == 0 ) then
  outit(iz) = 0
  cycle izloop
end if
if ( onpass /= pass ) cycle izloop
if ( static ) outit(iz) = 0
call zone( i1, i2, iout(iz,:), nn, offset, hypocenter, nrmdim )
if ( any( i1 < i1node .or. i2 > i2node ) ) stop 'out range'
if ( cell ) i2 = i2 - 1
if ( any( i2 < i1 ) ) stop 'out range'
if ( fault ) then
  i1(nrmdim) = 1
  i2(nrmdim) = 1
end if
do i = 1, nc
  write( str, '(a,i2.2,a,a,i1,i6.6)' ) &
    'out/', iz, '/', trim( outvar(iz) ), i, it
  select case( outvar(iz) )
  case( 'rho'  ); call bwrite3( str, rho,  i1, i2 )
  case( 'lam'  ); call bwrite3( str, lam,  i1, i2 )
  case( 'mu'   ); call bwrite3( str, mu,   i1, i2 )
  case( 'y'    ); call bwrite3( str, y,    i1, i2 )
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
  end select
end do
if ( ip == 0 ) then
  write( str, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=str, status='replace' )
  write( 9, * ) nc, i1-offset, i2-offset, outit(iz), it, dt, dx
  write( 9, * ) outvar(iz)
  close( 9 )
end if

end do izloop

if ( pass == 'w' ) return

!------------------------------------------------------------------------------!

if ( checkpoint /= 0 .and. mod( it, checkpoint ) == 0 ) then
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
  write( 9, '(8es15.7)' ) amax, vmax, umax, wmax, dwt
  close( 9 )
  print '(i6,5es12.4)', it, amax, vmax, umax, dwt(1:2) + dwt(3:4)
end if

end subroutine
end module

