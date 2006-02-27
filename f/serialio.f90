! Binary input and output
module collectiveio_m
use collective_m
implicit none
contains

! Placeholder for split collective parallel output
subroutine iosplit( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: i
i = iz + nout + ditout ! silence compiler warnings
end subroutine

! Scalar field input/output
subroutine scalario( io, filename, s1, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), i1l(3), i2l(3), iz
integer :: j1, k1, l1, j2, k2, l2, reclen
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz <= 0 ) stop 'output error'
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) s1(j1:j2,k1:k2,l1:l2)
if ( reclen == 0 ) stop 'zero sized output'
select case( io )
case( 'r' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
  close( 9 )
case( 'w' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='replace' )
  write( 9, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
  close( 9 )
end select
end subroutine

! Vector component input/output
subroutine vectorio( io, filename, w1, i, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: i, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: j1, k1, l1, j2, k2, l2, reclen
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz <= 0 ) stop 'output error'
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) w1(j1:j2,k1:k2,l1:l2,i)
if ( reclen == 0 ) stop 'zero sized output'
select case( io )
case( 'r' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
  close( 9 )
case( 'w' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='replace' )
  write( 9, rec=1 ) w1(j1:j2,k1:k2,l1:l2,i)
  close( 9 )
end select
end subroutine

end module

