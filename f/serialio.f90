! Binary input and output - Serial version
module m_collectiveio
use m_collective
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
integer :: i, j1, k1, l1, j2, k2, l2
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz < 0 ) then
  print *, 'error writing ', trim( filename )
  stop
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=i ) s1(j1:j2,k1:k2,l1:l2)
if ( i == 0 ) then
  print *, 'error writing ', trim( filename ), ', zero size'
  stop
end if
select case( io )
case( 'r' )
  open( 1, &
    file=filename, &
    recl=i, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
case( 'w' )
  open( 1, &
    file=filename, &
    recl=i, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
end select
end subroutine

! Vector field component input/output
subroutine vectorio( io, filename, w1, ic, ir, i1, i2, i1l, i2l, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: ic, ir, i1(3), i2(3), i1l(3), i2l(3), iz
integer :: i, j1, k1, l1, j2, k2, l2
if ( any( i1 /= i1l .or. i2 /= i2l ) .or. iz < 0 ) then
  print *, 'error writing ', trim( filename )
  stop
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=i ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( i == 0 ) then
  print *, 'error writing ', trim( filename ), ', zero size'
  stop
end if
select case( io )
case( 'r' )
  open( 1, &
    file=filename, &
    recl=i, &
    form='unformatted', &
    access='direct', &
    status='old' )
  read( 1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
case( 'w' )
  open( 1, &
    file=filename, &
    recl=i, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
end select
end subroutine

end module

