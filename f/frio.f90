! Fortran Real Binary I/O
module m_frio
use m_globals, only: nz
implicit none
integer, private :: filehandles(64+6*nz) = 0
contains

! Timeseries I/O
subroutine frio1( id, str, ft, ir, nr )
real, intent(inout) :: ft(:)
integer, intent(in) :: id, ir, nr
character(*), intent(in) :: str
integer :: fh, n, i0, nb, i
n = size( ft )
if ( n == 0 ) return
i0 = ir - n
if ( i0 < 0 ) then
  write ( 0, * )  'Error in rio1 ', trim( str ), ir, n
  stop
end if
i = abs( id )
fh = filehandles(i)
if ( fh == 0 ) then
  fh = id + 65536
  filehandles(i) = fh
  write( 0, * ) 'Opening file: ', trim( str )
  inquire( iolength=nb ) ft(1)
  if ( id < 0 .or. i0 > 0 ) then
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='old' )
  else
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='new' )
  end if
end if
if ( id < 0 ) then
  do i = 1, n; read( fh, rec=i0+i ) ft(i); end do
else
  do i = 1, n; write( fh, rec=i0+i ) ft(i); end do
end if
if ( ir == nr ) then
  close( fh )
  i = abs( id )
  filehandles(i) = 0
end if
end subroutine

! Scalar I/O
subroutine frio3( id, str, s1, i1, i2, ir, nr )
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: id, i1(3), i2(3), ir, nr
character(*), intent(in) :: str
integer :: i, fh, nb, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i = abs( id )
fh = filehandles(i)
if ( fh == 0 ) then
  fh = id + 65536
  filehandles(i) = fh
  write( 0, * ) 'Opening file: ', trim( str )
  inquire( iolength=nb ) s1(j1:j2,k1:k2,l1:l2)
  if ( id < 0 .or. ir > 1 ) then
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='old' ) 
  else
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='new' )
  end if
end if
if ( ir < 1 ) return
if ( id < 0 ) then
  read(  fh, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
else
  write( fh, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
end if
if ( ir == nr ) then
  close( fh )
  i = abs( id )
  filehandles(i) = 0
end if
end subroutine

! Vector I/O
subroutine frio4( id, str, w1, ic, i1, i2, ir, nr )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: id, ic, i1(3), i2(3), ir, nr
character(*), intent(in) :: str
integer :: i, fh, nb, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i = abs( id )
fh = filehandles(i)
if ( fh == 0 ) then
  fh = id + 65536
  filehandles(i) = fh
  write( 0, * ) 'Opening file: ', trim( str )
  inquire( iolength=nb ) w1(j1:j2,k1:k2,l1:l2,ic)
  if ( id < 0 .or. ir > 1 ) then
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='old' ) 
  else
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='new' )
  end if
end if
if ( ir < 1 ) return
if ( id < 0 ) then
  read(  fh, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
else
  write( fh, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
end if
if ( ir == nr ) then
  close( fh )
  i = abs( id )
  filehandles(i) = 0
end if
end subroutine
  
end module

