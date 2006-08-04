program dynread

implicit none
real :: tn, ts, dc
integer :: i, j, k, l, err, reclen

open( 1, file='tsdynfile', form='formatted' )
inquire( iolength=reclen ) j
open( 2, file='j', recl=reclen, form='unformatted', access='direct' )
open( 3, file='k', recl=reclen, form='unformatted', access='direct' )
open( 4, file='l', recl=reclen, form='unformatted', access='direct' )
inquire( iolength=reclen ) tn
open( 7, file='tn', recl=reclen, form='unformatted', access='direct' )
open( 8, file='ts', recl=reclen, form='unformatted', access='direct' )
open( 9, file='dc', recl=reclen, form='unformatted', access='direct' )
i = 0

do
  read( 1, *, iostat=err ) j, k, l, tn, ts, dc
  if( err /= 0 ) exit
  i = i + 1
  write( 2, rec=i ) j
  write( 3, rec=i ) k
  write( 4, rec=i ) l
  write( 7, rec=i ) tn
  write( 8, rec=i ) ts
  write( 9, rec=i ) dc
end do

close( 1 )
close( 2 )
close( 3 )
close( 4 )
close( 7 )
close( 8 )
close( 9 )

end program

