! Output properties
! Copyright 2007 Geoffrey Ely
! This software is released under the GNU General Public License
module m_outprops
implicit none
contains

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
case( 'rho'  ); onpass = 0; cell = .true.
case( 'vp'   ); onpass = 0; cell = .true.
case( 'vs'   ); onpass = 0; cell = .true.
case( 'lam'  ); onpass = 0; cell = .true.
case( 'mu'   ); onpass = 0; cell = .true.
case( 'gam'  ); onpass = 0; cell = .true.
case( 'gamt' )
case( 'mr'   )
case( 'v'    ); nc = 3
case( 'vm2'  ); onpass = 1
case( 'pv2'  ); onpass = 1
case( 'w'    ); onpass = 1; cell = .true.; nc = 6
case( 'wm2'  ); onpass = 1; cell = .true.
case( 'u'    ); nc = 3
case( 'um2'  )
case( 'a'    ); nc = 3
case( 'am2'  )
case( 'nhat' ); fault = .true.; onpass = 0; nc = 3
case( 'mus'  ); fault = .true.; onpass = 0
case( 'mud'  ); fault = .true.; onpass = 0
case( 'dc'   ); fault = .true.; onpass = 0
case( 'co'   ); fault = .true.; onpass = 0
case( 'sv'   ); fault = .true.; onpass = 1; nc = 3
case( 'svm'  ); fault = .true.; onpass = 1
case( 'psv'  ); fault = .true.; onpass = 1
case( 'su'   ); fault = .true.; onpass = 1; nc = 3
case( 'sum'  ); fault = .true.; onpass = 1
case( 'sl'   ); fault = .true.
case( 'ts'   ); fault = .true.; nc = 3
case( 'tsm'  ); fault = .true.
case( 'tn'   ); fault = .true.
case( 'fr'   ); fault = .true.
case( 'sa'   ); fault = .true.; nc = 3
case( 'sam'  ); fault = .true.
case( 'trup' ); fault = .true.
case( 'tarr' ); fault = .true.
case default
  write( 0, * ) 'error: unknown output field: ', field
  stop
end select
end subroutine

end module

