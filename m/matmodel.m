%------------------------------------------------------------------------------%
% MATMODEL

fprintf( 'Material model\n' )

% Material arrays
rho(:) = 0.;
s1(:) = 0.;
s2(:) = 0.;
if matdir
  i1 = i1cell;
  i2 = i2cell + 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  rho(j1:j2,k1:k2,l1:l2) = bread( matdir, 'rho' );
  s1(j1:j2,k1:k2,l1:l2)  = bread( matdir, 'vp' );
  s2(j1:j2,k1:k2,l1:l2)  = bread( matdir, 'vs' );
end
for iz = 1:size( material, 1 )
  [ i1, i2 ] = zone( imat(iz,:), nn, offset, hypocenter, nrmdim );
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  rho(j1:j2,k1:k2,l1:l2) = material(iz,1);
  s1(j1:j2,k1:k2,l1:l2)  = material(iz,2);
  s2(j1:j2,k1:k2,l1:l2)  = material(iz,3);
end

% Matrial extremes
i = rho > 0.; matmin(1) = min( rho(i) ); matmax(1) = max( rho(i) );
i = s1 > 0.;  matmin(2) = min( s1(i) );  matmax(2) = max( s1(i) );
i = s2 > 0.;  matmin(3) = min( s2(i) );  matmax(3) = max( s2(i) );

% Lame parameters
s2 = rho .* s2 .* s2;
s1 = rho .* ( s1 .* s1 ) - 2. .* s2;

% Save mu at hypocenter
i1 = hypocenter;
mu0 = s2( i1(1), i1(2), i1(3) );

% Average Lame parameters on cell centers
lam(:) = 0.;
m(:)  = 0.;
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
for iz = 1:size( operator, 1 )
  [ i1, i2 ] = zone( ioper(iz,:), nn, offset, hypocenter, nrmdim );
  i2 = i2 - 1;
  op = operator(iz);
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = dfnc( op, x, x, dx, 1, 1, j, k, l );
end

% Make sure cell volumes are zero on the fault
if nrmdim
  i = hypocenter(nrmdim);
  switch nrmdim
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
rho = rho .* s1;
i = rho ~= 0.;
rho(i) = 1. ./ rho(i);

s1(:) = 0.;
s2(:) = 0.;

