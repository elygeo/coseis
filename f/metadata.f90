! Write metadata
module m_metadata
implicit none
contains

subroutine metadata
use m_globals
use m_outprops
real :: courant
integer :: i1(4), i2(4), i, nc, iz, onpass
character :: endian
character(7) :: field
logical :: fault, cell

if ( master ) write( 0, * ) 'Write metadata'

! Debug info
if ( debug /= 0 ) then
  i = 0
  if ( master ) i = 1
  write( str, '(a,i6.6,a)' ) 'debug/db', ip, '.m'
  open( 1, file=str, status='replace' )
  write( 1, '(a)'             ) '% SORD debug info'
  write( 1, '(a,i8,a)'        ) '  debug  =  ', debug,  ' ;'
  write( 1, '(a,i8,a)'        ) '  master =  ', i,      ' ;'
  write( 1, '(a,i8,a)'        ) '  ip     =  ', ip,     ' ;'
  write( 1, '(a,i8,a)'        ) '  ifn    =  ', ifn,    ' ;'
  write( 1, '(a,i8,a)'        ) '  nin    =  ', nin,    ' ;'
  write( 1, '(a,i8,a)'        ) '  nout   =  ', nout,   ' ;'
  write( 1, '(a,i8,a)'        ) '  nlock  =  ', nlock,  ' ;'
  write( 1, '(a,3i8,a)'       ) '  ip3    = [', ip3,    ' ];'
  write( 1, '(a,3i8,a)'       ) '  np     = [', np,     ' ];'
  write( 1, '(a,3i8,a)'       ) '  nhalo  = [', nhalo,  ' ];'
  write( 1, '(a,3i8,a)'       ) '  ihypo  = [', ihypo,  ' ];'
  write( 1, '(a,3i8,a)'       ) '  nm     = [', nm,     ' ];'
  write( 1, '(a,3i8,a)'       ) '  nnoff  = [', nnoff,  ' ];'
  write( 1, '(a,3i8,a,3i8,a)' ) '  i1pml  = [', i1pml,  ' ]; i2pml  = [', i2pml,  ' ];'
  write( 1, '(a,3i8,a,3i8,a)' ) '  i1core = [', i1core, ' ]; i2core = [', i2core, ' ];'
  write( 1, '(a,3i8,a,3i8,a)' ) '  i1node = [', i1node, ' ]; i2node = [', i2node, ' ];'
  write( 1, '(a,3i8,a,3i8,a)' ) '  i1cell = [', i1cell, ' ]; i2cell = [', i2cell, ' ];'
  write( 1, '(a,3i8,a,3i8,a)' ) '  ibc1   = [', ibc1,   ' ]; ibc2   = [', ibc2,   ' ];'
  do iz = 1, nin
    select case( intype(iz) )
    case( 'z' ); write( 1, '(2x,a,a,g15.7,a,6i8,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'zone'", i1in(iz,:), i2in(iz,:), ' };'
    case( 'c' ); write( 1, '(2x,a,a,g15.7,a,6g15.7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'cube'", x1in(iz,:), x2in(iz,:), ' };'
    end select
  end do
  do iz = 1, nlock
    write( 1, '(a,9i7,a)' ) &
      '  lock        = [', ilock(iz,:), i1lock(iz,:), i2lock(iz,:), ' ];'
  end do
  close( 1 )
end if

