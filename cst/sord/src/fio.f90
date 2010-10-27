! fortran binary i/o
module m_fio
integer, parameter :: fio_file_null = -1
contains

subroutine fiio2( fh, f2, mode, filename, m, o, verb )
implicit none
integer, intent(inout) :: fh
integer, intent(inout) :: f2(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o
logical, intent(in) :: verb
integer, save :: filehandle = 10
integer :: i, n
if ( fh == fio_file_null ) then
    filehandle = filehandle + 1
    fh = filehandle
    if ( verb ) write( *, '(2a)' ) 'Opening file: ', trim( filename )
    inquire( iolength=i ) f2(:,1)
    if ( mode == 'r' .or. o > 0 ) then
        open( fh, file=filename, recl=i, form='unformatted', access='direct', &
        status='old' )
    else
        open( fh, file=filename, recl=i, form='unformatted', access='direct', &
        status='new' )
    end if
end if
n = size( f2, 2 )
if ( mode == 'r' ) then
    if ( verb ) write( *, '(2a)' ) 'Reading file: ', trim( filename )
    do i = 1, n
        read( fh, rec=o+i ) f2(:,i)
    end do
else
    if ( verb ) write( *, '(2a)' ) 'Writing file: ', trim( filename )
    do i = 1, n
        write( fh, rec=o+i ) f2(:,i)
    end do
end if
if ( o+n == m ) then
    close( fh )
    if ( fh == filehandle ) filehandle = filehandle - 1
    fh = fio_file_null
end if
end subroutine

subroutine frio2( fh, f2, mode, filename, m, o, verb )
implicit none
integer, intent(inout) :: fh
real, intent(inout) :: f2(:,:)
character(1), intent(in) :: mode
character(*), intent(in) :: filename
integer, intent(in) :: m, o
logical, intent(in) :: verb
integer, save :: filehandle = 10
integer :: i, n
if ( fh == fio_file_null ) then
    filehandle = filehandle + 1
    fh = filehandle
    if ( verb ) write( *, '(2a)' ) 'Opening file: ', trim( filename )
    inquire( iolength=i ) f2(:,1)
    if ( mode == 'r' .or. o > 0 ) then
        open( fh, file=filename, recl=i, form='unformatted', access='direct', &
        status='old' )
    else
        open( fh, file=filename, recl=i, form='unformatted', access='direct', &
        status='new' )
    end if
end if
n = size( f2, 2 )
if ( mode == 'r' ) then
    if ( verb ) write( *, '(2a)' ) 'Reading file: ', trim( filename )
    do i = 1, n
        read( fh, rec=o+i ) f2(:,i)
    end do
else
    if ( verb ) write( *, '(2a)' ) 'Writing file: ', trim( filename )
    do i = 1, n
        write( fh, rec=o+i ) f2(:,i)
    end do
end if
if ( o+n == m ) then
    close( fh )
    if ( fh == filehandle ) filehandle = filehandle - 1
    fh = fio_file_null
end if
end subroutine

end module

