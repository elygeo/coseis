! Collective routines - Provides hooks for parallelization
module m_collective
implicit none
contains

! Initialize
subroutine initialize( ipout, np0, master )
logical, intent(out) :: master
integer, intent(out) :: ipout, np0
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
ipout = 0
ip3 = np - np
end subroutine

! Set master processor
subroutine setmaster( ip3master )
integer, intent(in) :: ip3master(3)
integer :: i
i = ip3master(1)
end subroutine

! Integer broadcast
subroutine ibroadcast( i )
real, intent(inout) :: i
i = i
end subroutine

! Real broadcast
subroutine broadcast( r )
real, intent(inout) :: r(:)
r = r
end subroutine

! Real sum
subroutine psum( rr, r, i )
real, intent(out) :: rr
real, intent(in) :: r
integer, intent(in) :: i
integer :: ii
rr = r
ii = i
end subroutine

! Integer minimum
subroutine pimin( ii, i )
integer, intent(out) :: ii
integer, intent(in) :: i
ii = i
end subroutine

! Real minimum
subroutine pmin( rr, r )
real, intent(out) :: rr
real, intent(in) :: r
rr = r
end subroutine

! Real maximum
subroutine pmax( rr, r )
real, intent(out) :: rr
real, intent(in) :: r
rr = r
end subroutine

!Real global minimum & location
subroutine pminloc( rr, ii, r, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
ii = minloc( r ) - n + n - noff + noff - i2d + i2d
rr = r(ii(1),ii(2),ii(3))
end subroutine

! Real global maximum & location
subroutine pmaxloc( rr, ii, r, n, noff, i2d )
real, intent(out) :: rr
real, intent(in) :: r(:,:,:)
integer, intent(out) :: ii(3)
integer, intent(in) :: n(3), noff(3), i2d
ii = maxloc( r ) - n + n - noff + noff - i2d + i2d
rr = r(ii(1),ii(2),ii(3))
end subroutine

! Vector send
subroutine vectorsend( f, i1, i2, i )
real, intent(inout) :: f(:,:,:,:)
integer, intent(in) :: i1(3), i2(3), i
f(1,1,1,1) = f(1,1,1,1) - i1(1) + i1(1) - i2(1) + i2(1) - i + i
end subroutine

! Vector recieve
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
subroutine scalario( io, filename, s1, ir, i1, i2, i3, i4, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: s1(:,:,:)
integer, intent(in) :: ir, i1(3), i2(3), i3(3), i4(3), iz
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

! Vector field component input/output
subroutine vectorio( io, filename, w1, ic, ir, i1, i2, i3, i4, iz )
character(*), intent(in) :: io, filename
real, intent(inout) :: w1(:,:,:,:)
integer, intent(in) :: ic, ir, i1(3), i2(3), i3(3), i4(3), iz
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

