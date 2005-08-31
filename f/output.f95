!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( pass )
use globals_m
use utils_m

implicit none
save
character, intent(in) :: pass
character :: onpass
integer :: iz, nc, reclen, floatsize = 4, wt_rate, hh, mm, ss
real :: dwt(4), wtall = 0.
character(255) :: s
logical :: fault, cell, static, init = .true., outinit(nz) = .true.

if ( init ) then
  init = .false.
  if ( verb > 0 ) print '(a)', 'Initialize output'
  ! FIXME read checkpoint
  call system( 'rm -fr out; mkdir out; mkdir out/ckp; mkdir out/stats' )
  open(  9, file='out/xhypo' )
  write( 9, * ) xhypo
  close( 9 )
  call system_clock( count_rate=wt_rate )
  if ( verb > 0 ) print '(a)', &
  'Step  Amax       Vmax       Umax       Compute    I/O'
end if

outer: do iz = 1, nout
  if ( outit(iz) < 0 ) outit(iz) = nt + outit(iz) + 1
  if ( outit(iz) == 0 .or. mod( it, outit(iz) ) /= 0 ) cycle outer
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
  case( 'miu' ); static = .true.; cell = .true.
  case( 'yc'  ); static = .true.; cell = .true.
  case( 'uslip' ); fault = .true.
  case( 'vslip' ); fault = .true.
  case( 'trup'  ); fault = .true.
  end select
  if ( fault .and. nrmdim == 0 ) then
    outit(iz) = 0
    cycle outer
  end if
  if ( onpass /= pass ) cycle outer
  if ( outinit(iz) ) then
    outinit(iz) = .false.
    write( s, '(a,i2.2)' ) 'mkdir out/', iz
    call system( s )
    do i = 1, nc
      write( s, '(a,i2.2,a,i1)' ) 'mkdir out/', iz, '/', i
      call system( s )
    end do
  end if
  call zoneselect( i1, i2, iout(iz,:), nn, offset, hypocenter, nrmdim )
  if ( any( i1 < i1node .or. i2 > i2node ) ) stop 'out range'
  if ( cell ) i2 = i2 - 1
  if ( any( i2 < i1 ) ) stop 'out range'
  if ( fault ) then
    i1(nrmdim) = 1
    i2(nrmdim) = 1
  end if
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  reclen = floatsize * product( i2 - i1 + 1 )
  inner: do i = 1, nc
    write( s, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
    open( 9, file=s, form='unformatted', access='direct', status='replace', recl=reclen )
    select case( outvar(iz) )
    case( '|a|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
    case( '|v|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
    case( 'a'     ); write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
    case( 'v'     ); write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,i)
    case( '|u|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
    case( '|w|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
    case( 'u'     ); write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,i)
    case( 'w'     );
      if ( i < 4 )   write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
      if ( i > 3 )   write( 9, rec=1 ) w2(j1:j2,k1:k2,l1:l2,i-3)
    case( 'x'     ); write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,i)
    case( 'rho'   ); write( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
    case( 'lam'   ); write( 9, rec=1 ) lam(j1:j2,k1:k2,l1:l2)
    case( 'miu'   ); write( 9, rec=1 ) miu(j1:j2,k1:k2,l1:l2)
    case( 'yn'    ); write( 9, rec=1 ) yn(j1:j2,k1:k2,l1:l2)
    case( 'yc'    ); write( 9, rec=1 ) yc(j1:j2,k1:k2,l1:l2)
    case( 'uslip' ); write( 9, rec=1 ) uslip(j1:j2,k1:k2,l1:l2)
    case( 'vslip' ); write( 9, rec=1 ) vslip(j1:j2,k1:k2,l1:l2)
    case( 'trup'  ); write( 9, rec=1 ) trup(j1:j2,k1:k2,l1:l2)
    case default; stop 'outvar'
    end select
    close( 9 )
    if ( static ) outit(iz) = 0
  end do inner
  write( s, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=s )
  write( 9, * ) nc, i1-offset, i2-offset, outit(iz), it, dt, dx
  write( 9, * ) outvar(iz)
  close( 9 )
end do outer

if ( pass == 'w' ) return

if ( checkpoint < 0 ) checkpoint = nt + checkpoint + 1
if ( checkpoint /= 0 .and. mod( it, checkpoint ) == 0 ) then
  if ( verb > 1 ) print '(a)', 'Writing checkpoint file'
  reclen = floatsize * ( 2 * size(u) + 3 * size(uslip) &
   + size(p1) + size(p2) + size(p3) + size(p4) + size(p5) + size(p6) &
   + size(g1) + size(g2) + size(g3) + size(g4) + size(g5) + size(g6) )
  write( s, '(a,i5.5)') 'out/ckp/', it
  open( 9, file=s, form='unformatted', access='direct', status='replace', recl=reclen )
  write( 9, rec=1 ) u, v, vslip, uslip, trup, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  open( 9, file='out/ckp/hdr' )
  write( 9, * ) it
  close( 9 )
end if

open(  9, file='out/timestep' )
write( 9, * ) it
close( 9 )

call system_clock( wt(5) )
dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )

write( s, '(a,i5.5)' ) 'out/stats/', it
open(  9, file=s )
write( 9, '(8es14.6)' ) amax, vmax, umax, wmax, dwt
close( 9 )

if ( verb > 0 ) print '(i4,5es10.2)', it, amax, vmax, umax, dwt(1:2) + dwt(3:4)

end subroutine
end module

