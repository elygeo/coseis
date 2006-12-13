! collective routines - hooks for parallelization
module m_collective
implicit none
contains

! initialize
subroutine initialize( ipout, np0, master )
integer, intent(out) :: ipout, np0
logical, intent(out) :: master
ipout = 0
np0 = 1
master = .true.
end subroutine

! finalize
subroutine finalize
end subroutine

! processor rank
subroutine rank( ipout, ip3, np )
integer, intent(out) :: ipout, ip3(3)
integer, intent(in) :: np(3)
ip3 = np
ip3 = 0
ipout = 0
end subroutine

! set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: i
i = ip3master(1)
end subroutine

! broadcast real 1d
subroutine broadcastr1( r )
real, intent(inout) :: r(:)
r = r
end subroutine

! all reduce integer
subroutine allreducei0( ii, i, op, i2d )
integer, intent(out) :: ii
integer, intent(in) :: i, i2d
character(3), intent(in) :: op(3)
ii = i2d
ii = i
end subroutine

! reduce real
subroutine reducer0( rr, r, op, i2d )
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i2d
character(3), intent(in) :: op(3)
rr = i2d
rr = r
end subroutine

! reduce real 1d
subroutine reducer1( rr, r, op, i2d )
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(3), intent(in) :: op(3)
rr = i2d
rr = r
end subroutine

! all reduce real 1d
subroutine allreducer1( rr, r, op, i2d )
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(3), intent(in) :: op(3)
rr = i2d
rr = r
end subroutine

! reduce extrema location, real 3d
subroutine reduceloc( rr, ii, r, op, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
character(3), intent(in) :: op
ii = n + noff + i2d
select case( op )
case( 'min' ); ii = minloc( r );
case( 'max' ); ii = maxloc( r );
end select
rr = r(ii(1),ii(2),ii(3))
end subroutine

! all reduce extrema location, real 3d
subroutine allreduceloc( rr, ii, r, op, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
character(3), intent(in) :: op
ii = n + noff + i2d
select case( op )
case( 'min' ); ii = minloc( r );
case( 'max' ); ii = maxloc( r );
end select
rr = r(ii(1),ii(2),ii(3))
end subroutine

! vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! vector recieve
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
f(1,1,1) = f(1,1,1) - nhalo + nhalo
end subroutine

! vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
f(1,1,1,1) = f(1,1,1,1) - nhalo + nhalo
end subroutine

! split communicator
subroutine splitio( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: i
i = iz + nout + ditout
end subroutine

! scalar field input/output
subroutine scalario( io, filename, s1, ir, i1, i2, i3, i4, iz )
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: ir, i1(3), i2(3), i3(3), i4(3), iz
character(*), intent(in) :: io, filename
integer :: nb, i, j1, k1, l1, j2, k2, l2
if ( any( i1 /= i3 .or. i2 /= i4 ) .or. iz < 0 ) stop 'scalario index error'
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=nb ) s1(j1:j2,k1:k2,l1:l2)
if ( nb == 0 ) stop 'scalario zero size'
select case( io )
case( 'r' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  read( 1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
case( 'w' )
  if ( ir == 1 ) then
    open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='replace' )
  else
    open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  end if
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  write( 1, rec=ir ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
end select
end subroutine

! vector field component input/output
subroutine vectorio( io, filename, w1, ic, ir, i1, i2, i3, i4, iz )
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: ic, ir, i1(3), i2(3), i3(3), i4(3), iz
character(*), intent(in) :: io, filename
integer :: nb, i, j1, k1, l1, j2, k2, l2
if ( any( i1 /= i3 .or. i2 /= i4 ) .or. iz < 0 ) stop 'vectorio index error'
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
inquire( iolength=nb ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( nb == 0 ) stop 'vectorio zero size'
select case( io )
case( 'r' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  read( 1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
case( 'w' )
  if ( ir == 1 ) then
    open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='replace' )
  else
    open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  end if
  if ( i /= 0 ) then
    write( *, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  write( 1, rec=ir ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
end select
end subroutine

end module

