program swab4
implicit none
integer :: err
integer(1) :: bytes(4)
do
  read( 5, '(a1)', form='unformatted', advance='no', iostat=err ) bytes(1)
  if ( err /= 0 ) exit
  read( 5, '(3a1)', form='unformatted', advance='no', iostat=err ) bytes(2:4)
  if ( err /= 0 ) then
    write( 0, '(a)' ) 'Error: number of bytes must be a multiple of 4, extra truncated'
    exit
  end if
  write( 6, '(4a1)', advance='no' ) bytes(4:1:-1)
end do
end program
