program byteswap
implicit none
integer :: err
character :: bytes(4)
do
  read( 5, '(a1)', advance='no', iostat=err ) bytes(1)
  if( err /= 0 ) exit
  read( 5, '(3a1)', advance='no', iostat=err ) bytes(2:4)
  if( err /= 0 ) stop 'number of bytes must be a multiple of 4, extra truncated'
  write( 6, '(4a1)', advance='no' ) bytes(4:1:-1)
end do
end program