! Metadata
if ( .not. master ) return
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
courant = dt * vp2 * sqrt( 3. ) / abs( dx )
open( 1, file='meta.m', status='replace' )
write( 1, '(a)' ) '% SORD metadata'
write( 1, '(a,g15.7,a)'  ) '  dx          =  ', dx,             ' ;'
write( 1, '(a,g15.7,a)'  ) '  rmax        =  ', rmax,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  dt          =  ', dt,             ' ;'
write( 1, '(a,g15.7,a)'  ) '  rho0        =  ', rho0,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  rho1        =  ', rho1,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  rho2        =  ', rho2,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  vp0         =  ', vp0,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  vp1         =  ', vp1,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  vp2         =  ', vp2,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  vs0         =  ', vs0,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  vs1         =  ', vs1,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  vs2         =  ', vs2,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  gam0        =  ', gam0,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  gam1        =  ', gam1,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  gam2        =  ', gam2,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  vdamp       =  ', vdamp,          ' ;'
write( 1, '(a,g15.7,a)'  ) '  rexpand     =  ', rexpand,        ' ;'
write( 1, '(a,g15.7,a)'  ) '  courant     =  ', courant,        ' ;'
write( 1, '(a,2g15.7,a)' ) '  hourglass   = [', hourglass,      ' ];'
write( 1, '(a,3g15.7,a)' ) '  xcenter     = [', xcenter,        ' ];'
write( 1, '(a,3g15.7,a)' ) '  xhypo       = [', xhypo,          ' ];'
write( 1, '(a,3g15.7)'   ) '  affine      = [', affine(1:3)
write( 1, '(a,3g15.7)'   ) '                 ', affine(4:6)
write( 1, '(a,3g15.7,a)' ) '                 ', affine(7:9),    ' ];'
write( 1, '(a,i8,a)'     ) '  nt          =  ', nt,             ' ;'
write( 1, '(a,i8,a)'     ) '  itcheck     =  ', itcheck,        ' ;'
write( 1, '(a,i8,a)'     ) '  fixhypo     =  ', fixhypo,        ' ;'
write( 1, '(a,i8,a)'     ) '  npml        =  ', npml,           ' ;'
write( 1, '(a,i8,a)'     ) '  oplevel     =  ', oplevel,        ' ;'
write( 1, '(a,i8,a)'     ) '  mpin        =  ', mpin,           ' ;'
write( 1, '(a,i8,a)'     ) '  mpout       =  ', mpout,          ' ;'
write( 1, '(a,3i8,a)'    ) '  nn          = [', nn,             ' ];'
write( 1, '(a,3i8,a)'    ) '  ihypo       = [', ihypo + nnoff,  ' ];'
write( 1, '(a,3i8,a)'    ) '  n1expand    = [', n1expand,       ' ];'
write( 1, '(a,3i8,a)'    ) '  n2expand    = [', n2expand,       ' ];'
write( 1, '(a,3i8,a)'    ) '  bc1         = [', bc1,            ' ];'
write( 1, '(a,3i8,a)'    ) '  bc2         = [', bc2,            ' ];'
write( 1, '(3a)'         ) '  grid        = ''', trim( grid ),  ''' ;'
write( 1, '(3a)'         ) '  endian      = ''', endian,        ''' ;'
write( 1, '(a,g15.7,a)'  ) '  rsource     =  ', rsource,        ' ;'
if ( rsource > 0. ) then
write( 1, '(a,g15.7,a)'  ) '  tsource     =  ', tsource,        ' ;'
write( 1, '(a,3g15.7,a)' ) '  moment1     = [', moment1,        ' ];'
write( 1, '(a,3g15.7,a)' ) '  moment2     = [', moment2,        ' ];'
write( 1, '(3a)'         ) '  rfunc       = ''', trim( rfunc ), ''' ;'
write( 1, '(3a)'         ) '  tfunc       = ''', trim( tfunc ), ''' ;'
end if
write( 1, '(a,i8,a)'     ) '  faultnormal =  ', faultnormal,    ' ;'
if ( faultnormal /= 0 ) then
write( 1, '(a,3g15.7,a)' ) '  slipvector  = [', slipvector,     ' ];'
write( 1, '(a,g15.7,a)'  ) '  vrup        =  ', vrup,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  rcrit       =  ', rcrit,          ' ;'
write( 1, '(a,g15.7,a)'  ) '  trelax      =  ', trelax,         ' ;'
write( 1, '(a,g15.7,a)'  ) '  svtol       =  ', svtol,          ' ;'
write( 1, '(a,g15.7,a)'  ) '  mus0        =  ', mus0,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  mud0        =  ', mud0,           ' ;'
write( 1, '(a,g15.7,a)'  ) '  dc0         =  ', dc0,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  tn0         =  ', tn0,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  ts0         =  ', ts0,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  ess         =  ', ess,            ' ;'
write( 1, '(a,g15.7,a)'  ) '  lc          =  ', lc,             ' ;'
write( 1, '(a,g15.7,a)'  ) '  rctest      =  ', rctest,         ' ;'
end if
write( 1, '(a)' )          '  dirfmt      = ''out/%02d'' ;'
do iz = 1, nout
  i = ditout(iz)
  i1 = i1out(iz,:)
  i2 = i2out(iz,:)
  i1(1:3) = i1(1:3) + nnoff
  i2(1:3) = i2(1:3) + nnoff
  call outprops( fieldout(iz), nc, onpass, fault, cell )
  write( field, * ) '''', trim( fieldout(iz) ), ''''
  write( 1, '(a,i3.3,a,i1,a,9i7,a)' ) '  out{', iz, '} = { ', nc, field, i, i1, i2, ' };'
end do
close( 1 )

if ( mpout == 0 ) then
  open( 1, file='out/hdr', status='replace' )
  write( 1, '(3i8)' ) nn
  write( 1, '(3i8)' ) np
  do iz = 1, nout
    i1 = i1out(iz,:)
    i2 = i2out(iz,:)
    i1(1:3) = i1(1:3) + nnoff
    i2(1:3) = i2(1:3) + nnoff
    call outprops( fieldout(iz), nc, onpass, fault, cell )
    do i = 1, nc
      write( 1, '(9i7,a,i2.2,a,i1)' ) ditout(iz), i1, i2, '  ', iz, trim(fieldout(iz)), i
    end do
  end do
  close( 1 )
end if

end subroutine

end module

