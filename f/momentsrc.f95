!------------------------------------------------------------------------------!
! MOMENTSRC

module momentsrc_m
contains
subroutine momentsrc
use globals_m
use dfnc_m

implicit none
save
logical :: init = .true.
integer, allocatable :: jj(:), kk(:), ll(:)
real, allocatable :: srcfr(:)
integer :: i, j, k, l, i1(3), j1, k1, l1, i2(3), j2, k2, l2, nsrc, ic
real :: srcft, m0, mw, d, mm(3,3), eigval(3), eigwork(8)

if ( rsource <= 0. ) return

ifinit: if ( init ) then

init = .false.
if ( ip == 0 ) print '(a)', 'Moment source'

! Indices
i1 = i1cell
i2 = i2cell
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)

! Cell volumes
s1 = 0.
call dfnc( s1, 'g', x, x, dx, 1, 1, i1, i2 )

! Cell center locations
w1 = 2 * rsource
forall( j=j1:j2, k=k1:k2, l=l1:l2 )
  w1(j,k,l,:) = 0.125 * &
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) &
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) &
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) &
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
end forall

! Find radius to cell from source location
do i = 1, 3
  w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i)
end do
s2 = sqrt( sum( w1 * w1, 4 ) )
nsrc = count( s2 <= rsource )
allocate( srcfr(nrsc), jj(nsrc), kk(nsrc), ll(nsrc) ) 

! Spatial weighting
select case( rfunc )
case( 'box'  ); srcfr = 1.
case( 'tent' ); srcfr = rsource - pack( s2, s2 <= rsource )
case default; stop 'rfunc'
end select

! Normalize and devide by cell volume
srcfr = srcfr / sum( srcfr ) / pack( s1, s2 <= rsource )

! Index map
i = 0
do l = l1, l2
do k = k1, k2
do j = j1, j2
if ( s2(j,k,l) <= rsource ) then
  i = i + 1
  jj(i) = j
  kk(i) = k
  ll(i) = l
end if
end do
end do
end do

s1 = 0.
s2 = 0.

! Metadata, requires LAPACK for eigenvalue calculation
if ( all( ihypo >= i1node .and. ihypo <= i2node ) ) then
  mm(1,1) = moment1(1)
  mm(2,2) = moment1(2)
  mm(3,3) = moment1(3)
  mm(2,3) = moment2(1)
  mm(1,3) = moment2(2)
  mm(1,2) = moment2(3)
  call ssyev( 'N', 'U', 3, mm, 3, eigval, eigwork, size(eigwork), i )
  m0 = maxval( abs( eigval ) )
  mw = 2. / 3. * log10( m0 ) - 10.7
  d = m0 / ( rho * vs * vs * dx * dx )
  open(  9, file='out/sourcemeta.m', status='new' )
  write( 9, * ) 'm0 = ', m0, ';'
  write( 9, * ) 'mw = ', mw, ';'
  write( 9, * ) 'd  = ', d,  ';'
  close( 9 )
end if


return

end if ifinit

!------------------------------------------------------------------------------!

! Source time function
select case( tfunc )
case( 'delta'  ); srcft = 1.
case( 'brune'  ); srcft = 1. - exp( -t / tsource ) / tsource * ( t + tsource )
case( 'sbrune' ); srcft = 1. - exp( -t / tsource ) / tsource * &
  ( t + tsource + t * t / tsource / 2. )
case default; stop 'tfunc'
end select

! Add to stress variables
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

