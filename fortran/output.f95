!------------------------------------------------------------------------------!
! OUTPUT

subroutine output( init )
use globals
integer :: rc, i, j, k, l, nz(3), nc, reclen, i1(3), i2(3), init, ii
character(255) :: ofile

if ( init == 0 ) then
  if ( ipe == 0 ) print '(a)', 'Initialize output'
  do iz = 1, nout
    call zoneselect( outi(iz,:), ng, nl, offset, hypocenter )
    do i = 1, 3
      i1(i) = outgi1(i,iz)
      i2(i) = outgi2(i,iz)
      nn(i) = i2(i) - i1(i) + 1
    end do
    select case ( outvar(iz) )
    case('u'); nc = 3
    case('v'); nc = 3
    case('w'); nc = 6
    case default; stop 'Error: outvar'
    end select
    outnc(iz) = nc
    if ( ipe == 0 ) then
      write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/hdr'
      open(  9, file=ofile )
      write( 9, * ) nc, i1, i2, outint(iz), nt, dt, outvar(iz)
      close( 9 )
      j1 = i1(1); k1 = i1(2); l1 = i1(3)
      j2 = i2(1); k2 = i2(2); l2 = i2(3)
      reclen = floatsize * product( nn )
      write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/mesh1'
      open(  9, file=ofile, form="unformatted", access="direct", recl=reclen )
      write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,1)
      close( 9 )
      write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/mesh2'
      open(  9, file=ofile, form="unformatted", access="direct", recl=reclen )
      write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,2)
      close( 9 )
      write( ofile, '(a,i2.2,a)' ) 'out/', iz, '/mesh3'
      open(  9, file=ofile, form="unformatted", access="direct", recl=reclen )
      write( 9, rec=1 ) x(j1:j2,k1:k2,l1:l2,3)
      close( 9 )
    end if
    outme(iz)  = .true.
    outmee(iz) = .true.
    do i = 1, 3
      i1(i) = i1(i) - offset(i)
      i2(i) = i2(i) - offset(i)
      if ( i1(i) < core1(i) .or. i2(i) > core2(i) ) outmee(iz) = .false.
      i1(i) = max( i1(i), core1(i) )
      i2(i) = min( i2(i), core2(i) )
      if ( i1(i) > i2(i) ) outme(iz) = .false.
      outli1(1,i,iz) = i1(i)
      outli2(2,i,iz) = i2(i)
    end do
  end do
  return
end if 

do i = 1, 4
  i1(i) = outli1(i,iz)
  i2(i) = outli2(i,iz)
  nn(i) = i2(i) - i1(i) + 1
end do
j1 = i1(1); k1 = i1(2); l1 = i1(3)
j2 = i2(1); k2 = i2(2); l2 = i2(3)
do i = 1, outnc(iz)
  write( ofile, '(a,i2.2,a,i1,a,i5.5)' ) 'out/', iz, '/', i, '/', it
  reclen = floatsize * product( nn )
  open( 9, file=ofile, form='unformatted', access='direct', recl=reclen )
  select case ( outvar(iz) )
  case('u'); write( 9, rec=1 ) u(j1:j2,k1:k2,l1:l2,i)
  case('v'); write( 9, rec=1 ) v(j1:j2,k1:k2,l1:l2,i)
  case default; stop 'Error: outvar'
  end select
end do

close( 9 )

end subroutine

