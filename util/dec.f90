program main
real :: x(3001*1502)

inquire( iolength=i ) x

open( 1, file='05pv2', recl=i, form='unformatted', access='direct', status='old' )
open( 2, file='13pv2', recl=i, form='unformatted', access='direct', status='replace' )
read( 1, rec=76  ) x; write( 2, rec=1 ) x
read( 1, rec=101 ) x; write( 2, rec=2 ) x
read( 1, rec=126 ) x; write( 2, rec=3 ) x
close( 1 )
close( 2 )

open( 1, file='10vm2', recl=i, form='unformatted', access='direct', status='old' )
open( 2, file='14vm2', recl=i, form='unformatted', access='direct', status='replace' )
read( 1, rec=76  ) x; write( 2, rec=1 ) x
close( 1 )
close( 2 )

end program
