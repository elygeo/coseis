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
  write( str, "( a,i6.6,a )" ) 'debug/db', ip, '.m'
  open( 1, file=str, status='replace' )
  write( 1, "( '% SORD debug info'                                              )" )
  write( 1, "( 'debug  =    ',i8,';'                                            )" ) debug
  write( 1, "( 'master =    ',i8,';'                                            )" ) i
  write( 1, "( 'ip     =    ',i8,';'                                            )" ) ip
  write( 1, "( 'ifn    =    ',i8,';'                                            )" ) ifn
  write( 1, "( 'nin    =    ',i8,';'                                            )" ) nin
  write( 1, "( 'ip3    =  [ ',i8,2(', ',i8),'];'                                )" ) ip3
  write( 1, "( 'np     =  [ ',i8,2(', ',i8),'];'                                )" ) np
  write( 1, "( 'nhalo  =  [ ',i8,2(', ',i8),'];'                                )" ) nhalo
  write( 1, "( 'ihypo  =  [ ',i8,2(', ',i8),'];'                                )" ) ihypo
  write( 1, "( 'nm     =  [ ',i8,2(', ',i8),'];'                                )" ) nm
  write( 1, "( 'nnoff  =  [ ',i8,2(', ',i8),'];'                                )" ) nnoff
  write( 1, "( 'i1bc   =  [ ',i8,2(', ',i8),']; i2bc   =  [',i8,2(', ',i8),' ];')" ) i1bc, i2bc
  write( 1, "( 'i1pml  =  [ ',i8,2(', ',i8),']; i2pml  =  [',i8,2(', ',i8),' ];')" ) i1pml, i2pml
  write( 1, "( 'i1core =  [ ',i8,2(', ',i8),']; i2core =  [',i8,2(', ',i8),' ];')" ) i1core, i2core
  write( 1, "( 'i1node =  [ ',i8,2(', ',i8),']; i2node =  [',i8,2(', ',i8),' ];')" ) i1node, i2node
  write( 1, "( 'i1cell =  [ ',i8,2(', ',i8),']; i2cell =  [',i8,2(', ',i8),' ];')" ) i1cell, i2cell
  do iz = 1, nin
    select case( intype(iz) )
    case( 'z' ); write( 1, "( a,' = { ',g15.7,', ''zone'', ',i8,5(', ',i8),' };' )" ) &
      fieldin(iz), inval(iz), i1in(iz,:), i2in(iz,:)
    case( 'c' ); write( 1, "( a,' = { ',g15.7,', ''cube'', ',g15.7,5(', ',g15.7),' };' )" ) &
      fieldin(iz), inval(iz), x1in(iz,:), x2in(iz,:)
    end select
  end do
  close( 1 )
end if

