%------------------------------------------------------------------------------%
% MATMODEL

fprintf( 'Material model\n' )

% Material arrays
rho(:) = 0.;
s1(:) = 0.;
s2(:) = 0.;
for iz = 1:size( material, 1 )
  [ i1, i2 ] = zone( imat(iz,:), nn, offset, hypocenter, nrmdim );
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  rho(j1:j2,k1:k2,l1:l2) = material(iz,1);
  s1(j1:j2,k1:k2,l1:l2)  = material(iz,2);
  s2(j1:j2,k1:k2,l1:l2)  = material(iz,3);
  rho0 = material(iz,1);
  vp   = material(iz,2);
  vs   = material(iz,3);
end

% Matrial extremes
i = rho > 0.; matmin(1) = min( rho(i) ); matmax(1) = max( rho(i) );
i = s1 > 0.;  matmin(2) = min( s1(i) );  matmax(2) = max( s1(i) );
i = s2 > 0.;  matmin(3) = min( s2(i) );  matmax(3) = max( s2(i) );

% Check Courant stability condition. TODO: check, make general
courant = dt * matmax(2) * sqrt( 3 ) / dx;
fprintf( '  Courant: 1 >%11.4e\n', courant )

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

% Hourglass constant
y = 12. * dx * dx * ( lam + 2. * mu );
i = y ~= 0.;
y(i) = 1. ./ y(i);
y = mu .* ( lam + mu ) .* y;

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

% Make sure cell volumes and Y are zero on the fault
if nrmdim
  i = hypocenter(nrmdim);
  switch nrmdim
  case 1, s2(i,:,:) = 0.; y(i,:,:) = 0.;
  case 2, s2(:,i,:) = 0.; y(:,i,:) = 0.;
  case 3, s2(:,:,i) = 0.; y(:,:,i) = 0.;
  end
end

% Ghost cell volumes are NOT zero for PML
i2 = nm - 1;
j1 = i2(1); j2 = i2(1);
k1 = i2(2); k2 = i2(2);
l1 = i2(3); l2 = i2(3);
if bc(1), s2(1,:,: ) = s2(2,:,: ); end
if bc(4), s2(j1,:,:) = s2(j2,:,:); end
if bc(2), s2(:,1,: ) = s2(:,2,: ); end
if bc(5), s2(:,k1,:) = s2(:,k2,:); end
if bc(3), s2(:,:,1 ) = s2(:,:,2 ); end
if bc(6), s2(:,:,l1) = s2(:,:,l2); end

% Node volume
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

% Multipy Y by cell volume
y = y .* s2;

% Devide Lame constants by cell volume
i = s2  ~= 0.;
s2(i)  = 1. ./ s2(i);
lam = lam .* s2;
mu = mu .* s2;

% Node mass ratio
rho = rho .* s1;
i = rho ~= 0.;
rho(i) = 1. ./ rho(i);

s1(:) = 0.;
s2(:) = 0.;

% PML damping
if npml
  c1 =  8. / 15.;
  c2 = -3. / 100.;
  c3 =  1. / 1500.;
  tune = 3.5;
  pmlp = 2.;
  hmean = 2. * matmin .* matmax ./ ( matmin + matmax );
  damp = tune * hmean(3) / dx * ( c1 + ( c2 + c3 * npml ) * npml ) / npml^pmlp;
  for i = 1:npml
    dampn = damp *   i ^ pmlp;
    dampc = damp * ( i ^ pmlp + ( i - 1 ) ^ pmlp ) / 2.;
    dn1(npml-i+1) = - 2. * dampn        / ( 2. + dt * dampn );
    dc1(npml-i+1) = ( 2. - dt * dampc ) / ( 2. + dt * dampc );
    dn2(npml-i+1) =   2.                / ( 2. + dt * dampn );
    dc2(npml-i+1) =   2. * dt           / ( 2. + dt * dampc );
  end
end

