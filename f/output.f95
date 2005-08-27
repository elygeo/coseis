!------------------------------------------------------------------------------!
! OUTPUT

module output_m
contains
subroutine output( thispass )
use globals_m
use utils_m

implicit none
save
integer, intent(in) :: thispass
integer :: iz, nc, reclen, floatsize = 4, pass
character(255) :: ofile
logical :: fault, cell, static, init = .true., outinit(nz) = .true.

if ( init ) then
  init = .false.
  if ( verb > 0 ) print '(a)', 'Initialize output'
  ! FIXME read checkpoint
  call system( 'rm -fr out; mkdir out; mkdir out/ckp; mkdir out/stats' )
  if ( verb > 0 ) print '(a)', &
  'Step  Amax          Vmax          Umax          Wmax          WallTime'
end if

outer: do iz = 1, nout
  if ( outit(iz) < 0 ) outit(iz) = nt + outit(iz) + 1
  if ( outit(iz) == 0 .or. mod( it, outit(iz) ) /= 0 ) cycle outer
  nc = 1
  pass = 2
  cell = .false.
  fault = .false.
  static = .false.
  select case( outvar(iz) )
  case( 'a'   ); nc = 3; pass = 1
  case( 'v'   ); nc = 3; pass = 1
  case( 'u'   ); nc = 3
  case( 'w'   ); nc = 6; cell = .true.
  case( '|a|' ); pass = 1
  case( '|v|' ); pass = 1
  case( '|u|' ) 
  case( '|w|' ); cell = .true.
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
  if ( pass /= thispass ) cycle outer
  if ( outinit(iz) ) then
    outinit(iz) = .false.
    write( ofile, '(a,i2.2)' ) 'mkdir out/', iz
    call system( ofile )
    do i = 1, nc
      write( ofile, '(a,i2.2,a,i1)' ) 'mkdir out/', iz, '/', i
      call system( ofile )
    end do
  end if
  call zoneselect( i1, i2, iout(iz,:), nn, offset, hypocenter, nrmdim )
  if ( any( i1 < i1node .or. i2 > i2node .or. i2 < i1 ) ) stop 'outrange'
  if ( cell ) i2 = i2 - 1
  if ( fault ) then
    i1(nrmdim) = 1
    i2(nrmdim) = 1
  end if
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  reclen = floatsize * product( i2 - i1 + 1 )
  inner: do i = 1, nc
    write( ofile, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
    open( 9, file=ofile, form='unformatted', access='direct', status='replace', recl=reclen )
    select case( outvar(iz) )
    case( 'a'     ); write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
    case( 'v'     ); write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,i)
    case( 'u'     ); write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,i)
    case( 'w'     );
      if ( i < 4 )   write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
      if ( i > 3 )   write( 9, rec=1 ) w2(j1:j2,k1:k2,l1:l2,i-3)
    case( '|a|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
    case( '|v|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
    case( '|u|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
    case( '|w|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
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
  write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=ofile )
  write( 9, * ) nc, i1-offset, i2-offset, outit(iz), it, dt, dx
  write( 9, * ) outvar(iz)
  close( 9 )
end do outer

if ( thispass == 1 ) return

if ( checkpoint < 0 ) checkpoint = nt + checkpoint + 1
if ( checkpoint /= 0 .and. mod( it, checkpoint ) == 0 ) then
  if ( verb > 1 ) print '(a)', 'Writing checkpoint file'
  reclen = floatsize * ( size(v) + size(u) + size(uslip) &
   + size(p1) + size(p2) + size(p3) + size(p4) + size(p5) + size(p6) &
   + size(g1) + size(g2) + size(g3) + size(g4) + size(g5) + size(g6) )
  write( ofile, '(a,i5.5)') 'out/ckp/', it
  open( 9, file=ofile, form='unformatted', access='direct', status='replace', recl=reclen )
  write( 9, rec=1 ) u, v, uslip, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  open( 9, file='out/ckp/hdr' )
  write( 9, * ) it
  close( 9 )
end if

call system_clock( wt(6) )
dwt(1:5) = real( wt(2:6) - wt(1:5) ) / real( wt_rate )
dwt(6)   = real( wt(6)   - wt(1) )   / real( wt_rate )

if ( verb > 0 ) print '(i4,4e14.6,e10.2)', it, amax, vmax, umax, wmax, dwt(6)

write( ofile, '(a,i5.5)' ) 'out/stats/', it
open(  9, file=ofile )
write( 9, '(4e14.6,6e10.2)' ) amax, vmax, umax, wmax, dwt
close( 9 )

open(  9, file='out/timestep' )
write( 9, * ) it
close( 9 )

end subroutine
end module

