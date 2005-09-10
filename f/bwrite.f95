!------------------------------------------------------------------------------!
! BWRITE

module bwrite_m
contains
subroutine bwrite( filename, s1, i1, i2 )

implicit none
character(256), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j1, j2, k1, k2, l1, l2
integer :: reclen

j1 = ii1(1); j2 = ii2(1)
k1 = ii1(2); k2 = ii2(2)
l1 = ii1(3); l2 = ii2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
open( 9, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
close( 9 )

end subroutine
end module

