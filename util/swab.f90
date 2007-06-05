! Swap endian of files in place
program main
implicit none
integer, parameter :: nb = 4
integer :: n1, n2, i, j, k, ifile, command_argument_count
character, allocatable :: b0(:,:)
character :: b1(nb)
character(255) :: str
character :: endian

! Print native endian
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
print *, endian
if ( command_argument_count() < 3 ) return

! Block sizes
call get_command_argument( 1, str )
read ( str, * ) n1
call get_command_argument( 2, str )
read ( str, * ) n2
n1 = n1 / nb
allocate( b0(nb,n1) )

! Swap bytes
do ifile = 3, command_argument_count()
  call get_command_argument( ifile, str )
  inquire( iolength=i ) b0
  open( 1, file=str, recl=i, form='unformatted', access='direct', status='old' )
  open( 2, file=trim(str)//'.swab', recl=i, form='unformatted', access='direct', status='replace' )
  do k = 1, n2
    read( 1, rec=k ) b0
    do j = 1, n1
      b1 = b0(:,j)
      forall( i=1:nb ) b0(i,j) = b1(nb-i+1)
    end do
    write( 2, rec=k ) b0
  end do
  close( 1 )
  close( 2 )
  write( 0, * ) trim( str )
end do
end program

