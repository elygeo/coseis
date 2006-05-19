! Write output
module output_m
use globals_m
use collectiveio_m
use tictoc_m
contains

! Ouput initialize
subroutine output_init
use zone_m
implicit none
real :: courant, rout
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nc, iz
character :: endian
character(7) :: field
logical :: fault, dofault, test, cell

i = 0
if ( master ) then
  i = 1
  call toc( 'Output initialize' )
  inquire( file='currentstep.m', exist=test )
  if ( test .and. it == 1 ) stop 'error: previous output found'
end if

! Fault communicator
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) then
    dofault = .true.
  else
    i = 0
  end if
  call splitfault( i )
end if

! Diagnostic
if ( debug /= 0 ) then
  write( str, '(a,i6.6,a)' ) 'debug/db', ip, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'ifn         =  ', ifn,         ';'
  write( 9, * ) 'nin         =  ', nin,         ';'
  write( 9, * ) 'nout        =  ', nout,        ';'
  write( 9, * ) 'nlock       =  ', nlock,       ';'
  write( 9, * ) 'noper       =  ', noper,       ';'
  write( 9, * ) 'master      =  ', i,           ';'
  write( 9, * ) 'ip          =  ', ip,          ';'
  write( 9, * ) 'ip3         = [', ip3,        '];'
  write( 9, * ) 'np          = [', np,         '];'
  write( 9, * ) 'ihypo       = [', ihypo,      '];'
  write( 9, * ) 'nm          = [', nm,         '];'
  write( 9, * ) 'nnoff       = [', nnoff,      '];'
  write( 9, * ) 'i1oper      = [', i1oper(1,:), ';', i1oper(2,:), '];'
  write( 9, * ) 'i1node      = [', i1node,     '];'
  write( 9, * ) 'i1cell      = [', i1cell,     '];'
  write( 9, * ) 'i1pml       = [', i1pml,      '];'
  write( 9, * ) 'i2oper      = [', i2oper(1,:), ';', i2oper(2,:), '];'
  write( 9, * ) 'i2node      = [', i2node,     '];'
  write( 9, * ) 'i2cell      = [', i2cell,     '];'
  write( 9, * ) 'i2pml       = [', i2pml,      '];'
  write( 9, * ) 'ibc1        = [', ibc1,       '];'
  write( 9, * ) 'ibc2        = [', ibc2,       '];'
  write( 9, * ) 'oper        = ''', oper,     ''';'
  do iz = 1, nin
    select case( intype(iz) )
    case( 'z' ); write( 9, '(a,a,g15.7,a,6i7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'zone'", i1in(iz,:), i2in(iz,:), ' };'
    case( 'c' ); write( 9, '(a,a,g15.7,a,6g15.7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'cube'", x1in(iz,:), x2in(iz,:), ' };'
    end select
  end do
  do iz = 1, nlock
    write( 9, '(a,9i7,a)' ) &
      'lock        = [', ilock(iz,:), i1lock(iz,:), i2lock(iz,:), '];'
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
  write( 9, '(a,10g15.7,a)' ) ' affine      = [', affine, '];'
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
  case( 'x'    ); ditout(iz) = 0; nc = 3
  case( 'mr'   ); ditout(iz) = 0
  case( 'mu'   ); ditout(iz) = 0; cell = .true.
  case( 'lam'  ); ditout(iz) = 0; cell = .true.
  case( 'y'    ); ditout(iz) = 0; cell = .true.
  case( 'a'    ); nc = 3
  case( 'v'    ); nc = 3
  case( 'u'    ); nc = 3
  case( 'w'    ); nc = 6; cell = .true.
  case( 'am'   );
  case( 'vm'   );
  case( 'um'   );
  case( 'wm'   ); cell = .true.
  case( 'nhat' ); fault = .true.; ditout(iz) = 0; nc = 3
  case( 't0'   ); fault = .true.; ditout(iz) = 0; nc = 3
  case( 'mus'  ); fault = .true.; ditout(iz) = 0
  case( 'mud'  ); fault = .true.; ditout(iz) = 0
  case( 'dc'   ); fault = .true.; ditout(iz) = 0
  case( 'co'   ); fault = .true.; ditout(iz) = 0
  case( 'sa'   ); fault = .true.; nc = 3
  case( 'sv'   ); fault = .true.; nc = 3
  case( 'su'   ); fault = .true.; nc = 3
  case( 'ts'   ); fault = .true.; nc = 3
  case( 't'    ); fault = .true.; nc = 3
  case( 'sam'  ); fault = .true.
  case( 'svm'  ); fault = .true.
  case( 'sum'  ); fault = .true.
  case( 'tnm'  ); fault = .true.
  case( 'tsm'  ); fault = .true.
  case( 'sl'   ); fault = .true.
  case( 'f'    ); fault = .true.
  case( 'svp'  ); fault = .true.
  case( 'trup' ); fault = .true.
  case( 'tarr' ); fault = .true.
  case default
    if ( master ) call toc( 'unknown output field: ' // fieldout(iz) )
    stop 'output field, see log'
  end select

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
          t1(:,:,:,i) = xout(iz,i) - x(j1:j2,k1:k2,l1:l2,i)
        end do
        f1 = sum( t1 * t1, 4 )
        i1 = minloc( f1 )
        rout = f1(i1(1),i1(2),i1(3))
        i1(i) = ihypo(i)
        t1 = 0.
        f1 = 0.
        call pminloc( rout, i1, nnoff, fault )
      end if
    else
      if ( cell ) then
        i1 = i1node
        i2 = i2node - 1
        j1 = i1(1); j2 = i2(1)
        k1 = i1(2); k2 = i2(2)
        l1 = i1(3); l2 = i2(3)
        w1 = rmax
        forall( j=j1:j2, k=k1:k2, l=l1:l2, i=1:3 )
          w1(j,k,l,i) = xout(iz,i) - 0.125 * &
            ( x(j,k,l,i) + x(j+1,k+1,l+1,i) &
            + x(j+1,k,l,i) + x(j,k+1,l+1,i) &
            + x(j,k+1,l,i) + x(j+1,k,l+1,i) &
            + x(j,k,l+1,i) + x(j+1,k+1,l,i) )
        end forall
      else
        do i = 1, 3
          w1(:,:,:,i) = xout(iz,i) - x(:,:,:,i)
        end do
      end if
      s1 = sum( w1 * w1, 4 )
      i1 = minloc( s1 )
      rout = s1(i1(1),i1(2),i1(3))
      call pminloc( rout, i1, nnoff, fault )
      w1 = 0.
      s1 = 0.
    end if
    i2 = i1
    if ( rout > 2. * dx ) ditout(iz) = nt + 1
  end select

  ! Interval 
  if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
  if ( fault .and. faultnormal == 0 ) ditout(iz) = nt + 1

  ! Metadata
  if ( master ) then
    write( field, * ) '''', trim( fieldout(iz) ), ''''
    write( 9, '(a,i3,a,i1,a,7i7,a)' ) ' out{', iz, '}    = { ', nc, field, ditout(iz), i1 - nnoff, i2 - nnoff, ' };'
  end if
 
  if ( any( i2 < i1 ) ) stop 'bad output indices'
  i1out(iz,:) = i1
  i2out(iz,:) = i2
 
  ! Split collective i/o
  i1 = max( i1, i1node )
  i2 = min( i2, i2node )
  if ( any( i2 < i1 ) ) ditout(iz) = nt + 1
  call splitio( iz, nout, ditout(iz) )
 
end do doiz0

! For step 1, pass 1
t1 = 0.
t2 = 0.
f1 = 0.
f2 = 0.
 
! Wall time
if ( master ) then
  close( 9 )
end if

end subroutine

!------------------------------------------------------------------------------!
subroutine output( pass )
implicit none
integer, intent(in) :: pass
real, save :: amax, vmax, umax, wmax, &
  samax, svmax, sumax, tnmax, tsmax, slmax, tarrmax
integer, save, dimension(3) :: amaxi, vmaxi, umaxi, wmaxi, &
  samaxi, svmaxi, sumaxi, tnmaxi, tsmaxi, slmaxi, tarrmaxi
integer :: onpass, i1(3), i2(3), i1l(3), i2l(3), i, j, k, l, nc, ic, ir, iz
logical :: fault, dofault, test

if ( master ) call toc( 'Output' )

! Fault
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
  umaxi = maxloc( s1 )
  wmaxi = maxloc( s2 )
  umax = s1(umaxi(1),umaxi(2),umaxi(3))
  wmax = s2(wmaxi(1),wmaxi(2),wmaxi(3))
  call pmaxloc( umax, umaxi, nnoff, fault )
  call pmaxloc( wmax, wmaxi, nnoff, fault )
  if ( master .and. umax > dx / 10. ) call toc( 'warning: u !<< dx' )
  if ( dofault ) then
    svmaxi = maxloc( f1 )
    sumaxi = maxloc( f2 )
    svmax = f1(svmaxi(1),svmaxi(2),svmaxi(3))
    sumax = f2(sumaxi(1),sumaxi(2),sumaxi(3))
    svmaxi(i) = ihypo(i)
    sumaxi(i) = ihypo(i)
    call pmaxloc( svmax, svmaxi, nnoff, fault )
    call pmaxloc( sumax, sumaxi, nnoff, fault )
  end if
case( 2 )
  s1 = sqrt( sum( w1 * w1, 4 ) )
  s2 = sqrt( sum( v * v, 4 ) )
  amaxi = maxloc( s1 )
  vmaxi = maxloc( s2 )
  amax = s1(amaxi(1),amaxi(2),amaxi(3))
  vmax = s2(vmaxi(1),vmaxi(2),vmaxi(3))
  call pmaxloc( amax, amaxi, nnoff, fault )
  call pmaxloc( vmax, vmaxi, nnoff, fault )
  if ( dofault ) then
    samaxi = maxloc( f1 )
    tnmaxi = maxloc( abs( tn ) )
    tsmaxi = maxloc( ts )
    slmaxi = maxloc( sl )
    tarrmaxi = maxloc( tarr )
    samax = f1(samaxi(1),samaxi(2),samaxi(3))
    tnmax = abs( tn(tnmaxi(1),tnmaxi(2),tnmaxi(3)) )
    tsmax = ts(tsmaxi(1),tsmaxi(2),tsmaxi(3))
    slmax = sl(slmaxi(1),slmaxi(2),slmaxi(3))
    tarrmax = tarr(tarrmaxi(1),tarrmaxi(2),tarrmaxi(3))
    samaxi(i) = ihypo(i)
    tnmaxi(i) = ihypo(i)
    tsmaxi(i) = ihypo(i)
    slmaxi(i) = ihypo(i)
    tarrmaxi(i) = ihypo(i)
    call pmaxloc( samax, samaxi, nnoff, fault )
    call pmaxloc( tnmax, tnmaxi, nnoff, fault )
    call pmaxloc( tsmax, tsmaxi, nnoff, fault )
    call pmaxloc( slmax, slmaxi, nnoff, fault )
    call pmaxloc( tarrmax, tarrmaxi, nnoff, fault )
  end if
case default; stop 'output pass'
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
case( 'svp'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default; stop 'output fieldout'
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
  case( 'svp'  ); call scalario( 'w', str, svp,      ir, i1, i2, i1l, i2l, iz )
  case( 'trup' ); call scalario( 'w', str, trup,     ir, i1, i2, i1l, i2l, iz )
  case( 'tarr' ); call scalario( 'w', str, tarr,     ir, i1, i2, i1l, i2l, iz )
  case default; stop 'output fieldout'
  end select
end do

end do doiz !------------------------------------------------------------------!

! Return if not on acceleration pass
if ( pass == 1 ) return

! Check for stop file
inquire( file='stop', exist=test )
if ( test ) then
  itcheck = it
  nt = it
end if

! Metadata
if ( master ) then
  open(  9, file='currentstep.m', status='replace' )
  write( 9, * ) 'it =  ', it, ';'
  close( 9 )
  write( str, '(a,i6.6,a)' ) 'stats/st', it, '.m'
  open(  9, file=str, status='replace' )
  write( 9, * ) 'it       =  ', it,   ';'
  write( 9, * ) 't        =  ', t,    ';'
  write( 9, * ) 'dt       =  ', dt,   ';'
  write( 9, * ) 'amax     =  ', amax, ';'
  write( 9, * ) 'vmax     =  ', vmax, ';'
  write( 9, * ) 'umax     =  ', umax, ';'
  write( 9, * ) 'wmax     =  ', wmax, ';'
  write( 9, * ) 'amaxi    = [', amaxi - nnoff, '];'
  write( 9, * ) 'vmaxi    = [', vmaxi - nnoff, '];'
  write( 9, * ) 'umaxi    = [', umaxi - nnoff, '];'
  write( 9, * ) 'wmaxi    = [', wmaxi - nnoff, '];'
  if ( dofault ) then
    i = abs( faultnormal )
    i1 = ihypo
    i1(i) = 1
    j = i1(1)
    k = i1(2)
    l = i1(3)
    write( 9, * ) 'samax    =  ', samax,       ';'
    write( 9, * ) 'svmax    =  ', svmax,       ';'
    write( 9, * ) 'sumax    =  ', sumax,       ';'
    write( 9, * ) 'tnmax    =  ', tnmax,       ';'
    write( 9, * ) 'tsmax    =  ', tsmax,       ';'
    write( 9, * ) 'slmax    =  ', slmax,       ';'
    write( 9, * ) 'tarrmax  =  ', tarrmax,     ';'
    write( 9, * ) 'tarrhypo =  ', tarr(j,k,l), ';'
    write( 9, * ) 'samaxi   = [', samaxi   - nnoff, '];'
    write( 9, * ) 'svmaxi   = [', svmaxi   - nnoff, '];'
    write( 9, * ) 'sumaxi   = [', sumaxi   - nnoff, '];'
    write( 9, * ) 'tnmaxi   = [', tnmaxi   - nnoff, '];'
    write( 9, * ) 'tsmaxi   = [', tsmaxi   - nnoff, '];'
    write( 9, * ) 'slmaxi   = [', slmaxi   - nnoff, '];'
    write( 9, * ) 'tarrmaxi = [', tarrmaxi - nnoff, '];'
  end if
  close( 9 )              
end if

end subroutine

end module

