! Output routines
module m_output
implicit none
contains

!------------------------------------------------------------------------------!
! Initialize output
subroutine output_init
use m_globals
use m_collectiveio
use m_zone
use m_bc
real :: rout
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nc, iz, onpass
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
if ( onpass == 0 ) ditout(iz) = 0

! Zone or point location
select case( outtype(iz) )
case( 'z' )
  i1 = i1out(iz,:)
  i2 = i2out(iz,:)
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
      call pminloc( rout, i1, f2, nn, nnoff, i )
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
    call pminloc( rout, i1, s2, nn, nnoff, 0 )
  end if
  i2 = i1
  if ( rout > dx * dx ) ditout(iz) = nt + 1
end select

! Interval 
if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
if ( fault .and. faultnormal == 0 ) ditout(iz) = nt + 1

! Save indices
if ( any( i2 < i1 ) ) stop 'bad output indices'
i1out(iz,:) = i1
i2out(iz,:) = i2

! Split collective i/o
i1 = max( i1, i1node )
i2 = min( i2, i2node )
if ( cell ) i2 = min( i2, i2cell )
if ( any( i2 < i1 ) ) ditout(iz) = nt + 1
call splitio( iz, nout, ditout(iz) )
 
end do

end subroutine

!------------------------------------------------------------------------------!
! Write output
subroutine output( pass )
use m_globals
use m_collectiveio
use m_bc
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
    call rwrite( 'stats/t', t, it )
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
      i1 = ihypo
      i1(i) = 1
      call rwrite( 'stats/tarrhypo', tarr(i1(1),i1(2),i1(3)), it )
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
      call rwrite( 'stats/efric', efric, it )
      call rwrite( 'stats/estrain', estrain, it )
      call rwrite( 'stats/m0', m0, it )
      r1 = -0.
      if ( m0 > 0. ) r1 = 2. / 3. * log10( m0 ) - 10.7
      call rwrite( 'stats/mw', r1, it )
    end if
  end if
end select

doiz: do iz = 1, nout

! Pass
if ( ditout(iz) /= 0 ) then
  if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz
