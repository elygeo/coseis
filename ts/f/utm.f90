! UTM projection, reference: John Snyder, 1987, USGS Professional Paper 1395
module utm_m
contains

! UTM projection
subroutine ll2utm( x, i1, i2, zone )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2, zone
real(8), parameter ::                                            &
  a   = 6378137.,                                                &
  b   = 6356752.3142,                                            &
  k0  = .9996,                                                   &
  pi  = 3.14159265,                                              &
  e2  = 1. - b*b / (a*a),                                        &
  ep2 = e2 / (1.-e2),                                            &
  j1  =  a-a*e2/256.*(64.+e2*(e2*5.+12.)),                       &
  j2  = -a*e2/768.*(288.+e2*(e2*25.+72.)),                       &
  j3  =  a*e2*e2*15./512.*(e2*3.+4.),                            &
  j4  = -a*e2*e2*e2*35./768.
real(8) :: e1, l0, sf, cf, sf2, cf2, s2f, c2f, t, t2, n, c, aa, m
integer :: j, k, l
e1 = ( 1. - sqrt(1.-e2) ) / ( 1. + sqrt(1.-e2) )
l0 = pi / 180. * ( ( zone - 1 ) * 6 - 180 + 3 )
x(:,:,:,i1) = x(:,:,:,i1) * pi / 180.
x(:,:,:,i2) = x(:,:,:,i2) * pi / 180.
do l = 1, size( x, 3 ) 
do k = 1, size( x, 2 ) 
do j = 1, size( x, 1 ) 
  sf  = sin( x(j,k,l,i2) )
  cf  = cos( x(j,k,l,i2) )
  s2f = sin( x(j,k,l,i2)*2. )
  c2f = cos( x(j,k,l,i2)*2. )
  sf2 = sf * sf
  cf2 = cf * cf
  t   = sf / cf
  t2  = t * t
  n   = a / sqrt( 1. - e2*sf2 )
  c   = ep2 * cf2
  aa  = (x(j,k,l,i1)-l0) * cf
  m   = j1*x(j,k,l,i2) + s2f*(j2 + c2f*(j3 + c2f*j4))
  x(j,k,l,i1) = k0*n*aa*(1.+aa*aa/6.*(c+1-t2+aa*aa*.05*(5.+c*72.-ep2*58.+t2*(t2-18.))))
  x(j,k,l,i2) = k0*(m+n*t*aa*aa*(.5+aa*aa/24.*(5.-t2+c*(c*4.+9.)+aa*aa/30.*(c*600.+61.-ep2*330.+t2*(t2-58.)))))
end do
end do
end do
x(:,:,:,i1) = x(:,:,:,i1) + 500000.
end subroutine

! Inverse UTM projection
subroutine utm2ll( x, i1, i2, zone )
implicit none
real, intent(inout) :: x(:,:,:,:)
integer, intent(in) :: i1, i2, zone
real(8), parameter ::                                            &
  a   = 6378137.,                                                &
  b   = 6356752.3142,                                            &
  k0  = .9996,                                                   &
  pi  = 3.14159265,                                              &
  e2  = 1. - b*b / (a*a),                                        &
  ep2 = e2 / (1.-e2),                                            &
  cmu = 1. / (k0*a*(1.-e2*.25*(1.+e2/16.*(3.+e2*1.25))))
real(8) :: e1, j1, j2, j3, j4, l0, s2f, c2f, sf, cf, sf2, cf2, t, t2, c, n, r, d, f1
integer :: j, k, l
e1 = ( 1. - sqrt(1.-e2) ) / ( 1. + sqrt(1.-e2) )
j1 = e1*.5*(3.-e1*e1*29./6.)
j2 = e1*e1*.125*(21.-e1*e1*1537./16.)
j3 = e1*e1*e1*151./24.
j4 = e1*e1*e1*e1*1097./64.
l0 = pi / 180. * ( (zone-1)*6 - 180 + 3 )
x(:,:,:,i1) = x(:,:,:,i1) - 500000.
x(:,:,:,i2) = x(:,:,:,i2) * cmu
do l = 1, size( x, 3 ) 
do k = 1, size( x, 2 ) 
do j = 1, size( x, 1 ) 
  s2f = sin( x(j,k,l,i2)*2. )
  c2f = cos( x(j,k,l,i2)*2. )
  f1  = x(j,k,l,i2) + s2f*(j1 + c2f*(j2 + c2f*(j3 + c2f*j4)))
  cf  = cos( f1 )
  sf  = sin( f1 )
  cf2 = cf * cf
  sf2 = sf * sf
  t   = sf / cf
  t2  = t * t
  c   = ep2 * cf2
  n   = a / sqrt(1.-e2*sf2)
  r   = ((1.-e2*sf2)**1.5) / (a*(1.-e2))
  d   = x(j,k,l,i1) / (n*k0)
  x(j,k,l,i1) = l0+(d-d*d*d/6.*(1.+t2*2.+c-d*d*.05*(5.+ep2*8.-c*(c*3.+2.)+t2*(t2*24.+28.))))/cf
  x(j,k,l,i2) = f1-n*t*r*d*d*(.5-d*d/24.*(5.+t2*3.-ep2*9.-c*(c*4.-10.)-d*d/30.*(61.-ep2*252.+t2*(t2*45.+90.)-c*(c*3.-298.))))
end do
end do
end do
x(:,:,:,i1) = x(:,:,:,i1) * 180. / pi
x(:,:,:,i2) = x(:,:,:,i2) * 180. / pi
end subroutine
end module

