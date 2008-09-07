cell = .false.
fault = .false.
do i = 1, 3
select case( p%field )
case( 'x'    ); f => w1(:,:,:,i);   nc = 3; pass = 0
case( 'x1'   ); f => w1(:,:,:,1);   nc = 1; pass = 0
case( 'x2'   ); f => w1(:,:,:,2);   nc = 1; pass = 0
case( 'x3'   ); f => w1(:,:,:,3);   nc = 1; pass = 0
case( 'rho'  ); f => mr;            nc = 1; pass = 0; cell = .true.
case( 'vp'   ); f => s1;            nc = 1; pass = 0; cell = .true.
case( 'vs'   ); f => s2;            nc = 1; pass = 0; cell = .true.
case( 'lam'  ); f => lam;           nc = 1; pass = 0; cell = .true.
case( 'mu'   ); f => mu;            nc = 1; pass = 0; cell = .true.
case( 'gam'  ); f => gam;           nc = 1; pass = 0; cell = .true.

case( 'nhat' ); f => nhat(:,:,:,i); nc = 3; pass = 0; fault = .true.
case( 'mus'  ); f => mus;           nc = 1; pass = 0; fault = .true.
case( 'mud'  ); f => mud;           nc = 1; pass = 0; fault = .true.
case( 'dc'   ); f => dc;            nc = 1; pass = 0; fault = .true.
case( 'co'   ); f => co;            nc = 1; pass = 0; fault = .true.
case( 'sxx'  ); f => t1(:,:,:,1);   nc = 1; pass = 0; fault = .true.
case( 'syy'  ); f => t1(:,:,:,2);   nc = 1; pass = 0; fault = .true.
case( 'szz'  ); f => t1(:,:,:,3);   nc = 1; pass = 0; fault = .true.
case( 'syz'  ); f => t2(:,:,:,1);   nc = 1; pass = 0; fault = .true.
case( 'szx'  ); f => t2(:,:,:,2);   nc = 1; pass = 0; fault = .true.
case( 'sxy'  ); f => t2(:,:,:,3);   nc = 1; pass = 0; fault = .true.
case( 'ts1'  ); f => t3(:,:,:,1);   nc = 1; pass = 0; fault = .true.
case( 'ts2'  ); f => t3(:,:,:,2);   nc = 1; pass = 0; fault = .true.


case( 'pv2'  ); f => pv;            nc = 1; pass = 1
case( 'vm2'  ); f => s1;            nc = 1; pass = 1
case( 'w'    );                     nc = 6; pass = 1; cell = .true.
  if ( i <= 3 ) f => w1(:,:,:,i)
  if ( i >  3 ) f => w2(:,:,:,i)
case( 'wm2'  ); f => s2;            nc = 1; pass = 1; cell = .true.            
case( 'sv'   ); f => t1(:,:,:,i);   nc = 3; pass = 1; fault = .true.
case( 'su'   ); f => t2(:,:,:,i);   nc = 3; pass = 1; fault = .true.
case( 'svm'  ); f => f1;            nc = 1; pass = 1; fault = .true.
case( 'sum'  ); f => f2;            nc = 1; pass = 1; fault = .true.
case( 'psv'  ); f => psv;           nc = 1; pass = 1; fault = .true.

case( 'gamt' ); f => gam;           nc = 1; pass = 2
case( 'mr'   ); f => mr;            nc = 1; pass = 2
case( 'v'    ); f => vv(:,:,:,i);   nc = 3; pass = 2
case( 'u'    ); f => uu(:,:,:,i);   nc = 3; pass = 2
case( 'a'    ); f => w1(:,:,:,i);   nc = 3; pass = 2
case( 'um2'  ); f => s1;            nc = 1; pass = 2         
case( 'am2'  ); f => s2;            nc = 1; pass = 2
case( 'ts'   ); f => t3(:,:,:,i);   nc = 3; pass = 2; fault = .true.
case( 'sa'   ); f => t2(:,:,:,i);   nc = 3; pass = 2; fault = .true.
case( 'tsm'  ); f => ts;            nc = 1; pass = 2; fault = .true.
case( 'sam'  ); f => f2;            nc = 1; pass = 2; fault = .true.
case( 'tn'   ); f => tn;            nc = 1; pass = 2; fault = .true.
case( 'fr'   ); f => f1;            nc = 1; pass = 2; fault = .true.
case( 'sl'   ); f => sl;            nc = 1; pass = 2; fault = .true.
case( 'trup' ); f => trup;          nc = 1; pass = 2; fault = .true.
case( 'tarr' ); f => tarr;          nc = 1; pass = 2; fault = .true.
case default
  write( 0, * ) 'error: unknown output field: ', p%field
  stop
end select
p%nc = nc
p%pass = pass
p%fault = fault
p%c(i)%f => f
if ( nc == 1 ) exit
end do