! Metadata
if ( .not. master ) return
endian = 'l'
if ( iachar( transfer( 1, 'a' ) ) == 0 ) endian = 'b'
courant = dt * vp2 * sqrt( 3. ) / abs( dx )
open( 1, file='meta.m', status='replace' )
write( 1, "( '% SORD metadata'                              )" )
write( 1, "( 'dx          =    ',g15.7,';'                  )" ) dx
write( 1, "( 'dt          =    ',g15.7,';'                  )" ) dt
write( 1, "( 'rho_        =    ',g15.7,';'                  )" ) rho_
write( 1, "( 'rho1        =    ',g15.7,';'                  )" ) rho1
write( 1, "( 'rho2        =    ',g15.7,';'                  )" ) rho2
write( 1, "( 'vp_         =    ',g15.7,';'                  )" ) vp_
write( 1, "( 'vp1         =    ',g15.7,';'                  )" ) vp1
write( 1, "( 'vp2         =    ',g15.7,';'                  )" ) vp2
write( 1, "( 'vs_         =    ',g15.7,';'                  )" ) vs_
write( 1, "( 'vs1         =    ',g15.7,';'                  )" ) vs1
write( 1, "( 'vs2         =    ',g15.7,';'                  )" ) vs2
write( 1, "( 'gam_        =    ',g15.7,';'                  )" ) gam_
write( 1, "( 'gam1        =    ',g15.7,';'                  )" ) gam1
write( 1, "( 'gam2        =    ',g15.7,';'                  )" ) gam2
write( 1, "( 'vdamp       =    ',g15.7,';'                  )" ) vdamp
write( 1, "( 'rexpand     =    ',g15.7,';'                  )" ) rexpand
write( 1, "( 'courant     =    ',g15.7,';'                  )" ) courant
write( 1, "( 'hourglass   =  [ ',g15.7,', ',g15.7,' ];'     )" ) hourglass
write( 1, "( 'xhypo       =  [ ',g15.7,2(', ',g15.7),' ];'  )" ) xhypo
write( 1, "( 'affine      = [[ ',g15.7,2(', ',g15.7),' ],'  )" ) affine(1:3)
write( 1, "( '               [ ',g15.7,2(', ',g15.7),' ],'  )" ) affine(4:6)
write( 1, "( '               [ ',g15.7,2(', ',g15.7),' ]];' )" ) affine(7:9)
write( 1, "( 'nt          =    ',i8,';'                     )" ) nt
write( 1, "( 'itstats     =    ',i8,';'                     )" ) itstats
write( 1, "( 'itio        =    ',i8,';'                     )" ) itio
write( 1, "( 'itcheck     =    ',i8,';'                     )" ) itcheck
write( 1, "( 'fixhypo     =    ',i8,';'                     )" ) fixhypo
write( 1, "( 'npml        =    ',i8,';'                     )" ) npml
write( 1, "( 'oplevel     =    ',i8,';'                     )" ) oplevel
write( 1, "( 'mpin        =    ',i8,';'                     )" ) mpin
write( 1, "( 'mpout       =    ',i8,';'                     )" ) mpout
write( 1, "( 'nn          =  [ ',i8,2(', ',i8),' ];'        )" ) nn
write( 1, "( 'ihypo       =  [ ',i8,2(', ',i8),' ];'        )" ) ihypo + nnoff
write( 1, "( 'n1expand    =  [ ',i8,2(', ',i8),' ];'        )" ) n1expand
write( 1, "( 'n2expand    =  [ ',i8,2(', ',i8),' ];'        )" ) n2expand
write( 1, "( 'bc1         =  [ ',i8,2(', ',i8),' ];'        )" ) bc1
write( 1, "( 'bc2         =  [ ',i8,2(', ',i8),' ];'        )" ) bc2
write( 1, "( 'i1source    =  [ ',i8,2(', ',i8),' ];'        )" ) i1source
write( 1, "( 'i2source    =  [ ',i8,2(', ',i8),' ];'        )" ) i2source
write( 1, "( 'endian      =   ''',a,''';'                   )" ) endian
write( 1, "( 'rsource     =    ',g15.7,';'                  )" ) rsource
write( 1, "( 'tsource     =    ',g15.7,';'                  )" ) tsource
write( 1, "( 'moment1     =  [ ',g15.7,2(', ',g15.7),' ];'  )" ) moment1
write( 1, "( 'moment2     =  [ ',g15.7,2(', ',g15.7),' ];'  )" ) moment2
write( 1, "( 'rfunc       =   ''',a,''';'                   )" ) trim( rfunc )
write( 1, "( 'tfunc       =   ''',a,''';'                   )" ) trim( tfunc )
write( 1, "( 'faultnormal =    ',i8,';'                     )" ) faultnormal
if ( faultnormal /= 0 ) then
write( 1, "( 'slipvector  =  [',g15.7,2(',',g15.7),'];'     )" ) slipvector
write( 1, "( 'vrup        =   ',g15.7,';'                   )" ) vrup
write( 1, "( 'rcrit       =   ',g15.7,';'                   )" ) rcrit
write( 1, "( 'trelax      =   ',g15.7,';'                   )" ) trelax
write( 1, "( 'svtol       =   ',g15.7,';'                   )" ) svtol
write( 1, "( 'mu0         =   ',g15.7,';'                   )" ) mu0
write( 1, "( 'mus0        =   ',g15.7,';'                   )" ) mus0
write( 1, "( 'mud0        =   ',g15.7,';'                   )" ) mud0
write( 1, "( 'dc0         =   ',g15.7,';'                   )" ) dc0
write( 1, "( 'tn0         =   ',g15.7,';'                   )" ) tn0
write( 1, "( 'ts0         =   ',g15.7,';'                   )" ) ts0
write( 1, "( 'ess         =   ',g15.7,';'                   )" ) ess
write( 1, "( 'lc          =   ',g15.7,';'                   )" ) lc
write( 1, "( 'rctest      =   ',g15.7,';'                   )" ) rctest
end if
write( 1, "( 'dirfmt      =   ''out/%02d'';'                )" )
write( 1, "( 'out         =   {'                            )" )
do iz = 1, nout
  i = ditout(iz)
  i1 = i1out(iz,:)
  i2 = i2out(iz,:)
  i1(1:3) = i1(1:3) + nnoff
  i2(1:3) = i2(1:3) + nnoff
  call outprops( fieldout(iz), nc, onpass, fault, cell )
  write( field, "( '''',a,''',')" ) trim( fieldout(iz) )
  write( 1, "( '  { ',i1,' ',a,9(', ',i7),' }, % ',i3 )" ) nc, field, i, i1, i2, iz
end do
write( 1, "( '};' )" )
close( 1 )

! Translate MATALB to Python
open( 1, file='meta.m', status='old' )
open( 2, file='meta.py', status='replace' )
doline: do
  read( 1, "(a)", iostat=i ) str
  if ( i /= 0 ) exit
  do; i = scan( str, "%" ); if ( i == 0 ) exit; str(i:i) = '#'; end do
  do; i = scan( str, "{" ); if ( i == 0 ) exit; str(i:i) = '['; end do
  do; i = scan( str, "}" ); if ( i == 0 ) exit; str(i:i) = ']'; end do
  write( 2, "(a)" ) trim( str )
end do doline
close( 1 )
close( 2 )

! Header for split multi-processor output
if ( mpout == 0 ) then
  open( 1, file='out/hdr', status='replace' )
  write( 1, "(3i8)" ) nn
  write( 1, "(3i8)" ) np
  do iz = 1, nout
    i1 = i1out(iz,:)
    i2 = i2out(iz,:)
    i1(1:3) = i1(1:3) + nnoff
    i2(1:3) = i2(1:3) + nnoff
    call outprops( fieldout(iz), nc, onpass, fault, cell )
    do i = 1, nc
      write( 1, "( 9(i7,', '),i2.2,', ',a,', ',i1 )" ) &
      ditout(iz), i1, i2, iz, trim( fieldout(iz) ), i
    end do
  end do
  close( 1 )
end if

end subroutine

end module

