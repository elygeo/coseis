!------------------------------------------------------------------------------!
! OUTPUT

subroutine output
use globals
use utils

implicit none
save
integer :: iz, nc, reclen, floatsize = 4
character(255) :: ofile
logical :: doit

if ( it == 0 ) then
call system( 'rm -r out; mkdir out' )
do iz = 1, nout
  write( ofile, '(a,i2.2)' ) 'mkdir out/', iz
  call system( ofile )
  select case ( outvar(iz) )
  case('x'); nc = 3
  case('u'); nc = 3
  case('v'); nc = 3
  case('uslip'); nc = 1
  case('vslip'); nc = 1
  case default; print '(a)', 'outvar ' // outvar(iz); stop
  end select
  do i = 1, nc
    write( ofile, '(a,i2.2,a,i1)' ) 'mkdir out/', iz, '/', i
    call system( ofile )
  end do
end do
end if

do iz = 1, nout
if ( outint(iz) < 0 ) outint(iz) = nt + outint(iz) + 1
if ( outint(iz) == 0 ) then
  doit = it == 0
else
  doit = mod( it, outint(iz) ) == 0
end if
if ( doit ) then
  call zoneselect( i1, i2, iout(iz,:), npg, hypocenter, nrmdim )
  if ( any( i1 < i1node .or. i2 > i2node .or. i2 < i1 ) ) stop 'output error'
  select case ( outvar(iz) )
  case('x'); nc = 3
  case('u'); nc = 3
  case('v'); nc = 3
  case('uslip'); nc = 1; i1(nrmdim) = 1; i2(nrmdim) = 1
  case('vslip'); nc = 1; i1(nrmdim) = 1; i2(nrmdim) = 1
  case default; print '(a)', 'outvar ' // outvar(iz); stop
  end select
  reclen = floatsize * product( i2 - i1 + 1 )
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  do i = 1, nc
    write( ofile, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
    open( 9, file=ofile, form='unformatted', access='direct', recl=reclen )
    select case ( outvar(iz) )
    case('x'); write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,i)
    case('u'); write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,i)
    case('v'); write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,i)
    case('uslip'); write( 9, rec=1 ) uslip(j1:j2,k1:k2,l1:l2,i)
    case('vslip'); write( 9, rec=1 ) vslip(j1:j2,k1:k2,l1:l2,i)
    case default; print '(a)', 'outvar ' // outvar(iz); stop
    end select
    close( 9 )
  end do
  write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
  open(  9, file=ofile )
  write( 9, * ) nc, i1, i2, outint(iz), it, dt, dx, outvar(iz)
  close( 9 )
end if
end do

if ( mod( it, checkpoint ) == 0 ) then
  write( ofile, '(a,i5.5)') 'out/ckp/', ti
  reclen = floatsize * ( size(v) + size(u) + size(uslip) &
   + size(p1) + size(p2) + size(p3) + size(p4) + size(p5) + size(p6) &
   + size(g1) + size(g2) + size(g3) + size(g4) + size(g5) + size(g6) )
  open ( 9, file=ofile, form='unformatted', access='direct', recl=reclen )
  write( 9, rec=1 ) u, v, uslip, p1, p2, p3, p4, p5, p6, g1, g2, g3, g4, g5, g6
  close( 9 )
  write( outfile, '(a,i5.5,a)' ) 'out/ckp/', mype, '.hdr'
  open( 9, file=outfile )
  write( 9, * ) ti
  close( 9 )
end if

open(  9, file='out/timestep' )
write( 9, * ) it
close( 9 )

end subroutine

