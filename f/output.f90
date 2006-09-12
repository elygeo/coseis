! Output routines
module m_output
implicit none
contains

! Initialize output
subroutine output_init
use m_globals
use m_collective
use m_outprops
use m_util
real :: rout
integer :: i1(3), i2(3), n(3), noff(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nc, iz, onpass
character(7) :: field
logical :: dofault, fault, cell

if ( master ) write( 0, * ) 'Output initialization'
if ( nout > nz ) stop 'too many output zones, make nz bigger'

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

do iz = 1, nout

! Output field properties
call outprops( fieldout(iz), nc, onpass, fault, cell )

! Time indices 
if ( fault .and. faultnormal == 0 ) ditout(iz) = 0
if ( i1out(iz,4) < 0 ) i1out(iz,4) = nt + i1out(iz,4) + 1
if ( i2out(iz,4) < 0 ) i2out(iz,4) = nt + i2out(iz,4) + 1
if ( ditout(iz)  < 0 ) ditout(iz)  = nt + ditout(iz)  + 1
if ( onpass == 0 ) then
  i1out(iz,4) = 0
  i2out(iz,4) = 0
end if

! Spacial indices
n = nn + 2 * nhalo
noff = nnoff - nhalo
select case( outtype(iz) )
case( 'z' )
  i1 = i1out(iz,1:3)
  i2 = i2out(iz,1:3)
  call zone( i1, i2, nn, nnoff, ihypo, faultnormal )
  if ( cell ) i2 = i2 - 1
  if ( fault .and. faultnormal /= 0 ) then
    i = abs( faultnormal )
    i1(i) = ihypo(i)
    i2(i) = ihypo(i)
  end if
case( 'x' )
  if ( fault ) then
    i1 = nnoff
    rout = rmax
    if ( dofault ) then
      i = abs( faultnormal )
      i1 = 1
      i2 = nm
      i1(i) = ihypo(i)
      i2(i) = ihypo(i)
      j1 = i1(1); j2 = i2(1)
      k1 = i1(2); k2 = i2(2)
      l1 = i1(3); l2 = i2(3)
      do i = 1, 3
        t2(:,:,:,i) = xout(iz,i) - x(j1:j2,k1:k2,l1:l2,i)
      end do
      i = abs( faultnormal )
      f2 = sum( t2 * t2, 4 )
      call sethalo( f2, rmax * rmax, i1node, i2node )
      call pminloc( rout, i1, f2, n, noff, i )
      i1(i) = ihypo(i)
    end if
  else
    if ( cell ) then
      i1 = i1node
      i2 = i2cell
      j1 = i1(1); j2 = i2(1)
      k1 = i1(2); k2 = i2(2)
      l1 = i1(3); l2 = i2(3)
      forall( j=j1:j2, k=k1:k2, l=l1:l2, i=1:3 )
        w2(j,k,l,i) = xout(iz,i) - 0.125 * &
          ( x(j,k,l,i) + x(j+1,k+1,l+1,i) &
          + x(j+1,k,l,i) + x(j,k+1,l+1,i) &
          + x(j,k+1,l,i) + x(j+1,k,l+1,i) &
          + x(j,k,l+1,i) + x(j+1,k+1,l,i) )
      end forall
      s2 = sum( w2 * w2, 4 )
      call sethalo( s2, rmax * rmax, i1node, i2cell )
    else
      do i = 1, 3
        w2(:,:,:,i) = xout(iz,i) - x(:,:,:,i)
      end do
      s2 = sum( w2 * w2, 4 )
      call sethalo( s2, rmax * rmax, i1node, i2node )
    end if
    call pminloc( rout, i1, s2, n, noff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) ditout(iz) = 0
end select

! Save indices
if ( any( i2 < i1 ) ) stop 'bad output indices'
i1out(iz,1:3) = i1
i2out(iz,1:3) = i2

! Split collective i/o
i1 = max( i1, i1node )
i2 = min( i2, i2node )
if ( cell ) i2 = min( i2, i2cell )
i = ditout(iz)
if ( any( i2 < i1 ) ) i = 0
call splitio( iz, nout, i )
 
end do

end subroutine

!------------------------------------------------------------------------------!

! Write output
subroutine output( pass )
use m_globals
use m_collective
use m_outprops
use m_util
integer, intent(in) :: pass
real :: r1, r2, r3, r4
integer :: i1(3), i2(3), i3(3), i4(3), n(3), noff(3), i, onpass, nc, ic, ir, iz
logical :: dofault, fault, cell

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

! Prepare output and write stats
if ( it > 0 ) then
  n = nn + 2 * nhalo
  noff = nnoff - nhalo
  select case( pass )
  case( 1 )
    s1 = sqrt( sum( v * v, 4 ) )
    s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
    pv = max( pv, s1 )
    call sethalo( s1, -1., i1node, i2node )
    call sethalo( s2, -1., i1cell, i2cell )
    call pmaxloc( r1, i1, s1, n, noff, 0 )
    call pmaxloc( r2, i2, s2, n, noff, 0 )
    if ( master ) then
      call stats( r1, i1-nnoff, 'vmax', it )
      call stats( r2, i2-nnoff, 'wmax', it )
    end if
    if ( dofault ) then
      call sethalo( f1, -1., i1node, i2node )
      call sethalo( f2, -1., i1node, i2node )
      call sethalo( tarr, -1., i1node, i2node )
      call pmaxloc( r1, i1, f1,   n, noff, i ); i1(i) = ihypo(i)
      call pmaxloc( r2, i2, f2,   n, noff, i ); i2(i) = ihypo(i)
      call pmaxloc( r3, i3, sl,   n, noff, i ); i3(i) = ihypo(i)
      call pmaxloc( r4, i4, tarr, n, noff, i ); i4(i) = ihypo(i)
      if ( master ) then
        call stats( r1, i1-nnoff, 'svmax',   it )
        call stats( r2, i2-nnoff, 'sumax',   it )
        call stats( r3, i3-nnoff, 'slmax',   it )
        call stats( r4, i4-nnoff, 'tarrmax', it )
      end if
    end if
  case( 2 )
    s1 = sqrt( sum( u * u, 4 ) )
    s2 = sqrt( sum( w1 * w1, 4 ) )
    call sethalo( s1, -1., i1node, i2node )
    call sethalo( s2, -1., i1node, i2node )
    call pmaxloc( r1, i1, s1, n, noff, 0 )
    call pmaxloc( r2, i2, s2, n, noff, 0 )
    if ( master ) then
      call stats( r1, i1-nnoff, 'umax', it )
      call stats( r2, i2-nnoff, 'amax', it )
      if ( r1 > dx / 10. ) write( 0, * ) 'warning: u !<< dx', r1, dx
    end if
    if ( dofault ) then
      call sethalo( ts, -1., i1node, i2node )
      call sethalo( f2, -1., i1node, i2node )
      call pmaxloc( r1, i1, ts, n, noff, i ); i1(ifn) = ihypo(ifn)
      call pmaxloc( r2, i2, f2, n, noff, i ); i2(ifn) = ihypo(ifn)
      r3 = 2. * minval( tn ) - 1.
      call sethalo( tn, r3, i1node, i2node )
      call pmaxloc( r3, i3, tn, n, noff, i ); i3(ifn) = ihypo(ifn)
      r4 = 2. * r3 + 1.
      call sethalo( tn, r4, i1node, i2node )
      call pminloc( r4, i4, tn, n, noff, i ); i4(ifn) = ihypo(ifn)
      if ( master ) then
        call stats( r1, i1-nnoff, 'tsmax', it )
        call stats( r2, i2-nnoff, 'samax', it )
        call stats( r3, i3-nnoff, 'tnmax', it )
        call stats( r4, i4-nnoff, 'tnmin', it )
      end if
    end if
  end select
end if

doiz: do iz = 1, nout

! Interval
if ( ditout(iz) == 0 ) cycle doiz
if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz
if ( it < i1out(iz,4) .or it > i2out(iz,4) ) cycle doiz

! Pass
call outprops( fieldout(iz), nc, onpass, fault, cell )
i1 = i1out(iz,1:3)
i2 = i2out(iz,1:3)
i3 = max( i1, i1node )
i4 = min( i2, i2node )
if ( cell ) i4 = min( i4, i2cell )
if ( any( i3 > i4 ) ) then 
  ditout(iz) = 0
  cycle doiz
end if
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if
if ( pass /= onpass ) cycle doiz

! Binary output
do ic = 1, nc
  ir = 1
  write( str, '(i2.2,a,a)' ) iz, '/', fieldout(iz)
  if ( nc > 1 ) write( str, '(a,i1)' ) trim( str ), ic
  if ( onpass /= 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = it / ditout(iz)
  else
    write( str, '(a,i6.6)' ) trim( str ), it
  end if
  end if
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,    ic, ir, i1, i2, i3, i4, iz )
  case( 'rho'  ); call scalario( 'w', str, mr,       ir, i1, i2, i3, i4, iz )
  case( 'vp'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'vs'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,       ir, i1, i2, i3, i4, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,      ir, i1, i2, i3, i4, iz )
  case( 'v'    ); call vectorio( 'w', str, v,    ic, ir, i1, i2, i3, i4, iz )
  case( 'u'    ); call vectorio( 'w', str, u,    ic, ir, i1, i2, i3, i4, iz )
  case( 'w'    );
   if ( ic < 4 )  call vectorio( 'w', str, w1, ic,   ir, i1, i2, i3, i4, iz )
   if ( ic > 3 )  call vectorio( 'w', str, w2, ic-3, ir, i1, i2, i3, i4, iz )
  case( 'a'    ); call vectorio( 'w', str, w1,   ic, ir, i1, i2, i3, i4, iz )
  case( 'vm'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'um'   ); call scalario( 'w', str, s1,       ir, i1, i2, i3, i4, iz )
  case( 'wm'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
  case( 'am'   ); call scalario( 'w', str, s2,       ir, i1, i2, i3, i4, iz )
  case( 'pv'   ); call scalario( 'w', str, pv,       ir, i1, i2, i3, i4, iz )
  case( 'nhat' ); call vectorio( 'w', str, nhat, ic, ir, i1, i2, i3, i4, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,      ir, i1, i2, i3, i4, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,      ir, i1, i2, i3, i4, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,       ir, i1, i2, i3, i4, iz )
  case( 'co'   ); call scalario( 'w', str, co,       ir, i1, i2, i3, i4, iz )
  case( 'sv'   ); call vectorio( 'w', str, t1,   ic, ir, i1, i2, i3, i4, iz )
  case( 'su'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i3, i4, iz )
  case( 'ts'   ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i3, i4, iz )
  case( 'sa'   ); call vectorio( 'w', str, t2,   ic, ir, i1, i2, i3, i4, iz )
  case( 'svm'  ); call scalario( 'w', str, f1,       ir, i1, i2, i3, i4, iz )
  case( 'sum'  ); call scalario( 'w', str, f2,       ir, i1, i2, i3, i4, iz )
  case( 'tsm'  ); call scalario( 'w', str, ts,       ir, i1, i2, i3, i4, iz )
  case( 'sam'  ); call scalario( 'w', str, f2,       ir, i1, i2, i3, i4, iz )
  case( 'tn'   ); call scalario( 'w', str, tn,       ir, i1, i2, i3, i4, iz )
  case( 'fr'   ); call scalario( 'w', str, f1,       ir, i1, i2, i3, i4, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,       ir, i1, i2, i3, i4, iz )
  case( 'psv'  ); call scalario( 'w', str, psv,      ir, i1, i2, i3, i4, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i3, i4, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i3, i4, iz )
  case default
    write( 0, * ) 'error: unknown output field: ', fieldout(iz)
    stop
  end select
end do

end do doiz

! Interation counter
if ( master .and. pass == 2 ) then
  open( 1, file='currentstep', status='replace' )
  write( 1, * ) it
  close( 1 )
end if

end subroutine

end module

