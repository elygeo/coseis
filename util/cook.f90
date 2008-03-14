! Cook TeraShake and ShakeOut data.

program main
implicit none
!real, parameter :: dt0 = 0.011, dt = 0.11
!integer, parameter :: n1 = 3000, n2 = 1500, nt = 22728, nblock =  1, ndec = 2
real, parameter :: dt0 = 0.0055, dt = 0.1
integer, parameter :: n1 = 6000, n2 = 3000, nt = 45455, nblock = 20, ndec = 4
integer :: i, j, k, jj, kk, io, it0 = 0, it = 0
real :: x(n1,n2), y(n1,n2), m(n1/ndec,n2/ndec), t = 0.
character(256) :: str

inquire( iolength=io ) m
open( 1, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) x
do while ( it0 <= nt )
  it = it + 1
  t = dt * it
  it0 = t / dt0
  print *, it, it0, t
  i = modulo( it0 - 1, nblock ) + 1
  write( str, '(a,i5.5)' ) 'SX96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) x
  close( 2 )
  write( str, '(a,i5.5)' ) 'SY96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) y
  close( 2 )
  m = 0.
  do k = 1, n2; kk = ( k - 1 ) / ndec + 1
  do j = 1, n1; jj = ( j - 1 ) / ndec + 1
    m(jj,kk) = m(jj,kk) + sqrt( x(j,k) * x(j,k) + y(j,k) * y(j,k) ) / ( ndec * ndec )
  enddo
  enddo
  write( 1, rec=it ) m
enddo
close( 1 )

end program

