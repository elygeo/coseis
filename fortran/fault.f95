!------------------------------------------------------------------------------!
! FAULT

subroutine fault( init )

use globals
implicit none
real, allocatable, dimension(:,:,:) :: fs, fd, dc, cohes, area, r, tmp, tn, ts, ff, ff2
real, allocatable, dimension(:,:,:,:) :: nrm, tt0, str, dip, tt0nsd, w0, tt, tn3, ts3, r3
real :: fs0, fd0, dc0, tn0, ts0
integer :: nf(3), down(3), handed, init, strdim, dipdim, j3, j4, k3, k4, l3, l4

if ( init == 0 ) then
  if ( ipe == 0 ) print '(a)', 'Initialize fault'
  if ( nrmdim /= downdim ) then
    dipdim = downdim
    strdim = 6 - dipdim - nrmdim
  else
    strdim = mod( nrmdim, 3 ) + 1
    dipdim = 6 - strdim - nrmdim
  end if
  down = (/ 0, 0, 0 /)
  down(downdim) = 1
  handed = mod( strdim - nrmdim + 1, 3 ) - 1
  i1 = i1node
  i2 = i2node
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  allocate( &
    uslip(j1:j2,k1:k2,l1:l2), &
    vslip(j1:j2,k1:k2,l1:l2), &
     trup(j1:j2,k1:k2,l1:l2), &
       fs(j1:j2,k1:k2,l1:l2), &
       fd(j1:j2,k1:k2,l1:l2), &
       dc(j1:j2,k1:k2,l1:l2), &
    cohes(j1:j2,k1:k2,l1:l2), &
     area(j1:j2,k1:k2,l1:l2), &
      tmp(j1:j2,k1:k2,l1:l2), &
        r(j1:j2,k1:k2,l1:l2), &
       r3(j1:j2,k1:k2,l1:l2,3), &
      nrm(j1:j2,k1:k2,l1:l2,3), &
      tt0(j1:j2,k1:k2,l1:l2,3), &
       w0(j1:j2,k1:k2,l1:l2,6), &
      str(j1:j2,k1:k2,l1:l2,3), &
      dip(j1:j2,k1:k2,l1:l2,3) )
  uslip = 0.
  vslip = 0.
  trup = 0.
  fs = 0.
  fd = 0.
  dc = 0.
  cohes = 1e9
  do iz = 1, nfric
    call zoneselect( i1, i2, frici(iz,:), npg, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    fs(j1:j2,k1:k2,l1:l2)    = friction(iz,1)
    fd(j1:j2,k1:k2,l1:l2)    = friction(iz,2)
    dc(j1:j2,k1:k2,l1:l2)    = friction(iz,3)
    cohes(j1:j2,k1:k2,l1:l2) = friction(iz,4)
  end do
  tt0nsd = 0.
  do iz = 1, ntrac
    call zoneselect( i1, i2, traci(iz,:), npg, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    tt0nsd(j1:j2,k1:k2,l1:l2,1) = traction(iz,1)
    tt0nsd(j1:j2,k1:k2,l1:l2,2) = traction(iz,2)
    tt0nsd(j1:j2,k1:k2,l1:l2,3) = traction(iz,3)
  end do
  w0 = 0.
  do iz = 1, nstress
    call zoneselect( i1, i2, stressi(iz,:), npg, hypocenter, nrmdim )
    i1 = max( i1, i1nodepml )
    i2 = min( i2, i2nodepml )
    i1(nrmdim) = 1
    i2(nrmdim) = 1
    j1 = i1(1); j2 = i2(1)
    k1 = i1(2); k2 = i2(2)
    l1 = i1(3); l2 = i2(3)
    w0(j1:j2,k1:k2,l1:l2,1) = stress(iz,1)
    w0(j1:j2,k1:k2,l1:l2,2) = stress(iz,2)
    w0(j1:j2,k1:k2,l1:l2,3) = stress(iz,3)
    w0(j1:j2,k1:k2,l1:l2,4) = stress(iz,4)
    w0(j1:j2,k1:k2,l1:l2,5) = stress(iz,5)
    w0(j1:j2,k1:k2,l1:l2,6) = stress(iz,6)
  end do
  ! normal vectors
  i1 = i1node
  i2 = i2node
  call snormals( nrm, x, i1, i2 )
  area = sqrt( sum( nrm * nrm, 4 ) )
  tmp = 0.
  where ( area /= 0. ) tmp = 1. / area
  do i = 1, 3
    nrm(:,:,:,i) = nrm(:,:,:,i) * tmp
  end do
  ! strike vectors
  str = 0.
  str(:,:,:,1) = down(2) * nrm(:,:,:,3) - down(3) * nrm(:,:,:,2)
  str(:,:,:,2) = down(3) * nrm(:,:,:,1) - down(1) * nrm(:,:,:,3)
  str(:,:,:,3) = down(1) * nrm(:,:,:,2) - down(2) * nrm(:,:,:,1)
  tmp = sqrt( sum( str * str, 4 ) )
  where ( tmp /= 0. ) tmp = handed / tmp
  do i = 1, 3
    str(:,:,:,i) = str(:,:,:,i) * tmp
  end do
  ! dip vectors
  dip = 0.
  dip(:,:,:,1) = nrm(:,:,:,2) * str(:,:,:,3) - nrm(:,:,:,3) * str(:,:,:,2)
  dip(:,:,:,2) = nrm(:,:,:,3) * str(:,:,:,1) - nrm(:,:,:,1) * str(:,:,:,3)
  dip(:,:,:,3) = nrm(:,:,:,1) * str(:,:,:,2) - nrm(:,:,:,2) * str(:,:,:,1)
  tmp = sqrt( sum( dip * dip, 4 ) )
  where ( tmp /= 0. ) tmp = handed / tmp
  do i = 1, 3
    dip(:,:,:,i) = dip(:,:,:,i) * tmp
  end do
  do i = 1, 3
    j = mod( i , 3 ) + 1
    k = mod( i + 1, 3 ) + 1
    tt0(:,:,:,i) = &
      w0(:,:,:,i)   * nrm(:,:,:,i) + &
      w0(:,:,:,j+3) * nrm(:,:,:,k) + &
      w0(:,:,:,k+3) * nrm(:,:,:,j) + &
      tt0nsd(:,:,:,nrmdim) * nrm(:,:,:,i) + &
      tt0nsd(:,:,:,strdim) * str(:,:,:,i) + &
      tt0nsd(:,:,:,dipdim) * dip(:,:,:,i)
  end do
  do i = 1, 3
    r3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - hypoloc(i)
  end do
  r = sqrt( sum( r3 * r3, 4 ) )
  i1 = hypocenter
  i1(nrmdim) = 1
  j = i1(1)
  k = i1(2)
  l = i1(3)
  tn0 = sum( tt0(j,k,l,:) * nrm(j,k,l,:) )
  ts0 = norm( shiftdim( tt0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) )
  tn0 = max( -tn0, 0. )
  fs0 = fs(j,k,l)
  fd0 = fd(j,k,l)
  dc0 = dc(j,k,l)
  print *, 'S', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 )
  print *, 'dc: ', dc0, '>', 3 * dx * tn0 * ( fs0 - fd0 ) / miu0
  print *, 'rcrit: ', rcrit, '>', miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ** 2
  deallocate( tt0nsd, w0, str, dip, r3 )
  i1 = i1node
  i2 = i2node
  i1(nrmdim) = 1
  i2(nrmdim) = 1
  j1 = i1(1); j2 = i2(1)
  k1 = i1(2); k2 = i2(2)
  l1 = i1(3); l2 = i2(3)
  allocate( &
      tt(j1:j2,k1:k2,l1:l2,3), &
      tn3(j1:j2,k1:k2,l1:l2,3), &
      ts3(j1:j2,k1:k2,l1:l2,3), &
      tn(j1:j2,k1:k2,l1:l2), &
      ts(j1:j2,k1:k2,l1:l2), &
      ff(j1:j2,k1:k2,l1:l2), &
      ff2(j1:j2,k1:k2,l1:l2) )
  return
end if

!------------------------------------------------------------------------------!
! Zero slip velocity condition
i1 = i1node
i2 = i2node
i1(nrmdim) = hypocenter(nrmdim)
i2(nrmdim) = hypocenter(nrmdim)
j1 = i1(1); j2 = i2(1)
k1 = i1(2); k2 = i2(2)
l1 = i1(3); l2 = i2(3)
i1(nrmdim) = hypocenter(nrmdim) + 1
i2(nrmdim) = hypocenter(nrmdim) + 1
j3 = i1(1); j4 = i2(1)
k3 = i1(2); k4 = i2(2)
l3 = i1(3); l4 = i2(3)
tmp = area * ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) )
where ( tmp /= 0. ) tmp = 1. / tmp
do i = 1, 3
  tt(:,:,:,i) = tt0(:,:,:,i) + tmp * &
    ( v(j3:j4,k3:k4,l3:l4,i) + w1(j3:j4,k3:k4,l3:l4,i) &
    - v(j1:j2,k1:k2,l1:l2,i) - w1(j1:j2,k1:k2,l1:l2,i) )
