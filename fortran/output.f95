!------------------------------------------------------------------------------!
! OUTPUT

subroutine output
use globals
use utils

implicit none
save
integer :: iz, nc, reclen, floatsize = 4, outnc(nz) = 1, init = 0
character(255) :: ofile
logical :: doit, fault(nz) = .false., outcell(nz) = .false.

if ( init == 0 ) then
  init = 1
  if ( verb > 0 ) print '(a)', 'Initialize output'
  if ( checkpoint < 0 ) checkpoint = nt + checkpoint + 1
  if ( it == 0 ) then
    call system( 'rm -fr out; mkdir out; mkdir out/ckp; mkdir out/stats' )
  else
    ! FIXME read checkpoint
  end if
  do iz = 1, nout
    if ( outint(iz) < 0 ) outint(iz) = nt + outint(iz) + 1
    select case ( outvar(iz) )
    case('x'); outnc(iz) = 3
    case('u'); outnc(iz) = 3
    case('v'); outnc(iz) = 3
    case('w'); outnc(iz) = 6; outcell(iz) = .true.
    case('|w|'); outcell(iz) = .true.
    case('miu'); outcell(iz) = .true.
    case('lam'); outcell(iz) = .true.
    case('yc');  outcell(iz) = .true.
    case('uslip'); fault(iz) = .true.
    case('vslip'); fault(iz) = .true.
    case('trup');  fault(iz) = .true.
    end select
    if ( it == 0 ) then
      write( ofile, '(a,i2.2)' ) 'mkdir out/', iz
      call system( ofile )
      do i = 1, outnc(iz)
        write( ofile, '(a,i2.2,a,i1)' ) 'mkdir out/', iz, '/', i
        call system( ofile )
      end do
    end if
  end do
end if

do iz = 1, nout
  if ( it == 0 .or. outint(iz) == 0 ) then
    doit = it == outint(iz)
  else
    doit = mod( it, outint(iz) ) == 0
  end if
  if ( doit ) then
    call zoneselect( i1, i2, iout(iz,:), npg, hypocenter, nrmdim )
    if ( any( i1 < i1node .or. i2 > i2node .or. i2 < i1 ) ) stop 'output error'
    if ( outcell(iz) ) i2 = i2 - 1
    if ( fault(iz) ) i1(nrmdim) = 1; i2(nrmdim) = 1
    reclen = floatsize * product( i2 - i1 + 1 )
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    do i = 1, outnc(iz)
      write( ofile, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
      open( 9, file=ofile, form='unformatted', access='direct', status='replace', recl=reclen )
      select case ( outvar(iz) )
      case('x');     write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,i)
      case('u');     write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,i)
      case('v');     write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,i)
      case('w');
        if ( i < 4 ) write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
        if ( i > 3 ) write( 9, rec=1 ) w2(j1:j2,k1:k2,l1:l2,i-3)
      case('|v|');   write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
      case('|w|');   write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
      case('rho');   write( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
      case('lam');   write( 9, rec=1 ) lam(j1:j2,k1:k2,l1:l2)
      case('miu');   write( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
      case('yn');    write( 9, rec=1 ) yn(j1:j2,k1:k2,l1:l2)
      case('yc');    write( 9, rec=1 ) yc(j1:j2,k1:k2,l1:l2)
      case('uslip'); write( 9, rec=1 ) uslip(j1:j2,k1:k2,l1:l2)
      case('vslip'); write( 9, rec=1 ) vslip(j1:j2,k1:k2,l1:l2)
      case('trup');  write( 9, rec=1 ) trup(j1:j2,k1:k2,l1:l2)
      case default; print '(a)', 'outvar ' // outvar(iz); stop
      end select
      close( 9 )
    end do
    write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
    open(  9, file=ofile )
    write( 9, * ) outnc(iz), i1, i2, outint(iz), it, dt, dx, outvar(iz)
    close( 9 )
  end if
end do

if ( mod( it, checkpoint ) == 0 ) then
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

write( ofile, '(a,i5.5)' ) 'out/stats/', it
open(  9, file=ofile )
write( 9, * ) umax, vmax, wmax
close( 9 )

open(  9, file='out/timestep' )
write( 9, * ) it
close( 9 )

end subroutine

