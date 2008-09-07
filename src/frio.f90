! Fortran Real Binary I/O
module m_frio
implicit none
integer, private, parameter :: nz = 1000
integer, private :: filehandles(64+6*nz) = 0
contains

! 1D I/O
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

! 3D I/O
subroutine frio3( id, str, f, i1, i2, ifill )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: id, i1(3), i2(3), ifill(3)
character(*), intent(in) :: str
integer :: i, fh, nb, j1, k1, l1, j2, k2, l2
if ( id == 0 .or. any( i1 > i2 ) ) return
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
fh = id + 65536
write( 0, * ) 'Opening file: ', trim( str )
inquire( iolength=nb ) f(j1:j2,k1:k2,l1:l2)
if ( id < 0 .or. ir > 1 ) then
  open( fh, file=str, recl=nb, form='unformatted', access='direct', status='old' )
else
  open( fh, file=str, recl=nb, form='unformatted', access='direct', status='new' )
end if
if ( id < 0 ) then
  read(  fh, rec=ir ) f(j1:j2,k1:k2,l1:l2)
  do i = i2(1)+1, ifill(1); f(i,:,:) = f(i2(1),:,:); end do
  do i = i2(2)+1, ifill(2); f(:,i,:) = f(:,i2(2),:); end do
  do i = i2(3)+1, ifill(3); f(:,:,i) = f(:,:,i2(3)); end do
else
  write( fh, rec=ir ) f(j1:j2,k1:k2,l1:l2)
end if
close( fh )
end subroutine

! 4D I/O
subroutine frio4( id, str, f, i1, i2, nr, ifill )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: id, i1(4), i2(4), nr, ifill(4)
character(*), intent(in) :: str
integer :: i, fh, nb, j1, k1, l1, j2, k2, l2, it
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
  inquire( iolength=nb ) f(j1:j2,k1:k2,l1:l2,1)
  if ( id < 0 .or. i1(4) > 1 ) then
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='old' ) 
  else
    open( fh, file=str, recl=nb, form='unformatted', access='direct', status='new' )
  end if
end if
if ( i1(4) < 1 ) stop 'error in frio4'
if ( id < 0 ) then
  do it = i1(4), i2(4)
    i = it - i1(4) + 1
    read( fh, rec=it ) f(j1:j2,k1:k2,l1:l2,i)
  end do
  do i = i2(1)+1, ifill(1); f(i,:,:,:) = f(i2(1),:,:,:); end do
  do i = i2(2)+1, ifill(2); f(:,i,:,:) = f(:,i2(2),:,:); end do
  do i = i2(3)+1, ifill(3); f(:,:,i,:) = f(:,:,i2(3),:); end do
  do i = i2(4)+1, ifill(4); f(:,:,:,i) = f(:,:,:,i2(4)); end do
else
  do it = i1(4), i2(4)
    i = it - i1(4) + 1
    write( fh, rec=it ) f(j1:j2,k1:k2,l1:l2,i)
  end do
end if
if ( i2(4) == nr ) then
  close( fh )
  i = abs( id )
  filehandles(i) = 0
end if
end subroutine
  
end module