end do
tn = sum( tt * nrm, 4 )
do i = 1, 3; tn3(:,:,:,i) = tn * nrm(:,:,:,i); end do
ts3 = tt - tn3
ts = sqrt( sum( ts3 * ts3, 4 ) )
!if ( .false. ) then ! Fault opening 
!  do i = 1, 3
!    tt(:,:,:,i) = tt(:,:,:,i) + tmp * &
!    ( u(j3:j4,k3:k4,l3:l4,i) - u(j1:j2,k1:k2,l1:l2,i) ) / dt
!  end do
!  tn = sum( tt * nrm, 4 )
!  where( tn > cohes ) tn = cohes
!  do i = 1, 3; tn3(:,:,:,i) = tn * nrm(:,:,:,i); end do
!end if
! Friction Law
tn = -tn
where( tn < 0. ) tn = 0.
ff = fd
where( uslip < dc ) ff = ff + ( 1. - uslip / dc ) * ( fs - fd )
ff = ff * tn + cohes
! Nucleation
if ( rcrit > 0. .and. vrup > 0. ) then
  ff2 = 1.
  if ( nclramp > 0 ) ff2 = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 )
  ff2 = ( 1. - ff2 ) * ts + ff2 * ( fd * tn + cohes )
  where ( r < min( rcrit, it * dt * vrup ) .and. ff2 < ff ) ff = ff2
