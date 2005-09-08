!------------------------------------------------------------------------------!
! BREAD

module bread_m
contains
subroutine bread( var, dir, ii1, ii2 )
use globals_m

implicit none
character(8), intent(in) :: var
character(256) :: dir
integer, intent(in) :: ii1(3), ii2(3)
integer :: reclen

dir = trim( dir ) // '/' // var
j1 = ii1(1); j2 = ii2(1)
k1 = ii1(2); k2 = ii2(2)
l1 = ii1(3); l2 = ii2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
open( 9, file=dir, form='unformatted', access='direct', status='replace', &
  recl=reclen )
select case( var )
case( 'x1'  ); read( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,1)
case( 'x2'  ); read( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,2)
case( 'x3'  ); read( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,3)
case( 'rho' ); read( 9, rec=1 ) rho(j1:j2,k1:k2,l1:l2)
case( 'vp'  ); read( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
case( 'vs'  ); read( 9, rec=1 ) s2(j1:j2,k1:k2,l1:l2)
case( 'xx'  ); read( 9, rec=1 ) t1(j1:j2,k1:k2,l1:l2,1)
case( 'yy'  ); read( 9, rec=1 ) t1(j1:j2,k1:k2,l1:l2,2)
case( 'zz'  ); read( 9, rec=1 ) t1(j1:j2,k1:k2,l1:l2,3)
case( 'yz'  ); read( 9, rec=1 ) t2(j1:j2,k1:k2,l1:l2,1)
case( 'zx'  ); read( 9, rec=1 ) t2(j1:j2,k1:k2,l1:l2,2)
case( 'xy'  ); read( 9, rec=1 ) t2(j1:j2,k1:k2,l1:l2,3)
case( 'tn'  ); read( 9, rec=1 ) t3(j1:j2,k1:k2,l1:l2,1)
case( 'ts'  ); read( 9, rec=1 ) t3(j1:j2,k1:k2,l1:l2,2)
case( 'td'  ); read( 9, rec=1 ) t3(j1:j2,k1:k2,l1:l2,3)
case default; stop 'var'
end select
close( 9 )

end subroutine
end module

