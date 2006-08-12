! Ouput initialize
module m_output_init
implicit none
contains

subroutine output_init
use m_globals
use m_collectiveio
use m_tictoc
use m_zone
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
  write( 9, * ) 'origin      =  ', origin,      ';'
  write( 9, * ) 'fixhypo     =  ', fixhypo,     ';'
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
        i = abs( faultnormal )
        f1 = sum( t1 * t1, 4 )
        i1 = minloc( f1 )
        rout = f1(i1(1),i1(2),i1(3))
        i1(i) = ihypo(i)
        t1 = 0.
        f1 = 0.
        call pminloc( rout, i1, nnoff, i )
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
      call pminloc( rout, i1, nnoff, 0 )
      w1 = 0.
      s1 = 0.
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

end module

