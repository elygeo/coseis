! Swap endian of files
program main
implicit none
integer, parameter :: nb = 4, nr = 8192
integer :: n, i, j, io, ifile, command_argument_count
character :: b0(nb,nr)
character :: b1(nb), b2(nb)
character(255) :: str
character :: endian

! Print native endian
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
write( *, '(a)' ) endian

! Swap bytes
do ifile = 1, command_argument_count()
  call get_command_argument( ifile, str )
  inquire( iolength=io ) b0
  open( 1, file=str, recl=io, form='unformatted', access='direct', status='old' )
  open( 2, file=trim(str)//'.swab', recl=io, form='unformatted', access='direct', status='replace' )
  n = 0
  do
    read( 1, rec=n+1, iostat=io ) b0
    if ( io /= 0 ) exit
    read( 1, rec=n+1 ) b0
    do j = 1, nr
      b1 = b0(:,j)
      forall( i=1:nb ) b0(i,j) = b1(nb-i+1)
    end do
    write( 2, rec=n+1 ) b0
    n = n + 1
  end do
  close(1)
  close(2)
  inquire( iolength=io ) b1
  open( 1, file=str, recl=io, form='unformatted', access='direct', status='old' )
  open( 2, file=trim(str)//'.swab', recl=io, form='unformatted', access='direct', status='old' )
  n = n * nr
  do
    read( 1, rec=n+1, iostat=io ) b1
    if ( io /= 0 ) exit
    forall( i=1:nb ) b2(i) = b1(nb-i+1)
    write( 2, rec=n+1 ) b2
    n = n + 1
  end do
  close( 1 )
  close( 2 )
  write( 0, * ) n, trim( str )//'.swab'
end do
end program

