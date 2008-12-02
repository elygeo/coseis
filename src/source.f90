! Moment source
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

! Moment source
if ( rsource <= 0. ) return
if ( master ) write( 0, * ) 'Moment source initialize'

! Cell volumes
i1 = i1bc
i2 = i2bc - 1
call diffnc( s1, w1, 1, 1, i1cell, i2cell, oplevel, bb, xx, dx1, dx2, dx3, dx )
call set_halo( s1, 0., i1, i2 )

! Hypocenter/cell radius (squared)
call radius( s2, w2, xhypo, i1cell, i2cell )
call set_halo( s2, huge(sumsrcfr), i1cell, i2cell )
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
call set_halo( s2, 0., i1cell, i2cell )

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
subroutine moment_source
use m_globals
use m_util
integer :: i, j, k, l, ic, nsrc
real :: srcft = 0.

if ( rsource <= 0. ) return
if ( verb ) write( 0, * ) 'Moment source'

! Add to stress variables
srcft = time_function( tfunc, tm, dt, tsource )
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

end module

