!------------------------------------------------------------------------------!
! OUTPUT

subroutine output

use globals
implicit none
integer, intent(in) :: iz
integer :: io, nc, reclen
character(255) :: ofile

do io = 1, nout
if ( mod( it, outint(i) ) == 0 ) then

select case ( outvar(iz) )
case('x'); nc = 3
case('u'); nc = 3
case('v'); nc = 3
case default; stop 'Error: outvar'
end select
call zoneselect( i1, i2, iout(iz,:), npg, hypocenter, nrmdim )
if ( any( i1 < i1node ) .or. any( i2 > i2node ) ) stop 'Output error'
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
  case default; stop 'Error: outvar'
  end select
  close( 9 )
end do
write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
open(  9, file=ofile )
write( 9, * ) nc, i1, i2, outint(iz), it, dt, dx, outvar(iz)
close( 9 )

end if
end do

end subroutine

