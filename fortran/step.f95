!------------------------------------------------------------------------------!
! STEP

subroutine step
use globals
integer :: wt(5), wt_rate
real :: dwt(5)

do while ( it <= nt )
  it = it + 1;
  call system_clock( wt(1), count_rate=wt_rate )
  call vstep
  call system_clock( wt(2) )
  call system_clock( wt(3) )
  call wstep
  call system_clock( wt(4) )
  s1 = sum( u * u, 4 ); umax = maxval( s1 ); umaxi = maxloc( s1 )
  s1 = sum( v * v, 4 ); vmax = maxval( s1 ); vmaxi = maxloc( s1 )
  s2 = sum( w1 * w1, 4 ) + 2 * sum( w2 * w2, 4 )
  wmax = maxval( s1 ); wmaxi = maxloc( s1 )
  umax = sqrt( umax )
  vmax = sqrt( vmax )
  wmax = sqrt( wmax )
  if ( umax > dx / 10. ) print *, 'Warning: u !<< dx\n'
  if ( nout /= 0 ) call output
  call system_clock( wt(5) )
  dwt(1:4) = real( wt(2:5) - wt(1:4) ) / real( wt_rate )
  dwt(5)   = real( wt(5)   - wt(1)   ) / real( wt_rate )
  if ( ipe == 0 ) print '(a,i5,x,5(e9.2))', ti, dwt
end do

end subroutine

