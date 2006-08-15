! Write output
module m_output
implicit none
contains

subroutine iwrite( filename, i, ir )
character(*), intent(in) :: filename
integer, intent(in) :: i, ir
integer :: reclen
inquire( iolength=reclen ) i
open( 1, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct' )
write( 1, rec=ir ) i
close( 1 )
end subroutine

subroutine rwrite( filename, r, ir )
character(*), intent(in) :: filename
real, intent(in) :: r
integer, intent(in) :: ir
integer :: reclen
inquire( iolength=reclen ) r
open( 1, &
  file=filename, &
  recl=reclen, &
  form='unformatted', &
  access='direct' )
write( 1, rec=ir ) r
close( 1 )
end subroutine

subroutine minwrite( filename, s, ir, nn, nnoff, i2d, master )
character(*), intent(in) :: filename
real, intent(in) :: s(:,:,:)
integer, intent(in) :: ir, nn(3), nnoff(3), i2d
logical, intent(in) :: master
real :: r
integer :: i, ii(3), reclen
call pminloc( r, ii, s, nn, nnoff, i2d )
ii = ii - nnoff - 1
i = 1 + ii(1) + nn(1) * ( ii(2) + nn(2) * ii(3) )
if ( master ) then
  inquire( iolength=reclen ) r
  open( 1, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) r
  close( 1 )
  filename = trim( filename ) // 'i'
  open( 1, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) i
  close( 1 )
end if
end subroutine

subroutine maxwrite( filename, s, ir, nn, nnoff, i2d, master )
character(*), intent(in) :: filename
real, intent(in) :: s(:,:,:)
integer, intent(in) :: ir, nn(3), nnoff(3), i2d
logical, intent(in) :: master
real :: r
integer :: i, i1(3), reclen
call pmaxloc( r, ii, s, nn, nnoff, i2d )
ii = ii - nnoff - 1
i = 1 + ii(1) + nn(1) * ( ii(2) + nn(2) * ii(3) )
if ( master ) then
  inquire( iolength=reclen ) r
  open( 1, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) r
  close( 1 )
  filename = trim( filename ) // 'i'
  open( 1, &
    file=filename, &
    recl=reclen, &
    form='unformatted', &
    access='direct' )
  write( 1, rec=ir ) i
  close( 1 )
end if
end subroutine

subroutine output( pass )
use m_globals
use m_collectiveio
integer, intent(in) :: pass
real :: r1, r2
integer :: onpass, i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, ic, ir, iz
logical :: fault, dofault

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Magnitudes
select case( pass )
case( 1 )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  call maxwrite( '00/umax', s1, it, nn, nnoff, 0, master )
  call maxwrite( '00/wmax', s2, it, nn, nnoff, 0, master )
  if ( master .and. umax > dx / 10. ) print *, ip, 'warning: u !<< dx'
  if ( dofault ) then
    call maxwrite( '00/svmax', f1, it, nn, nnoff, i, master )
    call maxwrite( '00/sumax', f2, it, nn, nnoff, i, master )
  end if
case( 2 )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  pv = max( pv, s2 )
  call maxwrite( '00/amax', s1, it, nn, nnoff, 0, master )
  call maxwrite( '00/vmax', s2, it, nn, nnoff, 0, master )
  if ( dofault ) then
    call maxwrite( '00/samax',   f1,   it, nn, nnoff, i, master )
    call maxwrite( '00/slmax',   sl,   it, nn, nnoff, i, master )
    call minwrite( '00/tnmin',   tn,   it, nn, nnoff, i, master )
    call maxwrite( '00/tnmax',   tn,   it, nn, nnoff, i, master )
    call maxwrite( '00/tsmax',   ts,   it, nn, nnoff, i, master )
    call maxwrite( '00/tarrmax', tarr, it, nn, nnoff, i, master )
  end if
end select

doiz: do iz = 1, nout !--------------------------------------------------------!

if ( ditout(iz) == 0 ) then
  if ( it > 1 ) cycle doiz
else
  if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz
end if

! Properties
nc = 1
fault= .false.
onpass = 2
select case( fieldout(iz) )
case( 'x'    ); nc = 3
case( 'mr'   );
case( 'mu'   );
case( 'lam'  );
case( 'y'    );
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3; onpass = 1
case( 'w'    ); nc = 6; onpass = 1
case( 'am'   );
case( 'vm'   );
case( 'pv'   );
case( 'um'   ); onpass = 1
case( 'wm'   ); onpass = 1
case( 'nhat' ); fault = .true.; nc = 3
case( 't0'   ); fault = .true.; nc = 3
case( 'mus'  ); fault = .true.
case( 'mud'  ); fault = .true.
case( 'dc'   ); fault = .true.
case( 'co'   ); fault = .true.
case( 'sa'   ); fault = .true.; nc = 3
case( 'sv'   ); fault = .true.; nc = 3; onpass = 1
case( 'su'   ); fault = .true.; nc = 3; onpass = 1
case( 'ts'   ); fault = .true.; nc = 3
case( 't'    ); fault = .true.; nc = 3
case( 'sam'  ); fault = .true.
case( 'svm'  ); fault = .true.; onpass = 1
case( 'sum'  ); fault = .true.; onpass = 1
case( 'tnm'  ); fault = .true.
case( 'tsm'  ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'f'    ); fault = .true.
case( 'psv'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default
  print *, 'error: unknown output field: ' fieldout(iz)
  stop
end select

! Select pass
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i1l = max( i1, i1node )
i2l = min( i2, i2node )
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i1l(i) = 1
  i2l(i) = 1
end if

! Binary output
do ic = 1, nc
  ir = 1
  write( str, '(i2.2,a,a,i1)' ) iz, '/', trim( fieldout(iz) ), ic
  if ( ditout(iz) > 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = it / ditout(iz)
  else
    write( str, '(i2.2,a,a,i1,i6.6)' ) iz, '/', trim( fieldout(iz) ), ic, it
  end if
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'mr'   ); call scalario( 'w', str, mr,       ir, i1, i2, i1l, i2l, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,       ir, i1, i2, i1l, i2l, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,      ir, i1, i2, i1l, i2l, iz )
  case( 'y'    ); call scalario( 'w', str, y,        ir, i1, i2, i1l, i2l, iz )
  case( 'a'    ); call vectorio( 'w', str, w1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'v'    ); call vectorio( 'w', str, v,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'u'    ); call vectorio( 'w', str, u,    ic, ir, i1, i2, i1l, i2l, iz )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( 'w', str, w1, ic,   ir, i1, i2, i1l, i2l, iz )
   if ( ic > 3 )  call vectorio( 'w', str, w2, ic-3, ir, i1, i2, i1l, i2l, iz )
  case( 'am'   ); call scalario( 'w', str, s1,       ir, i1, i2, i1l, i2l, iz )
  case( 'vm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i1l, i2l, iz )
  case( 'pv'   ); call scalario( 'w', str, pv,       ir, i1, i2, i1l, i2l, iz )
  case( 'um'   ); call scalario( 'w', str, s1,       ir, i1, i2, i1l, i2l, iz )
  case( 'wm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i1l, i2l, iz )
  case( 'nhat' ); call vectorio( 'w', str, nhat, ic, ir, i1, i2, i1l, i2l, iz )
  case( 't0'   ); call vectorio( 'w', str, t0,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,      ir, i1, i2, i1l, i2l, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,      ir, i1, i2, i1l, i2l, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,       ir, i1, i2, i1l, i2l, iz )
  case( 'co'   ); call scalario( 'w', str, co,       ir, i1, i2, i1l, i2l, iz )
  case( 'sa'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sv'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'su'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'ts'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 't'    ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i1l, i2l, iz )
  case( 'sam'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'svm'  ); call scalario( 'w', str, f1,       ir, i1, i2, i1l, i2l, iz )
  case( 'sum'  ); call scalario( 'w', str, f2,       ir, i1, i2, i1l, i2l, iz )
  case( 'tnm'  ); call scalario( 'w', str, tn,       ir, i1, i2, i1l, i2l, iz )
  case( 'tsm'  ); call scalario( 'w', str, ts,       ir, i1, i2, i1l, i2l, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,       ir, i1, i2, i1l, i2l, iz )
  case( 'f'    ); call scalario( 'w', str, f2,       ir, i1, i2, i1l, i2l, iz )
  case( 'psv'  ); call scalario( 'w', str, psv,      ir, i1, i2, i1l, i2l, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i1l, i2l, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i1l, i2l, iz )
  case default
    print *, 'error: unknown output field 2: ' fieldout(iz)
    stop
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 1 ) return

! Check for stop file
!if ( master ) then
!  inquire( file='stop', exist=test )
!  if ( test ) then
!    itcheck = it
!    nt = it
!  end if
!  ibroadcast( itcheck )
!  ibroadcast( nt )
!end if

! Metadata
if ( master ) then
  open(  1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
  call iwrite( '00/it', it, it )
  call rwrite( '00/t',  t,  it )
  if ( dofault ) then
    i = abs( faultnormal )
    i1 = ihypo
    i1(i) = 1
    j = i1(1)
    k = i1(2)
    l = i1(3)
    call rwrite( '00/tarrhypo', tarr(j,k,l), it )
    call rwrite( '00/work',     work,        it )
    call rwrite( '00/efrac',    efrac,       it )
  end if
  close( 9 )              
end if

end subroutine

end module

