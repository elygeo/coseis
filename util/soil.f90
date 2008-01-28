! Compute average V_S for the upper 30 m
program main
use m_tscoords
implicit none
integer :: nn, i, io
real, allocatable :: f(:,:,:,:)

open( 1, file='nn', status='old' )
read( 1, * ) nn
close( 1 )
allocate( f(nn,1,1,2) )
inquire( iolength=io ) f
open( 1, file='x1', recl=io, form='unformatted', access='direct', status='old' )
open( 2, file='x2', recl=io, form='unformatted', access='direct', status='old' )
read( 1, rec=1 ) f(:,:,:,1)
read( 2, rec=1 ) f(:,:,:,2)
close( 1 )
close( 2 )
call ts2ll( f, 1, 2 )
open( 1, file='rlon', recl=io, form='unformatted', access='direct', status='replace' )
open( 2, file='rlat', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) f(:,:,:,1)
write( 2, rec=1 ) f(:,:,:,2)
close( 1 )
close( 2 )
f(:,:,:,2) = 0.
do i = 0, 0
  f(:,:,:,1) = i
  open( 1, file='rdep', recl=io, form='unformatted', access='direct', status='replace' )
  write( 1, rec=1 ) f(:,:,:,1)
  close( 1 )
  call system( './cvm nn rlon rlat rdep rho vp vs' )
  open( 1, file='vs', recl=io, form='unformatted', access='direct', status='old' )
  read( 1, rec=1 ) f(:,:,:,1)
  close( 1 )
  print *, i, minval( f(:,:,:,1) ), maxval( f(:,:,:,1) )
  f(:,:,:,2) = f(:,:,:,2) + f(:,:,:,1)
enddo
f(:,:,:,2) = f(:,:,:,2) / 1.
open( 1, file='vs30', recl=io, form='unformatted', access='direct', status='replace' )
write( 1, rec=1 ) f(:,:,:,2)
close( 1 )

end program

