! Cook SDSU ShakeOut data

program main
implicit none
integer, parameter :: n1 = 6000, n2 = 3000, nt = 4545, nblock = 20, nskip = 10, ndec = 5
real, parameter :: t0 = -0.73, dt0 = 0.055, dt = 0.2, rr = 1. / ( ndec * ndec )
integer :: i, j, k, jj, kk, io, it0, it = 0
real :: v1(n1,n2), v2(n1,n2), vh(n1/ndec,n2/ndec), t
character(256) :: str

inquire( iolength=io ) vh
open( 1, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) v1
do while ( it0 < nt )
  it = it + 1
  t = dt * ( it - 1 )
  it0 = nint( ( t - t0 ) / dt0 ) + 1
  it0 = max( it0, 1 )
  print *, it, it0, t
  i = modulo( it0 - 1, nblock ) + 1
  write( str, '(a,i5.5)' ) 'data/SX96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) v1
  close( 2 )
  write( str, '(a,i5.5)' ) 'data/SY96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) v2
  close( 2 )
  vh = 0.
  do k = 1, n2; kk = ( k - 1 ) / ndec + 1
  do j = 1, n1; jj = ( j - 1 ) / ndec + 1
    vh(jj,kk) = vh(jj,kk) + rr * sqrt( v1(j,k)*v1(j,k) + v2(j,k)*v2(j,k) )
  enddo
  enddo
  write( 1, rec=it ) vh
enddo
close( 1 )

end program

