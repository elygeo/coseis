! Collective routines - hooks for parallelization
module m_collective
implicit none
contains

! Initialize
subroutine initialize( ipout, np0, master )
integer, intent(out) :: ipout, np0
logical, intent(out) :: master
ipout = 0
np0 = 1
master = .true.
end subroutine

! Finalize
subroutine finalize
end subroutine

! Processor rank
subroutine rank( ipout, ip3, np )
integer, intent(out) :: ipout, ip3(3)
integer, intent(in) :: np(3)
ip3 = np
ip3 = 0
ipout = 0
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: i
i = ip3master(1)
end subroutine

! Broadcast real 1d
subroutine rbroadcast1( r )
real, intent(inout) :: r(:)
r = r
end subroutine

! Reduce integer
subroutine ireduce( ii, i, op, i2d )
integer, intent(out) :: ii
integer, intent(in) :: i, i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
ii = i2d
ii = i
end subroutine

! Reduce real
subroutine rreduce( rr, r, op, i2d )
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce real 1d
subroutine rreduce1( rr, r, op, i2d )
real, intent(out) :: rr(:)
real, intent(in) :: r(:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce real 2d
subroutine rreduce2( rr, r, op, i2d )
real, intent(out) :: rr(:,:)
real, intent(in) :: r(:,:)
integer, intent(in) :: i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
rr = i2d
rr = r
end subroutine

! Reduce extrema location, real 3d
subroutine reduceloc( rr, ii, r, op, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
character(*), intent(in) :: op
character :: a
a = op(1:1)
ii = n + noff + i2d
select case( op )
case( 'min', 'allmin' ); ii = minloc( r );
case( 'max', 'allmax' ); ii = maxloc( r );
case default; stop 'unknown op in reduceloc'
end select
rr = r(ii(1),ii(2),ii(3))
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Vector receive
subroutine vectorrecv( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Scalar swap halo
subroutine scalarswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:)
integer, intent(in) :: nhalo
f(1,1,1) = f(1,1,1) - nhalo + nhalo
end subroutine

! Vector swap halo
subroutine vectorswaphalo( f, nhalo )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: nhalo
f(1,1,1,1) = f(1,1,1,1) - nhalo + nhalo
end subroutine

! Split communicator
subroutine splitio( iz, nout, ditout )
integer, intent(in) :: iz, nout, ditout
integer :: i
i = iz + nout + ditout
end subroutine

! Scalar field input/output
subroutine scalario( io, filename, r, s1, i1, i2, i3, i4, iz, endian )
real, intent(inout) :: r, s1(:,:,:)
integer, intent(in) :: i1(3), i2(3), i3(3), i4(3), iz
character(*), intent(in) :: io, filename, endian
integer :: nb, i, j, k, l, j1, k1, l1, j2, k2, l2
real :: r1, r2
character :: c1(4), c2(4)
equivalence (r1,c1), (r2,c2)
if ( any( i1 /= i3 .or. i2 /= i4 ) .or. iz < 0 ) then
  write( 0, * ) 'Error in scalario: ', filename, io
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
if ( all( i1 == i2 ) .and. io == 'w' ) then
  r = s1(j1,k1,l1)
  return
end if
inquire( iolength=nb ) s1(j1:j2,k1:k2,l1:l2)
if ( nb == 0 ) stop 'scalario zero size'
select case( io )
case( 'r' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( 0, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  read( 1, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
  if ( endian /= '' ) then
  if ( endian == 'l' .eqv. iachar( transfer( 1, 'a' ) ) == 0 ) then
    do l = l1, l2
    do k = k1, k2
    do j = j1, j2
      r1 = s1(j,k,l)
      c2(4) = c1(1)
      c2(3) = c1(2)
      c2(2) = c1(3)
      c2(1) = c1(4)
      s1(j,k,l) = r2
    end do
    end do
    end do
  end if
  end if
case( 'w' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='replace' )
  if ( i /= 0 ) then
    write( 0, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  write( 1, rec=1 ) s1(j1:j2,k1:k2,l1:l2)
  close( 1 )
end select
end subroutine

! Vector field component input/output
subroutine vectorio( io, filename, r, w1, ic, i1, i2, i3, i4, iz, endian )
real, intent(inout) :: r, w1(:,:,:,:)
integer, intent(in) :: ic, i1(3), i2(3), i3(3), i4(3), iz
character(*), intent(in) :: io, filename, endian
integer :: nb, i, j, k, l, j1, k1, l1, j2, k2, l2
real :: r1, r2
character :: c1(4), c2(4)
equivalence (r1,c1), (r2,c2)

if ( any( i1 /= i3 .or. i2 /= i4 ) .or. iz < 0 ) then
  write( 0, * ) 'Error in vectorio: ', filename, io
  write( 0, * ) i1, i2
  write( 0, * ) i3, i4
  stop
end if
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
if ( all( i1 == i2 ) .and. io == 'w' ) then
  r = w1(j1,k1,l1,ic)
  return
end if
inquire( iolength=nb ) w1(j1:j2,k1:k2,l1:l2,ic)
if ( nb == 0 ) stop 'vectorio zero size'
select case( io )
case( 'r' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='old' )
  if ( i /= 0 ) then
    write( 0, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  read( 1, rec=1 ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
  if ( endian /= '' ) then
  if ( endian == 'l' .eqv. iachar( transfer( 1, 'a' ) ) == 0 ) then
    do l = l1, l2
    do k = k1, k2
    do j = j1, j2
      r1 = w1(j,k,l,ic)
      c2(4) = c1(1)
      c2(3) = c1(2)
      c2(2) = c1(3)
      c2(1) = c1(4)
      w1(j,k,l,ic) = r2
    end do
    end do
    end do
  end if
  end if
case( 'w' )
  open( 1, file=filename, recl=nb, iostat=i, form='unformatted', access='direct', status='replace' )
  if ( i /= 0 ) then
    write( 0, * ) 'Error opening file: ', trim( filename )
    stop
  end if
  write( 1, rec=1 ) w1(j1:j2,k1:k2,l1:l2,ic)
  close( 1 )
end select
end subroutine

end module

