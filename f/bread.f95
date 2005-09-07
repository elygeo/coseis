!------------------------------------------------------------------------------!
! BREAD

module bread_m
contains
subroutine bread( var, filename, ii1, ii2, ii )
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
open( 9, file=filename, form='unformatted', access='direct', status='replace', &
  recl=reclen )
select case( var )
case( 'x'   ); read( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,ii)
case( 'rho' ); read( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
case( 'vp'  ); read( 9, rec=1 ) lam(j1:j2,k1:k2,l1:l2)
case( 'vs'  ); read( 9, rec=1 ) mu(j1:j2,k1:k2,l1:l2)
case default; stop 'var'
end select
close( 9 )

end subroutine
end module