end if
!if ( any( ff <= 0. ) ) print *, 'fault opening!'
! Shear traction bounded by friction
ff2 = 1.
where ( ts > ff ) ff2 = ff / ts
do i = 1, 3
  tt(:,:,:,i) = -tt0(:,:,:,i) + tn3(:,:,:,i) + ff2 * ts3(:,:,:,i)
  w1(j1:j2,k1:k2,l1:l2,i) = &
  w1(j1:j2,k1:k2,l1:l2,i) + tt(:,:,:,i) * area * rho(j1:j2,k1:k2,l1:l2)
  w1(j3:j4,k3:k4,l3:l4,i) = &
  w1(j3:j4,k3:k4,l3:l4,i) + tt(:,:,:,i) * area * rho(j3:j4,k3:k4,l3:l4)
end do
tt = v(j3:j4,k3:k4,l3:l4,:) + w1(j3:j4,k3:k4,l3:l4,:) &
   - v(j1:j2,k1:k2,l1:l2,:) - w1(j1:j2,k1:k2,l1:l2,:)
vslip = sqrt( sum( tt * tt, 4 ) )
uslip = uslip + dt * vslip
!uslipmax = maxval( abs( uslip ) )
!vslipmax = maxval( abs( vslip ) )
!tnmax = maxval( abs( tn ) )
!tsmax = maxval( abs( ts ) )

if ( truptol > 0. ) where ( trup = 0. .and. vslip > truptol ) trup = ( it + .5 ) * dt

end subroutine

