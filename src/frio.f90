! Fortran real binary I/O
module m_frio
contains

subroutine frio2( fh, f, mode, filename, m, o, verb )
implicit none
integer, intent(inout) :: fh
real, intent(inout) :: f(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o
logical, intent(in) :: verb
integer, parameter :: file_null = -1
integer, save :: filehandle = 10
integer :: i, n
if ( fh == file_null ) then
  filehandle = filehandle + 1
  fh = filehandle
  if ( verb ) write( 0, * ) 'Opening file: ', trim( filename )
  inquire( iolength=i ) f(:,1)
  if ( mode == 'r' .or. o > 0 ) then
    open( fh, file=filename, recl=i, form='unformatted', access='direct', &
    status='old' )
  else
    open( fh, file=filename, recl=i, form='unformatted', access='direct', &
    status='new' )
  end if
end if
if ( verb ) write( 0, * ) 'Writing file: ', trim( filename )
n = size( f, 2 )
if ( mode == 'r' ) then
  do i = 1, n
    read( fh, rec=o+i ) f(:,i)
  end do
else
  do i = 1, n
    write( fh, rec=o+i ) f(:,i)
  end do
end if
if ( o+n == m ) then
  close( fh )
  if ( fh == filehandle ) filehandle = filehandle - 1
  fh = file_null
end if
end subroutine

end module

