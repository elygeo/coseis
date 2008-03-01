! Cook TS data
! call system( '' )

program main
implicit none
integer, parameter :: &
  n1 = 3000, &
  n2 = 1500, &
  h = 2, &
  ditfile = 20, &
  dit = 30, &
  nt = 22728
integer :: io, it, i, j, k, jj, kk
real :: x(n1,n2), y(n1,n2), m(n1/h,n2/h)
character(256) :: str

inquire( iolength=io ) m
open( 1, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) x
do it = dit, nt, dit
  print *, it
  i = modulo( it - 1, ditfile ) + 1
  write( str, '(a,i5.5)' ) 'SX96PS', ( ( it - 1 ) / ditfile + 1 ) * ditfile
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) x
  close( 2 )
  write( str, '(a,i5.5)' ) 'SY96PS', ( ( it - 1 ) / ditfile + 1 ) * ditfile
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) y
  close( 2 )
  m = 0.
  do k = 1, n2; kk = ( k - 1 ) / h + 1
  do j = 1, n1; jj = ( j - 1 ) / h + 1
    m(jj,kk) = m(jj,kk) + sqrt( x(j,k) * x(j,k) + y(j,k) * y(j,k) ) / ( h * h )
  enddo
  enddo
  write( 1, rec=it/dit ) m
enddo
close( 1 )

end program

