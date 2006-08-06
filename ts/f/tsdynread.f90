program dynread

implicit none
real :: f(3), f1(3), f2(3)
integer :: j(3), j1(3), j2(3), i, err, reclen

open( 1, file='tsdynfile', status='old' )
inquire( iolength=reclen ) f(1)
open( 2, file='tn', recl=reclen, form='unformatted', access='direct' )
open( 3, file='ts', recl=reclen, form='unformatted', access='direct' )

i = 0
j1 = 2**31
j2 = 0
f1 = 1e9
f2 = 0.

do
  read( 1, *, iostat=err ) j, f
  if( err /= 0 ) exit
  i = i + 1
  j1 = min( j, j1 )
  j2 = max( j, j2 )
  f1 = min( f, f1 )
  f2 = max( f, f2 )
  write( 2, rec=i ) f(1)
  write( 3, rec=i ) f(2)
end do
print *, 'j1: ', j1
print *, 'j2: ', j2
print *, 'n: ', prod(j2-j1+1)
print *, 'i: ', i
print *, 'f1: ', f1
print *, 'f2: ', f2

close( 1 )
close( 2 )
close( 3 )

end program

