!------------------------------------------------------------------------------!
! BWRITE

module bwrite_m
contains
subroutine bwrite( var, filename, ii1, ii2, ii )
use globals_m

implicit none
character(8), intent(in) :: var
character(256), intent(in) :: filename
integer, intent(in) :: ii1(3), ii2(3), ii
integer :: reclen

j1 = ii1(1); j2 = ii2(1)
k1 = ii1(2); k2 = ii2(2)
l1 = ii1(3); l2 = ii2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
open( 9, file=filename, form='unformatted', access='direct', status='replace',    recl=reclen )
select case( var )
case( '|a|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
case( '|v|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
case( 'a'     ); write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,ii)
case( 'v'     ); write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,ii)
case( '|u|'   ); write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
case( '|w|'   ); write( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
case( 'u'     ); write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,ii)
case( 'w'     );
  if ( i < 4 )   write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,ii)
  if ( i > 3 )   write( 9, rec=1 ) w2(j1:j2,k1:k2,l1:l2,ii-3)
case( 'x'     ); write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,ii)
case( 'rho'   ); write( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
case( 'lam'   ); write( 9, rec=1 ) lam(j1:j2,k1:k2,l1:l2)
case( 'mu'    ); write( 9, rec=1 ) mu(j1:j2,k1:k2,l1:l2)
case( 'y'     ); write( 9, rec=1 ) y(j1:j2,k1:k2,l1:l2)
case( 'uslip' ); write( 9, rec=1 ) uslip(j1:j2,k1:k2,l1:l2)
case( 'vslip' ); write( 9, rec=1 ) vslip(j1:j2,k1:k2,l1:l2)
case( 'trup'  ); write( 9, rec=1 ) trup(j1:j2,k1:k2,l1:l2)
case default; stop 'var'
end select
close( 9 )

end subroutine
end module

