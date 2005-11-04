% Material model

fprintf( 'Material model\n' )

FIXME

% Input
mr(:) = 0.;
s1(:) = 0.;
s2(:) = 0.;
rho1 = 1e9;
rho2 = 0.;
vp1 = 1e9;
vp2 = 0.;
vs1 = 1e9;
vs2 = 0.;

for iz = 1:size( fieldin, 1 )
if readfile(iz), error 'read not implemented', end
[ i1, i2 ] = zone( i1in(iz,:), i2in(iz,:), nn, nnoff, ihypo, ifn );
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
switch fieldin{iz}
case 'rho'
  mr(j1:j2,k1:k2,l1:l2) = inval(iz);
  rho1 = min( rho1, inval(iz) );
  rho2 = max( rho2, inval(iz) );
case 'vp'
  s1(j1:j2,k1:k2,l1:l2) = inval(iz);
  vp1 = min( vp1, inval(iz) );
  vp2 = max( vp2, inval(iz) );
case 'vs'
  s2(j1:j2,k1:k2,l1:l2) = inval(iz);
  vs1 = min( vs1, inval(iz) );
  vs2 = max( vs2, inval(iz) );
end
end

% Hypocenter properties
j = ihypo(1);
k = ihypo(2);
l = ihypo(3);
rho = mr(j,k,l);
vp  = s1(j,k,l);
vs  = s2(j,k,l);

% Lame parameters
s2 = mr .* s2 .* s2;
s1 = mr .* ( s1 .* s1 ) - 2. .* s2;

% Average Lame parameters on cell centers
lam(:) = 0.;
mu(:) = 0.;
i1 = i1cell;
i2 = i2cell;
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);
lam(j,k,l) = 0.125 * ...
  ( s1(j,k,l) + s1(j+1,k+1,l+1) ...
  + s1(j+1,k,l) + s1(j,k+1,l+1) ...
  + s1(j,k+1,l) + s1(j+1,k,l+1) ...
  + s1(j,k,l+1) + s1(j+1,k+1,l) );
mu(j,k,l) = 0.125 * ...
  ( s2(j,k,l) + s2(j+1,k+1,l+1) ...
  + s2(j+1,k,l) + s2(j,k+1,l+1) ...
  + s2(j,k+1,l) + s2(j+1,k,l+1) ...
  + s2(j,k,l+1) + s2(j+1,k+1,l) );

% Cell volume
s2(:) = 0.;
for iz = 1:size( oper, 1 )
  [ i1, i2 ] = zone( i1oper(iz,:), i2oper(iz,:), nn, nnoff, ihypo, ifn );
  i2 = i2 - 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = diffnc( oper(iz), x, x, dx, 1, 1, j, k, l );
end
if ifn
  i = ihypo(ifn);
  switch ifn
  case 1, s2(i,:,:) = 0.;
  case 2, s2(:,i,:) = 0.;
  case 3, s2(:,:,i) = 0.;
  end
end

% Node volume
s1(:) = 0.;
i1 = i1node;
i2 = i2node;
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);
s1(j,k,l) = 0.125 * ...
  ( s2(j,k,l) + s2(j-1,k-1,l-1) ...
  + s2(j-1,k,l) + s2(j,k-1,l-1) ...
  + s2(j,k-1,l) + s2(j-1,k,l-1) ...
  + s2(j,k,l-1) + s2(j-1,k-1,l) );

% Hourglass constant. FIXME off by factor of 8?
y = 6. * dx * dx * ( lam + 2. * mu );
i = y ~= 0.;
y(i) = 1. ./ y(i);
y = 4. * mu .* ( lam + mu ) .* y .* s2;

% Divide Lame parameters by cell volume
i = s2 ~= 0.;
s2(i) = 1. ./ s2(i);
lam = lam .* s2;
mu = mu .* s2;

% Node mass ratio
mr = mr .* s1;
i = mr ~= 0.;
mr(i) = 1. ./ mr(i);

s1(:) = 0.;
s2(:) = 0.;

