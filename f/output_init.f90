! Ouput initialize
module m_output_init
implicit none
contains

subroutine output_init
use m_globals
use m_collectiveio
use m_zone
real :: courant, rout
integer :: i1(3), i2(3), i, j, k, l, j1, k1, l1, j2, k2, l2, nc, iz
character :: endian
character(7) :: field
logical :: fault, dofault, test, cell

i = 0
if ( master ) then
  i = 1
  print *, 'Output initialize'
  inquire( file='currentstep.m', exist=test )
  if ( test .and. it == 1 ) then
    print *, 'error: previous output found'
    stop
  end if
end if

! Diagnostic
if ( debug /= 0 ) then
  write( str, '(a,i6.6,a)' ) 'debug/db', ip, '.m'
  open(  1, file=str, status='replace' )
  write( 1, * ) 'ifn         =  ', ifn,         ';'
  write( 1, * ) 'nin         =  ', nin,         ';'
  write( 1, * ) 'nout        =  ', nout,        ';'
  write( 1, * ) 'nlock       =  ', nlock,       ';'
  write( 1, * ) 'noper       =  ', noper,       ';'
  write( 1, * ) 'master      =  ', i,           ';'
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
  open(  1, file='meta.m', status='replace' )
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
end if

if ( nout > nz ) then
  print *, 'too many output zones, make nz bigger', nout, nz
  stop
end if

! Test for fault
dofault = .false.
if ( faultnormal /= 0 ) then
  i = abs( faultnormal )
  if ( ihypo(i) >= i1node(i) .and. ihypo(i) <= i2node(i) ) dofault = .true.
end if

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
  case( 'pv'   );
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
  case( 'psv'  ); fault = .true.
  case( 'trup' ); fault = .true.
  case( 'tarr' ); fault = .true.
  case default
    print *, 'unknown output field: ', fieldout(iz)
    stop
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
          t2(:,:,:,i) = xout(iz,i) - x(j1:j2,k1:k2,l1:l2,i)
        end do
        i1 = i1node
        i2 = i2node
        i1(i) = 1
        i2(i) = 1
        j1 = i1(1); j2 = i2(1)
        k1 = i1(2); k2 = i2(2)
        l1 = i1(3); l2 = i2(3)
        t1 = rmax
        do i = 1, 3
          t1(j1:j2,k1:k2,l1:l2,i) = t2(j1:j2,k1:k2,l1:l2,i)
        end do
        i = abs( faultnormal )
        f1 = sum( t1 * t1, 4 )
        call pminloc( rout, i1, f1, nn, nnoff, i )
      end if
    else
      w1 = rmax
      if ( cell ) then
        i1 = i1node
        i2 = i2node - 1
        j1 = i1(1); j2 = i2(1)
        k1 = i1(2); k2 = i2(2)
        l1 = i1(3); l2 = i2(3)
        forall( j=j1:j2, k=k1:k2, l=l1:l2, i=1:3 )
          w1(j,k,l,i) = xout(iz,i) - 0.125 * &
            ( x(j,k,l,i) + x(j+1,k+1,l+1,i) &
            + x(j+1,k,l,i) + x(j,k+1,l+1,i) &
            + x(j,k+1,l,i) + x(j+1,k,l+1,i) &
            + x(j,k,l+1,i) + x(j+1,k+1,l,i) )
        end forall
      else
        i1 = i1node
        i2 = i2node
        j1 = i1(1); j2 = i2(1)
        k1 = i1(2); k2 = i2(2)
        l1 = i1(3); l2 = i2(3)
        do i = 1, 3
          w1(j1:j2,k1:k2,l1:l2,i) = xout(iz,i) - x(j1:j2,k1:k2,l1:l2,i)
        end do
      end if
      s1 = sum( w1 * w1, 4 )
      call pminloc( rout, i1, s1, nn, nnoff, 0 )
    end if
    i2 = i1
    if ( rout > dx * dx ) ditout(iz) = nt + 1
  end select

  ! Interval 
  if ( ditout(iz) < 0 ) ditout(iz) = nt + ditout(iz) + 1
  if ( fault .and. faultnormal == 0 ) ditout(iz) = nt + 1

  ! Metadata
  if ( master ) then
    write( field, * ) '''', trim( fieldout(iz) ), ''''
    write( 1, '(a,i3,a,i1,a,7i7,a)' ) ' out{', iz, '}    = { ', nc, field, ditout(iz), i1 - nnoff, i2 - nnoff, ' };'
  end if
 
  if ( any( i2 < i1 ) ) then
    print *, 'bad output indices', i1, i2
    stop
  end if
  i1out(iz,:) = i1
  i2out(iz,:) = i2
 
  ! Split collective i/o
  i1 = max( i1, i1node )
  i2 = min( i2, i2node )
  if ( any( i2 < i1 ) ) ditout(iz) = nt + 1
  call splitio( iz, nout, ditout(iz) )
 
end do doiz0

! For step 1, pass 1
w1 = 0.
s1 = 0.
t1 = 0.
t2 = 0.
f1 = 0.
f2 = 0.
 
! Wall time
if ( master ) then
  close( 1 )
end if

end subroutine

end module

