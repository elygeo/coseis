! Cook SDSU ShakeOut data

program main
implicit none
integer, parameter :: n1 = 6000, n2 = 3000, nt = 4545, nblock = 20, nskip = 10, ndec = 5
real, parameter :: t0 = -0.73, dt0 = 0.055, dt = 0.2, rr = 1. / ( ndec * ndec )
integer :: i, j, k, jj, kk, io, it0, it = 0
real :: vx(n1,n2), vy(n1,n2), vz(n1,n2), ux(n1,n2), uy(n1,n2), uz(n1,n2), pv(n1,n2), pvh(n1,n2), vh(n1/ndec,n2/ndec), t
character(256) :: str

pv = 0.
pvh = 0.
inquire( iolength=io ) vh
open( 1, file='vh', recl=io, form='unformatted', access='direct', status='replace' )
inquire( iolength=io ) vx
do while ( it0 < nt )
  it = it + 1
  t = dt * ( it - 1 )
  it0 = nint( ( t - t0 ) / dt0 ) + 1
  it0 = max( it0, 1 )
  print *, it, it0, t
  i = modulo( it0 - 1, nblock ) + 1
  write( str, '(a,i5.5)' ) 'data/SX96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) vx
  close( 2 )
  write( str, '(a,i5.5)' ) 'data/SY96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) vy
  close( 2 )
  write( str, '(a,i5.5)' ) 'data/SZ96PS', ( ( it0 - 1 ) / nblock + 1 ) * nblock * nskip
  open( 2, file=str, recl=io, form='unformatted', access='direct', status='old' )
  read( 2, rec=i ) vz
  close( 2 )
  ux = ux + dt * vx
  uy = uy + dt * vy
  uz = uz + dt * vz
  write( 1, rec=it ) vh
  v = sqrt( vx * vx + vy * vy + vz * vz )
  pv = max( v, pv )
  v = sqrt( vx * vx + vy * vy )
  pvh = max( v, pvh )
  t = dt * ( it - 1 )
  it1 = nint( ( t - t0 ) / dt0 ) + 1
  if ( it0 == it1 ) then
    vh = 0.
    do k = 1, n2; kk = ( k - 1 ) / ndec + 1
    do j = 1, n1; jj = ( j - 1 ) / ndec + 1
      vh(jj,kk) = vh(jj,kk) + rr * v(j,k)
    end do
    end do
    write( 4, rec=it ) vh
    it = it + 1
  end if
enddo
close( 1 )

open( 1, file='ux',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='uy',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='uz',  recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) ux
write( 2, rec=1 ) uy
write( 3, rec=1 ) uz
close( 1 )
close( 2 )
close( 3 )

v = sqrt( ux * ux + uy * uy + uz * uz )
open( 1, file='um',  recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='pv',  recl=io, form='unformatted', access='direct', status='replace' )
open( 3, file='pvh', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) v
write( 2, rec=1 ) pv
write( 3, rec=1 ) pvh
close( 1 )
close( 2 )
close( 3 )

end program

