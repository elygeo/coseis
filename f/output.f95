!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use binaryio_m
use zone_m

implicit none
save
character, intent(in) :: pass
character :: onpass
integer :: iz, nc, reclen, wt_rate, hh, mm, ss, n(3)
real :: dwt(4)
character(255) :: str
logical :: fault, cell, static, init = .true., outinit(nz) = .true.

if ( init ) then
  init = .false.
  if ( ip == 0 ) then
    print '(a)', 'Initialize output'
    print '(a)', 'Step  Amax       Vmax       Umax       Compute    I/O'
  end if
  if ( it == 0 ) then
    if ( ip == 0 ) then
      call system( 'rm -fr out; mkdir out; mkdir out/ckp; mkdir out/stats' )
      open(  9, file='out/xhypo' )
      write( 9, * ) xhypo
      close( 9 )
    end if
  else
    if ( ip == 0 ) print '(a,i5)', 'Checkpoint found, starting from step ', it
    write( str, '(a,i5.5,i5.5)') 'out/ckp/', it, ip
    inquire( iolength=reclen ) u, v, vslip, uslip, trup, &
      p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    open( 9, file=str, form='unformatted', access='direct', recl=reclen, &
      status='old' )
    read( 9, rec=1 ) u, v, vslip, uslip, trup, &
      p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
    close( 9 )
  end if
  call system_clock( count_rate=wt_rate )
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
case( '|a|' )
case( '|v|' )
case( 'a'   ); nc = 3
case( 'v'   ); nc = 3
case( '|u|' ); onpass = 'w'; 
case( '|w|' ); onpass = 'w'; cell = .true.
case( 'u'   ); onpass = 'w'; nc = 3
case( 'w'   ); onpass = 'w'; nc = 6; cell = .true.
case( 'x'   ); static = .true.; nc = 3
case( 'rho' ); static = .true.
case( 'yn'  ); static = .true.
case( 'lam' ); static = .true.; cell = .true.
case( 'mu' );  static = .true.; cell = .true.
case( 'yc'  ); static = .true.; cell = .true.
case( 'uslip' ); fault = .true.
case( 'vslip' ); fault = .true.
case( 'trup'  ); fault = .true.
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
if ( ip == 0 .and. outinit(iz) ) then
  outinit(iz) = .false.
  write( str, '(a,i2.2)' ) 'mkdir out/', iz
  call system( str )
  do i = 1, nc
    write( str, '(a,i2.2,a,i1)' ) 'mkdir out/', iz, '/', i
    call system( str )
  end do
end if
do i = 1, nc
  write( str, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
  call bwrite( outvar(iz), str, i1, i2, i )
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
  write( str, '(a,i5.5,i5.5)') 'out/ckp/', it, ip
  inquire( iolength=reclen ) u, v, vslip, uslip, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  open( 9, file=str, form='unformatted', access='direct', status='replace', &
    recl=reclen )
  write( 9, rec=1 ) u, v, vslip, uslip, trup, &
    p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  open( 9, file='out/ckp/hdr', status='replace' )
  write( 9, * ) it
  close( 9 )
end if

if ( ip == 0 ) then
  open(  9, file='out/timestep', status='replace' )
  write( 9, * ) it
  close( 9 )
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  write( str, '(a,i5.5)' ) 'out/stats/', it
  open(  9, file=str, status='replace' )
  write( 9, '(8es14.6)' ) amax, vmax, umax, wmax, dwt
  close( 9 )
  print '(i4,5es10.2)', it, amax, vmax, umax, dwt(1:2) + dwt(3:4)
end if

end subroutine
end module

