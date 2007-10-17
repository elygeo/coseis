! Moment source and finite source
! Copyright 2007 Geoffrey Ely
! This software is released under the GNU General Public License
module m_source
implicit none
real, private, allocatable :: srcfr(:)
integer, private, allocatable :: jj(:), kk(:), ll(:)
contains

! Initialize source
subroutine source_init
use m_globals
use m_diffnc
use m_collective
use m_util
real, allocatable :: cellvol(:)
integer :: i1(3), i2(3), i, j, k, l, nsrc
real :: sumsrcfr, allsumsrcfr

! Finite source indices
call zone( i1source, i2source, nn, nnoff, ihypo, faultnormal )
i1source = max( i1source, 1  )
i2source = min( i2source, nm )

! Moment source
if ( rsource <= 0. ) return
if ( master ) write( 0, * ) 'Moment source initialize'

! Cell volumes
i1 = i1bc
i2 = i2bc - 1
call diffnc( s1, w1, 1, 1, i1cell, i2cell, oplevel, bb, xx, dx1, dx2, dx3, dx )
call scalarsethalo( s1, 0., i1, i2 )

! Hypocenter/cell radius (squared)
call radius( s2, w2, xhypo, i1cell, i2cell )
call scalarsethalo( s2, huge(sumsrcfr), i1cell, i2cell )
nsrc = count( s2 < rsource*rsource )
allocate( jj(nsrc), kk(nsrc), ll(nsrc), cellvol(nsrc), srcfr(nsrc) )

! Use points inside radius
i = 0
srcfr = 0.
sumsrcfr = 0.
do l = i1cell(3), i2cell(3)
do k = i1cell(2), i2cell(2)
do j = i1cell(1), i2cell(1)
if ( s2(j,k,l) < rsource*rsource ) then
  i = i + 1
  jj(i) = j
  kk(i) = k
  ll(i) = l
  cellvol(i) = s1(j,k,l)
  select case( rfunc )
  case( 'point' )
  case( 'box'  ); srcfr(i) = 1.
  case( 'tent' ); srcfr(i) = rsource - sqrt( s2(j,k,l) )
  case default
    write( 0, * ) 'invalid rfunc: ', trim( rfunc )
    stop
  end select
  if ( all( (/ j, k, l /) >= i1core .and. (/ j, k, l /) <= i2core ) ) then
    sumsrcfr = sumsrcfr + srcfr(i)
  end if
end if
end do
end do
end do
call scalarsethalo( s2, 0., i1cell, i2cell )

! Normalize and divide by cell volume
if ( rfunc == 'point' ) then
  if ( nsrc > 8 ) stop 'rsource too large for point source'
  srcfr = ( .5 * dx / rsource ) ** 3
else
  call rreduce( allsumsrcfr, sumsrcfr, 'allsum', 0 )
  if ( allsumsrcfr <= 0. ) stop 'bad source space function'
  srcfr = srcfr / allsumsrcfr
end if
where ( cellvol > 0. ) srcfr = srcfr / cellvol

end subroutine

!------------------------------------------------------------------------------!

! Add moment source
subroutine momentsource
use m_globals
integer :: i, j, k, l, ic, nsrc
real :: srcft = 0.

if ( rsource <= 0. ) return
if ( master .and. debug == 2 ) write( 0, * ) 'Moment source'

! Source time function
select case( tfunc )
case( 'delta' ); srcft = 1.
case( 'brune' ); srcft = 1. - exp( -tm / tsource ) / tsource * ( tm + tsource )
case default
  write( 0, * ) 'invalid tfunc: ', trim( tfunc )
  stop
end select

! Add to stress variables
nsrc = size( srcfr )
do ic = 1, 3
do i = 1, nsrc
  j = jj(i)
  k = kk(i)
  l = ll(i)
  w1(j,k,l,ic) = w1(j,k,l,ic) - srcft * srcfr(i) * moment1(ic)
  w2(j,k,l,ic) = w2(j,k,l,ic) - srcft * srcfr(i) * moment2(ic)
end do
end do

end subroutine

!------------------------------------------------------------------------------!

! Add finite source
subroutine finitesource
use m_globals
integer :: j, k, l
real :: t, srcft = 0.

if ( any( i1source > i2source ) ) return
if ( master .and. debug == 2 ) write( 0, * ) 'Finite source'

! Source time function
select case( tfunc )
case( 'delta'  )
  if ( it == 0 ) srcft = 1.
case( 'brune' )
  srcft = exp( -tm / tsource ) * tm / tsource
case( 'ricker1' )
  t = tm - tsource
  srcft = t * exp( -2. * ( pi * t / tsource ) ** 2. )
case( 'ricker2' )
  t = ( pi * ( tm - tsource ) / tsource ) ** 2.
  srcft = ( 1. - 2. * t ) * exp( -t )
case default
  write( 0, * ) 'invalid tfunc: ', trim( tfunc )
  stop
end select

! Set displacement
do l = i1source(3), i2source(3)
do k = i1source(2), i2source(2)
do j = i1source(1), i2source(1)
  uu(j,k,l,1) = srcft * moment1(1)
  uu(j,k,l,2) = srcft * moment1(2)
  uu(j,k,l,3) = srcft * moment1(3)
end do
end do
end do

end subroutine

end module

