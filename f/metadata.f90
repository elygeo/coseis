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
  write( 1, '(a)' ) '% SORD debug info'
  write( 1, * ) ' master      =  ', i,           ';'
  write( 1, * ) ' ip          =  ', ip,          ';'
  write( 1, * ) ' ifn         =  ', ifn,         ';'
  write( 1, * ) ' nin         =  ', nin,         ';'
  write( 1, * ) ' nout        =  ', nout,        ';'
  write( 1, * ) ' nlock       =  ', nlock,       ';'
  write( 1, * ) ' ip3         = [', ip3,        '];'
  write( 1, * ) ' np          = [', np,         '];'
  write( 1, * ) ' ihypo       = [', ihypo,      '];'
  write( 1, * ) ' nm          = [', nm,         '];'
  write( 1, * ) ' nnoff       = [', nnoff,      '];'
  write( 1, * ) ' i1node      = [', i1node,     '];'
  write( 1, * ) ' i1cell      = [', i1cell,     '];'
  write( 1, * ) ' i1pml       = [', i1pml,      '];'
  write( 1, * ) ' i2node      = [', i2node,     '];'
  write( 1, * ) ' i2cell      = [', i2cell,     '];'
  write( 1, * ) ' i2pml       = [', i2pml,      '];'
  write( 1, * ) ' ibc1        = [', ibc1,       '];'
  write( 1, * ) ' ibc2        = [', ibc2,       '];'
  do iz = 1, nin
    select case( intype(iz) )
    case( 'z' ); write( 1, '(2x,a,a,g15.7,a,6i7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'zone'", i1in(iz,:), i2in(iz,:), ' };'
    case( 'c' ); write( 1, '(2x,a,a,g15.7,a,6g15.7,a)' ) &
      fieldin(iz), ' = {', inval(iz), " 'cube'", x1in(iz,:), x2in(iz,:), ' };'
    end select
  end do
  do iz = 1, nlock
    write( 1, '(a,9i7,a)' ) &
      '  lock        = [', ilock(iz,:), i1lock(iz,:), i2lock(iz,:), '];'
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
write( 1, * ) ' dx          =  ', dx,      ';'
write( 1, * ) ' rmax        =  ', rmax,    ';'
write( 1, * ) ' dt          =  ', dt,      ';'
write( 1, * ) ' rho0        =  ', rho0,    ';'
write( 1, * ) ' rho1        =  ', rho1,    ';'
write( 1, * ) ' rho2        =  ', rho2,    ';'
write( 1, * ) ' vp0         =  ', vp0,     ';'
write( 1, * ) ' vp1         =  ', vp1,     ';'
write( 1, * ) ' vp2         =  ', vp2,     ';'
write( 1, * ) ' vs0         =  ', vs0,     ';'
write( 1, * ) ' vs1         =  ', vs1,     ';'
write( 1, * ) ' vs2         =  ', vs2,     ';'
write( 1, * ) ' vdamp       =  ', vdamp,   ';'
write( 1, * ) ' rexpand     =  ', rexpand, ';'
write( 1, * ) ' courant     =  ', courant, ';'
write( 1, '(a,10g15.7,a)' ) '  affine      = [', affine, '];'
write( 1, * ) ' hourglass   = [', hourglass, '];'
write( 1, * ) ' symmetry    = [', symmetry,  '];'
write( 1, * ) ' xcenter     = [', xcenter,   '];'
write( 1, * ) ' xhypo       = [', xhypo,     '];'
write( 1, * ) ' nt          =  ', nt,         ';'
write( 1, * ) ' itcheck     =  ', itcheck,    ';'
write( 1, * ) ' fixhypo     =  ', fixhypo,    ';'
write( 1, * ) ' npml        =  ', npml,       ';'
write( 1, * ) ' oplevel     =  ', oplevel,    ';'
write( 1, * ) ' mpin        =  ', mpin,       ';'
write( 1, * ) ' mpout       =  ', mpout,      ';'
write( 1, * ) ' nn          = [', nn,            '];'
write( 1, * ) ' ihypo       = [', ihypo - nnoff, '];'
write( 1, * ) ' n1expand    = [', n1expand,      '];'
write( 1, * ) ' n2expand    = [', n2expand,      '];'
write( 1, * ) ' bc1         = [', bc1,           '];'
write( 1, * ) ' bc2         = [', bc2,           '];'
write( 1, * ) ' grid        = ''', trim( grid ),  ''';'
write( 1, * ) ' endian      = ''', endian, ''';'
write( 1, * ) ' rsource     =  ', rsource, ';'
if ( rsource > 0. ) then
  write( 1, * ) ' tsource     =  ', tsource, ';'
  write( 1, * ) ' moment1     = [', moment1,'];'
  write( 1, * ) ' moment2     = [', moment2,'];'
  write( 1, * ) ' rfunc       = ''', trim( rfunc ), ''';'
  write( 1, * ) ' tfunc       = ''', trim( tfunc ), ''';'
end if
write( 1, * ) ' faultnormal =  ', faultnormal, ';'
if ( faultnormal /= 0 ) then
  write( 1, * ) ' slipvector  = [', slipvector,'];'
  write( 1, * ) ' vrup        =  ', vrup,   ';'
  write( 1, * ) ' rcrit       =  ', rcrit,  ';'
  write( 1, * ) ' trelax      =  ', trelax, ';'
  write( 1, * ) ' svtol       =  ', svtol,  ';'
  write( 1, * ) ' mus0        =  ', mus0,   ';'
  write( 1, * ) ' mud0        =  ', mud0,   ';'
  write( 1, * ) ' dc0         =  ', dc0,    ';'
  write( 1, * ) ' tn0         =  ', tn0,    ';'
  write( 1, * ) ' ts0         =  ', ts0,    ';'
  write( 1, * ) ' ess         =  ', ess,    ';'
  write( 1, * ) ' lc          =  ', lc,     ';'
  write( 1, * ) ' rctest      =  ', rctest, ';'
end if
write( 1, * ) ' dirfmt      =  ''out/%02d'';'
do iz = 1, nout
  i = ditout(iz)
  i1 = i1out(iz,:) - (/ nnoff, 0 /)
  i2 = i2out(iz,:) - (/ nnoff, 0 /)
  call outprops( fieldout(iz), nc, onpass, fault, cell )
  write( field, * ) '''', trim( fieldout(iz) ), ''''
  write( 1, '(a,i3.3,a,i1,a,9i7,a)' ) '  out{', iz, '} = { ', nc, field, i, i1, i2, ' };'
end do
close( 1 )

open( 1, file='out/hdr', status='replace' )
write( 1, * ) nn
write( 1, * ) np
do iz = 1, nout
  i1 = i1out(iz,:) - (/ nnoff, 0 /)
  i2 = i2out(iz,:) - (/ nnoff, 0 /)
  call outprops( fieldout(iz), nc, onpass, fault, cell )
  do i = 1, nc
    write( 1, '(i2.2,a,i1,9i7)' ) iz, trim(fieldout(iz)), i, ditout(iz), i1, i2
  end do
end do
end subroutine

end module

