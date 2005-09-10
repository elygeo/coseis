!------------------------------------------------------------------------------!
! BREAD

module bread_m
contains
subroutine bread( s1, dir, var, i1, i2 )

implicit none
real, intent(out) :: s1(:,:,:)
character(256), intent(inout) :: dir
character(8), intent(in) :: var
integer, intent(in) :: i1(3), i2(3)
integer :: reclen

dir = trim( dir ) // '/' // var
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
open( 9, file=dir, form='unformatted', access='direct', status='replace', &
  recl=reclen )
read( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
close( 9 )

end subroutine
end module

