! Write output
module output_m
use globals_m
use collectiveio_m
implicit none
integer, private :: twall_rate, twall_max, twall1, twall2
contains

! Ouput initialize
subroutine output_init
use zone_m
real :: courant
integer :: i1(3), i2(3), i, j, k, l, nc, iz
character :: endian
character(7) :: field
logical :: fault, test, cell

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Output initialize'
  close( 9 )
  inquire( file='meta.m', exist=test )
  if ( test .and. it == 1 ) stop 'error: previous output found'
  call system_clock( count_rate=twall_rate, count_max=twall_max )
end if

! Diagnostic
if ( debug /= 0 ) then
  open(  9, file='diagnostic.m', position='append' )
  write( 9, * ) 'ifn         =  ', ifn,        ';'
  write( 9, * ) 'nin         =  ', nin,        ';'
  write( 9, * ) 'nout        =  ', nout,       ';'
  write( 9, * ) 'nlock       =  ', nlock,      ';'
  write( 9, * ) 'noper       =  ', noper,      ';'
  write( 9, * ) 'twall_rate  =  ', twall_rate, ';'
  write( 9, * ) 'twall_max   =  ', twall_max,  ';'
  write( 9, * ) 'ip          =  ', ip,         ';'
  write( 9, * ) 'ip3         = [', ip3,       '];'
  write( 9, * ) 'nm          = [', nm,        '];'
  write( 9, * ) 'nnoff       = [', nnoff,     '];'
  write( 9, * ) 'i1oper      = [', i1oper(1,:), ';', i1oper(2,:), '];'
  write( 9, * ) 'i1node      = [', i1node,    '];'
  write( 9, * ) 'i1pml       = [', i1pml,     '];'
  write( 9, * ) 'i1cell      = [', i1cell,    '];'
  write( 9, * ) 'i2oper      = [', i2oper(1,:), ';', i2oper(2,:), '];'
  write( 9, * ) 'i2node      = [', i2node,    '];'
  write( 9, * ) 'i2pml       = [', i2pml,     '];'
  write( 9, * ) 'i2cell      = [', i2cell,    '];'
  write( 9, * ) 'ibc1        = [', ibc1,     '];'
  write( 9, * ) 'ibc2        = [', ibc2,     '];'
  write( 9, * ) 'master      =  ', master,     ';'
  write( 9, * ) 'oper        = ''', oper,    ''';'
  do iz = 1, nin
    write( 9,*) fieldin(iz), ' = [', inval(iz), i1in(iz,:), i2in(iz,:), '];'
  end do
  do iz = 1, nlock
    write( 9,*) 'lock        = [', ilock(iz,:), i1lock(iz,:), i2lock(iz,:), '];'
  end do
  close( 9 )
end if

! Metadata
if ( master ) then
  endian = 'l'
  if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
  courant = dt * vp2 * sqrt( 3. ) / abs( dx )
  open(  9, file='meta.m', status='replace' )
  write( 9, * ) 'dx          =  ', dx,      ';'
  write( 9, * ) 'rsource     =  ', rsource, ';'
  write( 9, * ) 'rcrit       =  ', rcrit,   ';'
  write( 9, * ) 'rmax        =  ', rmax,    ';'
  write( 9, * ) 'dt          =  ', dt,      ';'
  write( 9, * ) 'tsource     =  ', tsource, ';'
  write( 9, * ) 'trelax      =  ', trelax,  ';'
  write( 9, * ) 'rho0        =  ', rho0,    ';'
  write( 9, * ) 'rho1        =  ', rho1,    ';'
  write( 9, * ) 'rho2        =  ', rho2,    ';'
  write( 9, * ) 'vp0         =  ', vp0,     ';'
  write( 9, * ) 'vp1         =  ', vp1,     ';'
  write( 9, * ) 'vp2         =  ', vp2,     ';'
  write( 9, * ) 'vs0         =  ', vs0,     ';'
  write( 9, * ) 'vs1         =  ', vs1,     ';'
  write( 9, * ) 'vs2         =  ', vs2,     ';'
  write( 9, * ) 'vrup        =  ', vrup,    ';'
  write( 9, * ) 'svtol       =  ', svtol,   ';'
  write( 9, * ) 'rexpand     =  ', rexpand, ';'
  write( 9, * ) 'courant     =  ', courant, ';'
  write( 9, * ) 'affine      = [', affine,    '];'
  write( 9, * ) 'viscosity   = [', viscosity, '];'
  write( 9, * ) 'upvector    = [', upvector,  '];'
  write( 9, * ) 'symmetry    = [', symmetry,  '];'
  write( 9, * ) 'xcenter     = [', xcenter,   '];'
  write( 9, * ) 'xhypo       = [', xhypo,     '];'
  write( 9, * ) 'moment1     = [', moment1,   '];'
  write( 9, * ) 'moment2     = [', moment2,   '];'
  write( 9, * ) 'nt          =  ', nt,          ';'
  write( 9, * ) 'itcheck     =  ', itcheck,     ';'
  write( 9, * ) 'npml        =  ', npml,        ';'
  write( 9, * ) 'faultnormal =  ', faultnormal, ';'
  write( 9, * ) 'nn          = [', nn,            '];'
  write( 9, * ) 'ihypo       = [', ihypo - nnoff, '];'
  write( 9, * ) 'n1expand    = [', n1expand,      '];'
  write( 9, * ) 'n2expand    = [', n2expand,      '];'
  write( 9, * ) 'bc1         = [', bc1,           '];'
  write( 9, * ) 'bc2         = [', bc2,           '];'
  write( 9, * ) 'np          = [', np,            '];'
  write( 9, * ) 'grid        = ''', trim( grid ),  ''';'
  write( 9, * ) 'rfunc       = ''', trim( rfunc ), ''';'
  write( 9, * ) 'tfunc       = ''', trim( tfunc ), ''';'
  write( 9, * ) 'endian      = ''', endian, ''';'
end if

if ( nout > nz ) stop 'too many output zones, make nz bigger'

doiz0: do iz = 1, nout

  ! Properties
  nc = 1
  fault = .false.
  cell = .false.
  select case( fieldout(iz) )
  case( 'x'    ); nc = 3
  case( 'a'    ); nc = 3
  case( 'v'    ); nc = 3
  case( 'u'    ); nc = 3
  case( 'w'    ); nc = 6; cell = .true.
  case( 'wm'   ); cell = .true.
  case( 'mu'   ); cell = .true.
  case( 'lam'  ); cell = .true.
  case( 'y'    ); cell = .true.
  case( 't0'   ); fault = .true.; nc = 3
  case( 't3'   ); fault = .true.; nc = 3
  case( 'mus'  ); fault = .true.
  case( 'mud'  ); fault = .true.
  case( 'dc'   ); fault = .true.
  case( 'co'   ); fault = .true.
  case( 'sv'   ); fault = .true.
  case( 'sl'   ); fault = .true.
  case( 'trup' ); fault = .true.
  case( 'tarr' ); fault = .true.
  case( 'tn'   ); fault = .true.
  case( 'ts'   ); fault = .true.
  end select
  
  ! Interval 
  if ( ditout(iz) < 1 ) ditout(iz) = nt + ditout(iz) + 1
 
  ! Zone
  i1 = i1out(iz,:)
  i2 = i2out(iz,:)
  call zone( i1, i2, nn, nnoff, ihypo, ifn )
  if ( cell ) i2 = i2 - 1
  if ( fault ) then
    if ( faultnormal /= 0 ) then
      i = abs( faultnormal )
      i1(i) = ihypo(i)
      i2(i) = ihypo(i)
    else
      ditout(iz) = nt + 1
    end if
  end if
  if ( any( i2 < i1 ) ) stop 'output indices'
  i1out(iz,:) = i1
  i2out(iz,:) = i2
 
  ! Metadata
  if ( master ) then
    write( field, * ) '''', trim( fieldout(iz) ), ''''
    write( 9, '(a,i3,a,i1,a,7i7,a)' ) ' out{', iz, '}    = { ', nc, field, &
      ditout(iz), i1 - nnoff, i2 - nnoff, ' };'
  end if
 
  ! Split collective i/o
  i1 = max( i1, i1node )
  i2 = min( i2, i2node )
  if ( any( i2 < i1 ) ) ditout(iz) = nt + 1
  call iosplit( iz, nout, ditout(iz) )
 
end do doiz0
 
! Wall time
if ( master ) then
  close( 9 )
  call system_clock( twall2 )
end if

end subroutine

!------------------------------------------------------------------------------!
subroutine output( pass )
character, intent(in) :: pass
character :: onpass
real :: dtwall, tarrmax
real, save :: amax, vmax, umax, wmax, svmax, slmax
integer, save :: amaxi(3), vmaxi(3), umaxi(3), wmaxi(3), svmaxi(3), slmaxi(3)
integer :: i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, iz
logical :: fault, test, static

if ( master ) then
  open( 9, file='log', position='append' )
  write( 9, * ) 'Output pass: ', pass
  close( 9 )
end if

! Magnitudes
select case( pass )
case( 'w' )
  s1 = sqrt( sum( u * u, 4 ) )
  s2 = sqrt( sum( w1 * w1, 4 ) + 2. * sum( w2 * w2, 4 ) )
  umaxi = maxloc( s1 )
  wmaxi = maxloc( s2 )
  umax = s1(umaxi(1),umaxi(2),umaxi(3))
  wmax = s2(wmaxi(1),wmaxi(2),wmaxi(3))
  call pmaxloc( umax, umaxi, nnoff )
  call pmaxloc( wmax, wmaxi, nnoff )
  if ( master .and. umax > dx / 10. ) then
    open( 9, file='log', position='append' )
    write( 9, * ) 'warning: u !<< dx'
    close( 9 )
  end if
case( 'a' )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  amaxi = maxloc( s1 )
  vmaxi = maxloc( s2 )
  amax = s1(amaxi(1),amaxi(2),amaxi(3))
  vmax = s2(vmaxi(1),vmaxi(2),vmaxi(3))
  call pmaxloc( amax, amaxi, nnoff )
  call pmaxloc( vmax, vmaxi, nnoff )
  if ( faultnormal /= 0 ) then
    svmaxi = maxloc( sv )
    slmaxi = maxloc( sl )
    svmax = sv(svmaxi(1),svmaxi(2),svmaxi(3))
    slmax = sl(slmaxi(1),slmaxi(2),slmaxi(3))
    i = abs( faultnormal )
    svmaxi(i) = ihypo(i)
    slmaxi(i) = ihypo(i)
    call pmaxloc( svmax, svmaxi, nnoff )
    call pmaxloc( slmax, slmaxi, nnoff )
  end if
case default; stop 'output pass'
end select

doiz: do iz = 1, nout !--------------------------------------------------------!

if ( modulo( it, ditout(iz) ) /= 0 ) cycle doiz

! Properties
nc = 1
fault= .false.
static = .false.
onpass = 'a'
select case( fieldout(iz) )
case( 'x'    ); nc = 3; static = .true.
case( 'a'    ); nc = 3
case( 'v'    ); nc = 3
case( 'u'    ); nc = 3; onpass = 'w'
case( 'w'    ); nc = 6; onpass = 'w'
case( 'mr'   ); static = .true.
case( 'mu'   ); static = .true.
case( 'lam'  ); static = .true.
case( 'y'    ); static = .true.
case( 'um'   ); onpass = 'w'
case( 'wm'   ); onpass = 'w'
case( 't0'   ); fault = .true.; nc = 3
case( 't3'   ); fault = .true.; nc = 3
case( 'mus'  ); fault = .true.; static = .true.
case( 'mud'  ); fault = .true.; static = .true.
case( 'dc'   ); fault = .true.; static = .true.
case( 'co'   ); fault = .true.; static = .true.
case( 'sv'   ); fault = .true.
case( 'sl'   ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case( 'tn'   ); fault = .true.
case( 'ts'   ); fault = .true.
end select

! Select pass
if ( pass /= onpass ) cycle doiz

! X is static, only write once
if ( static ) ditout(iz) = nt + 1

! Indices
i1 = i1out(iz,:)
i2 = i2out(iz,:)
i1l = max( i1, i1node )
i2l = min( i2, i2node )
if ( fault .and. faultnormal /= 0 ) then
  i = abs( faultnormal )
  i1(i) = 1
  i2(i) = 1
  i1l(i) = 1
  i2l(i) = 1
end if

! Binary output
do i = 1, nc
  write( str, '(i2.2,a,a,i1,i6.6)' ) iz, '/', trim( fieldout(iz) ), i, it
  select case( fieldout(iz) )
  case( 'x'    ); call vectorio( 'w', str, x,  i,   i1, i2, i1l, i2l, iz )
  case( 'a'    ); call vectorio( 'w', str, w1, i,   i1, i2, i1l, i2l, iz )
  case( 'v'    ); call vectorio( 'w', str, v,  i,   i1, i2, i1l, i2l, iz )
  case( 'u'    ); call vectorio( 'w', str, u,  i,   i1, i2, i1l, i2l, iz )
  case( 'w'    );
    if ( i < 4 )  call vectorio( 'w', str, w1, i,   i1, i2, i1l, i2l, iz )
    if ( i > 3 )  call vectorio( 'w', str, w2, i-3, i1, i2, i1l, i2l, iz )
  case( 'am'   ); call scalario( 'w', str, s1,      i1, i2, i1l, i2l, iz )
  case( 'vm'   ); call scalario( 'w', str, s2,      i1, i2, i1l, i2l, iz )
  case( 'um'   ); call scalario( 'w', str, s1,      i1, i2, i1l, i2l, iz )
  case( 'wm'   ); call scalario( 'w', str, s2,      i1, i2, i1l, i2l, iz )
  case( 'mr'   ); call scalario( 'w', str, mr,      i1, i2, i1l, i2l, iz )
  case( 'mu'   ); call scalario( 'w', str, mu,      i1, i2, i1l, i2l, iz )
  case( 'lam'  ); call scalario( 'w', str, lam,     i1, i2, i1l, i2l, iz )
  case( 'y'    ); call scalario( 'w', str, y,       i1, i2, i1l, i2l, iz )
  case( 't0'   ); call vectorio( 'w', str, t0, i,   i1, i2, i1l, i2l, iz )
  case( 't1'   ); call vectorio( 'w', str, t1, i,   i1, i2, i1l, i2l, iz )
  case( 't2'   ); call vectorio( 'w', str, t2, i,   i1, i2, i1l, i2l, iz )
  case( 't3'   ); call vectorio( 'w', str, t3, i,   i1, i2, i1l, i2l, iz )
  case( 'mus'  ); call scalario( 'w', str, mus,     i1, i2, i1l, i2l, iz )
  case( 'mud'  ); call scalario( 'w', str, mud,     i1, i2, i1l, i2l, iz )
  case( 'dc'   ); call scalario( 'w', str, dc,      i1, i2, i1l, i2l, iz )
  case( 'co'   ); call scalario( 'w', str, co,      i1, i2, i1l, i2l, iz )
  case( 'sv'   ); call scalario( 'w', str, sv,      i1, i2, i1l, i2l, iz )
  case( 'sl'   ); call scalario( 'w', str, sl,      i1, i2, i1l, i2l, iz )
  case( 'trup' ); call scalario( 'w', str, trup,    i1, i2, i1l, i2l, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,    i1, i2, i1l, i2l, iz )
  case( 'tn'   ); call scalario( 'w', str, tn,      i1, i2, i1l, i2l, iz )
  case( 'ts'   ); call scalario( 'w', str, ts,      i1, i2, i1l, i2l, iz )
  case default; stop 'output fieldout'
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 'w' ) return

! Check for stop file
inquire( file='stop', exist=test )
if ( test ) then
  itcheck = it
  nt = it
end if

! Metadata
if ( master ) then
  twall1 = twall2
  call system_clock( twall2 )
  dtwall = real( twall2 - twall1 ) / real( twall_rate )
  if ( dtwall < 0. ) &
    dtwall = real( twall2 - twall1 + twall_max ) / real( twall_rate )
  open(  9, file='currentstep.m', status='replace' )
  write( 9, * ) 'it =  ', it, ';'
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'stats/st', it, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'it     =  ', it,     ';'
  write( 9, * ) 't      =  ', t,      ';'
  write( 9, * ) 'dt     =  ', dt,     ';'
  write( 9, * ) 'dtwall =  ', dtwall, ';'
  write( 9, * ) 'amax   =  ', amax,   ';'
  write( 9, * ) 'vmax   =  ', vmax,   ';'
  write( 9, * ) 'umax   =  ', umax,   ';'
  write( 9, * ) 'wmax   =  ', wmax,   ';'
  write( 9, * ) 'svmax  =  ', svmax,  ';'
  write( 9, * ) 'slmax  =  ', slmax,  ';'
  write( 9, * ) 'amaxi  = [', amaxi - nnoff,  '];'
  write( 9, * ) 'vmaxi  = [', vmaxi - nnoff,  '];'
  write( 9, * ) 'umaxi  = [', umaxi - nnoff,  '];'
  write( 9, * ) 'wmaxi  = [', wmaxi - nnoff,  '];'
  write( 9, * ) 'svmaxi = [', svmaxi - nnoff, '];'
  write( 9, * ) 'slmaxi = [', slmaxi - nnoff, '];'
  close( 9 )
end if
if ( faultnormal /= 0 .and. it == nt - 1 ) then
  i1 = maxloc( tarr )
  j = i1(1)
  k = i1(2)
  l = i1(3)
  tarrmax = tarr(j,k,l)
  call pmaxloc( tarrmax, i1, nnoff )
  if ( master ) then
    i2 = ihypo
    i = abs( faultnormal )
    i2(i) = 1
    j = i2(1)
    k = i2(2)
    l = i2(3)
    open(  9, file='arrest.m', status='replace' )
    write( 9, * ) 'tarrmaxi = [', i1 - nnoff, '];'
    write( 9, * ) 'tarrmax  = ', tarrmax, ';'
    write( 9, * ) 'tarrhypo = ', tarr(j,k,l), ';'
    close( 9 )
  end if
end if

end subroutine

end module

