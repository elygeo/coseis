! Binary input and output - Serial version
module collectiveio_m
use collective_m
implicit none
contains

! Split communicator
subroutine splitio( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: i
i = iz + nout + ditout
end subroutine

! Scalar field input/output
subroutine scalario( io, filename, s1, ir, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: ir, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: j1, k1, l1, j2, k2, l2, reclen
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz <= 0 ) stop 'scalario error'
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
  read( 9, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 9 )
case( 'w' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 9, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 9 )
end select
end subroutine

! Vector field component input/output
subroutine vectorio( io, filename, w1, ic, ir, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: ic, ir, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: j1, k1, l1, j2, k2, l2, reclen
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz <= 0 ) stop 'vectorio error'
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=reclen ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( reclen == 0 ) stop 'zero sized output'
select case( io )
case( 'r' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 9, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 9 )
case( 'w' )
  open( 9, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 9, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 9 )
end select
end subroutine

end module