end if
call outprops( fieldout(iz), nc, onpass, fault, cell )
if ( pass /= onpass ) cycle doiz

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i3 = max( i1, i1node )
i4 = min( i2, i2node )
if ( cell ) i4 = min( i2, i2cell )
if ( fault ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i3(i) = 1
  i4(i) = 1
end if

! Binary output
do ic = 1, nc
  ir = 1
  write( str, '(i2.2,a,a,i1)' ) iz, '/', trim( fieldout(iz) ), ic
  if ( pass /= 0 ) then
  if ( all( i1 == i2 ) ) then
    ir = it / ditout(iz)
  else
    write( str, '(i2.2,a,a,i1,i6.6)' ) iz, '/', trim( fieldout(iz) ), ic, it
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
  case( 'ts0'  ); call vectorio( 'w', str, t3,   ic, ir, i1, i2, i3, i4, iz )
  case( 'tsm0' ); call scalario( 'w', str, ts,       ir, i1, i2, i3, i4, iz )
  case( 'tn0'  ); call scalario( 'w', str, tn,       ir, i1, i2, i3, i4, iz )
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

!------------------------------------------------------------------------------!
! Output properties
subroutine outprops( field, nc, onpass, fault, cell )
character(*), intent(in) :: field
integer, intent(out) :: nc, onpass
logical, intent(out) :: fault, cell
nc = 1
fault = .false.
onpass = 2
cell = .false.
select case( field )
case( 'x'    ); onpass = 0; nc = 3
case( 'rho'  ); onpass = 0
case( 'vp'   ); onpass = 0
case( 'vs'   ); onpass = 0
case( 'mu'   ); onpass = 0; cell = .true.
case( 'lam'  ); onpass = 0; cell = .true.
case( 'v'    ); onpass = 1; nc = 3
case( 'u'    ); nc = 3
case( 'w'    ); onpass = 1; nc = 6; cell = .true.
case( 'a'    ); nc = 3
case( 'vm'   ); onpass = 1
case( 'um'   )
case( 'wm'   ); onpass = 1; cell = .true.
case( 'am'   )
case( 'pv'   )
case( 'nhat' ); fault = .true.; onpass = 0; nc = 3
case( 'ts0'  ); fault = .true.; onpass = 0; nc = 3
case( 'tsm0' ); fault = .true.; onpass = 0
case( 'tn0'  ); fault = .true.; onpass = 0
case( 'mus'  ); fault = .true.; onpass = 0
case( 'mud'  ); fault = .true.; onpass = 0
case( 'dc'   ); fault = .true.; onpass = 0
case( 'co'   ); fault = .true.; onpass = 0
case( 'sv'   ); fault = .true.; onpass = 1; nc = 3
case( 'su'   ); fault = .true.; onpass = 1; nc = 3
case( 'ts'   ); fault = .true.; nc = 3
case( 'sa'   ); fault = .true.; nc = 3
case( 'svm'  ); fault = .true.; onpass = 1
case( 'sum'  ); fault = .true.; onpass = 1
case( 'tsm'  ); fault = .true.
case( 'sam'  ); fault = .true.
case( 'tn'   ); fault = .true.
case( 'fr'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'psv'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default
  write( 0, * ) 'error: unknown output field: ', field
  stop
end select
end subroutine

!------------------------------------------------------------------------------!
! Write metadata
subroutine metadata
use m_globals
real :: courant
integer :: i1(3), i2(3), i, nc, iz, onpass
character :: endian
character(7) :: field
logical :: fault, cell

! Diagnostic
if ( debug /= 0 ) then
  write( str, '(a,i6.6,a)' ) 'debug/db', ip, '.m'
  open( 1, file=str, status='replace' )
  i = 0
  if ( master ) i = 1
  write( 1, * ) 'master      =  ', i,           ';'
  write( 1, * ) 'ifn         =  ', ifn,         ';'
  write( 1, * ) 'nin         =  ', nin,         ';'
  write( 1, * ) 'nout        =  ', nout,        ';'
  write( 1, * ) 'nlock       =  ', nlock,       ';'
  write( 1, * ) 'noper       =  ', noper,       ';'
  write( 1, * ) 'ip          =  ', ip,          ';'
  write( 1, * ) 'ip3         = [', ip3,        '];'
  write( 1, * ) 'np          = [', np,         '];'
  write( 1, * ) 'ihypo       = [', ihypo,      '];'
  write( 1, * ) 'nm          = [', nm,         '];'
  write( 1, * ) 'nnoff       = [', nnoff,      '];'
  write( 1, * ) 'i1oper      = [', i1oper(1,:), ';', i1oper(2,:), '];'
  write( 1, * ) 'i1node      = [', i1node,     '];'
  write( 1, * ) 'i1cell      = [', i1cell,     '];'
  write( 1, * ) 'i1pml       = [', i1pml,      '];'
  write( 1, * ) 'i2oper      = [', i2oper(1,:), ';', i2oper(2,:), '];'
  write( 1, * ) 'i2node      = [', i2node,     '];'
  write( 1, * ) 'i2cell      = [', i2cell,     '];'
  write( 1, * ) 'i2pml       = [', i2pml,      '];'
  write( 1, * ) 'ibc1        = [', ibc1,       '];'
  write( 1, * ) 'ibc2        = [', ibc2,       '];'
  write( 1, * ) 'oper        = ''', oper,     ''';'
  do iz = 1, nin
    select case( intype(iz) )
    case( 'z' ); write( 1, '(a,a,g15.7,a,6i7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'zone'", i1in(iz,:), i2in(iz,:), ' };'
    case( 'c' ); write( 1, '(a,a,g15.7,a,6g15.7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'cube'", x1in(iz,:), x2in(iz,:), ' };'
    end select
  end do
  do iz = 1, nlock
    write( 1, '(a,9i7,a)' ) &
      'lock        = [', ilock(iz,:), i1lock(iz,:), i2lock(iz,:), '];'
  end do
  close( 1 )
end if

! Metadata
if ( master ) then
  endian = 'l'
  if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
  courant = dt * vp2 * sqrt( 3. ) / abs( dx )
  open( 1, file='meta.m', status='replace' )
  write( 1, * ) 'dx          =  ', dx,      ';'
  write( 1, * ) 'rsource     =  ', rsource, ';'
  write( 1, * ) 'rcrit       =  ', rcrit,   ';'
  write( 1, * ) 'rmax        =  ', rmax,    ';'
  write( 1, * ) 'dt          =  ', dt,      ';'
  write( 1, * ) 'tsource     =  ', tsource, ';'
  write( 1, * ) 'trelax      =  ', trelax,  ';'
  write( 1, * ) 'rho0        =  ', rho0,    ';'
  write( 1, * ) 'rho1        =  ', rho1,    ';'
  write( 1, * ) 'rho2        =  ', rho2,    ';'
  write( 1, * ) 'vp0         =  ', vp0,     ';'
  write( 1, * ) 'vp1         =  ', vp1,     ';'
  write( 1, * ) 'vp2         =  ', vp2,     ';'
  write( 1, * ) 'vs0         =  ', vs0,     ';'
  write( 1, * ) 'vs1         =  ', vs1,     ';'
  write( 1, * ) 'vs2         =  ', vs2,     ';'
  write( 1, * ) 'vrup        =  ', vrup,    ';'
  write( 1, * ) 'svtol       =  ', svtol,   ';'
  write( 1, * ) 'rexpand     =  ', rexpand, ';'
  write( 1, * ) 'courant     =  ', courant, ';'
  write( 1, '(a,10g15.7,a)' ) ' affine      = [', affine, '];'
  write( 1, * ) 'viscosity   = [', viscosity, '];'
  write( 1, * ) 'upvector    = [', upvector,  '];'
  write( 1, * ) 'symmetry    = [', symmetry,  '];'
  write( 1, * ) 'xcenter     = [', xcenter,   '];'
  write( 1, * ) 'xhypo       = [', xhypo,     '];'
  write( 1, * ) 'moment1     = [', moment1,   '];'
  write( 1, * ) 'moment2     = [', moment2,   '];'
  write( 1, * ) 'nt          =  ', nt,          ';'
  write( 1, * ) 'itcheck     =  ', itcheck,     ';'
  write( 1, * ) 'npml        =  ', npml,        ';'
  write( 1, * ) 'faultnormal =  ', faultnormal, ';'
  write( 1, * ) 'origin      =  ', origin,      ';'
  write( 1, * ) 'fixhypo     =  ', fixhypo,     ';'
  write( 1, * ) 'nn          = [', nn,            '];'
  write( 1, * ) 'ihypo       = [', ihypo - nnoff, '];'
  write( 1, * ) 'n1expand    = [', n1expand,      '];'
  write( 1, * ) 'n2expand    = [', n2expand,      '];'
  write( 1, * ) 'bc1         = [', bc1,           '];'
  write( 1, * ) 'bc2         = [', bc2,           '];'
  write( 1, * ) 'grid        = ''', trim( grid ),  ''';'
  write( 1, * ) 'rfunc       = ''', trim( rfunc ), ''';'
  write( 1, * ) 'tfunc       = ''', trim( tfunc ), ''';'
  write( 1, * ) 'endian      = ''', endian, ''';'
  do iz = 1, nout
    i = ditout(iz)
    i1 = i1out(iz,:) - nnoff
    i2 = i2out(iz,:) - nnoff
    call outprops( fieldout(iz), nc, onpass, fault, cell )
    write( field, * ) '''', trim( fieldout(iz) ), ''''
    write( 1, '(a,i3,a,i1,a,7i7,a)' ) ' out{', iz, '}    = { ', nc, field, i, i1, i2, ' };'
  end do
  close( 1 )
end if

end subroutine

!------------------------------------------------------------------------------!
! Write integer binary timeseries
subroutine iwrite( filename, val, it )
character(*), intent(in) :: filename
integer, intent(in) :: val, it
integer :: i
inquire( iolength=i ) val
if ( it == 1 ) then
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
else
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
end if
write( 1, rec=it ) val
close( 1 )
end subroutine

!------------------------------------------------------------------------------!
! Write real binary timeseries
subroutine rwrite( filename, val, it )
character(*), intent(in) :: filename
real, intent(in) :: val
integer, intent(in) :: it
integer :: i
inquire( iolength=i ) val
if ( it == 1 ) then
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='replace' )
else
  open( 1, file=filename, recl=i, form='unformatted', access='direct', status='old' )
end if
write( 1, rec=it ) val
close( 1 )
end subroutine

!------------------------------------------------------------------------------!
! Write stats
subroutine stats( rr, ii, filename, it )
use m_collective
real, intent(in) :: rr
character(*), intent(in) :: filename
integer, intent(in) :: ii(3), it
call rwrite( 'stats/' // filename, rr, it )
call iwrite( 'stats/' // filename // '1', ii(1), it )
call iwrite( 'stats/' // filename // '2', ii(2), it )
call iwrite( 'stats/' // filename // '3', ii(3), it )
end subroutine

!------------------------------------------------------------------------------!
! Write timing info
subroutine clock( filename, it )
character(*), intent(in), optional :: filename
integer, intent(in), optional :: it
integer, save :: clock0, clock1, clockrate, clockmax
integer :: clock2
real :: tt, dt
if ( .not. present( it ) ) then
  call system_clock( clock0, clockrate, clockmax )
  clock1 = clock0
else
  call system_clock( clock2 )
  tt = real( clock2 - clock0 ) / real( clockrate )
  dt = real( clock2 - clock1 ) / real( clockrate )
  if ( tt < 0. ) tt = real( clock2 - clock0 + clockmax ) / real( clockrate ) 
  if ( dt < 0. ) dt = real( clock2 - clock1 + clockmax ) / real( clockrate ) 
  call rwrite( 'clock/tt' // filename, tt, it )
  call rwrite( 'clock/dt' // filename, dt, it )
  clock1 = clock2
end if
end subroutine

end module

