!------------------------------------------------------------------------------!
! BINIO

module binio_m
contains

subroutine bwrite3( filename, s1, i1, i2 )
implicit none
character*(*), intent(in) :: filename
real, intent(in) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j1, j2, k1, k2, l1, l2
integer :: reclen
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
if ( reclen == 0 ) return
open( 9, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
close( 9 )
end subroutine

subroutine bwrite4( filename, w1, i1, i2, i )
implicit none
character*(*), intent(in) :: filename
real, intent(in) :: w1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: j1, j2, k1, k2, l1, l2
integer :: reclen
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) w1(j1:j2,k1:k2,l1:l2,i)
if ( reclen == 0 ) return
open( 9, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='replace' )
write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
close( 9 )
end subroutine

subroutine bread3( dir, var, s1, i1, i2 )
implicit none
character*(*), intent(in) :: dir, var
character(160) :: filename
real, intent(out) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3)
integer :: j1, j2, k1, k2, l1, l2
integer :: reclen
filename = trim( dir ) // '/' // var
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
if ( reclen == 0 ) return
open( 9, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
close( 9 )
end subroutine

subroutine bread4( dir, var, w1, i1, i2, i )
implicit none
character*(*), intent(in) :: dir, var
character(160) :: filename
real, intent(out) :: w1(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
integer :: j1, j2, k1, k2, l1, l2
integer :: reclen
filename = trim( dir ) // '/' // var
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) w1(j1:j2,k1:k2,l1:l2,i)
if ( reclen == 0 ) return
open( 9, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct', &
  status='old' )
read( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
close( 9 )
end subroutine

end module

