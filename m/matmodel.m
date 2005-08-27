%------------------------------------------------------------------------------%
% MATMODEL

fprintf( 'Material model\n' )
matmax = material(1,1:3);
matmin = material(1,1:3);
s1(:) = 0.;
for iz = 1:size( material, 1 )
  [ i1, i2 ] = zoneselect( imat(iz,:), nhalo, np, hypocenter, nrmdim );
  rho0 = material(iz,1);
  vp   = material(iz,2);
  vs   = material(iz,3);
  matmax = max( matmax, material(iz,1:3) );
  matmin = min( matmin, material(iz,1:3) );
  miu0 = rho0 * vs * vs;
  lam0 = rho0 * ( vp * vp - 2 * vs * vs );
  yc0  = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / dx ^ 2;
  nu   = .5 * lam0 / ( lam0 + miu0 );
  j1 = i1(1); j2 = i2(1) - 1;
  k1 = i1(2); k2 = i2(2) - 1;
  l1 = i1(3); l2 = i2(3) - 1;
  s1(j1:j2,k1:k2,l1:l2) = rho0;
  lam(j1:j2,k1:k2,l1:l2) = lam0;
  miu(j1:j2,k1:k2,l1:l2) = miu0;
  yc(j1:j2,k1:k2,l1:l2) = yc0;
end
courant = dt * matmax(2) * sqrt( 3 ) / dx;   % TODO: check, make general
fprintf( 'courant: %g < 1\n', courant )
gamma = dt * viscosity;

s2(:) = 0.;
for iz = 1:size( operator, 1 )
  [ i1, i2 ] = zoneselect( ioper(iz,:), nhalo, np, hypocenter, nrmdim );
  op = operator(iz);
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  s2(j,k,l) = dfnc( op, x, x, dx, 1, 1, j, k, l );
end
if nrmdim
  i = hypocenter(nrmdim);
  switch nrmdim
  case 1, s2(i,:,:) = 0.; yc(i,:,:) = 0.;
  case 2, s2(:,i,:) = 0.; yc(:,i,:) = 0.;
  case 3, s2(:,:,i) = 0.; yc(:,:,i) = 0.;
  end
end

i2 = nl + 2 * nhalo - 1;
j1 = i2(1); j2 = i2(1) - 1
k1 = i2(2); k2 = i2(2) - 1
l1 = i2(3); l2 = i2(3) - 1
if bc(1), s1(1,:,:)  = s1(2,:,:);  s2(1,:,:)  = s2(2,:,:);  end
if bc(4), s1(j1,:,:) = s1(j2,:,:); s2(j1,:,:) = s2(j2,:,:); end
if bc(2), s1(:,1,:)  = s1(:,2,:);  s2(:,1,:)  = s2(:,2,:);  end
if bc(5), s1(:,k1,:) = s1(:,k2,:); s2(:,k1,:) = s2(:,k2,:); end
if bc(3), s1(:,:,1)  = s1(:,:,2);  s2(:,:,1)  = s2(:,:,2);  end
if bc(6), s1(:,:,l1) = s1(:,:,l2); s2(:,:,l1) = s2(:,:,l2); end

i1 = i1node;
i2 = i2node;
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);

yn(j,k,l) = 0.125 * ...
  ( s1(j,k,l) + s1(j-1,k-1,l-1) ...
  + s1(j-1,k,l) + s1(j,k-1,l-1) ...
  + s1(j,k-1,l) + s1(j-1,k,l-1) ...
  + s1(j,k,l-1) + s1(j-1,k-1,l) );
s1 = s1 .* s2;

rho(j,k,l) = 0.125 * ...
  ( s1(j,k,l) + s1(j-1,k-1,l-1) ...
  + s1(j-1,k,l) + s1(j,k-1,l-1) ...
  + s1(j,k-1,l) + s1(j-1,k,l-1) ...
  + s1(j,k,l-1) + s1(j-1,k-1,l) );

i = yn  ~= 0; yn(i)  = dt ./ yn(i);
i = rho ~= 0; rho(i) = dt ./ rho(i);
i = s2  ~= 0; s2(i)  = 1 ./ s2(i);
lam = lam .* s2;
miu = miu .* s2;

% PML damping
c1 =  8. / 15.;
c2 = -3. / 100.;
c3 =  1. / 1500.;
tune = 3.5;
hmean = 2. * matmin .* matmax ./ ( matmin + matmax );
damp = tune * hmean(3) / dx * ( c1 + ( c2 + c3 * npml ) * npml );
for i = 1:npml
  dampn = damp * ( i ./ npml ) .^ 2.;
  dampc = damp * .5 * ( ( i + i - 1. ) / npml ) .^ 2.;
  dn1(npml-i+1) = - 2. * dampn   ./ ( 2. + dt * dampn );
  dc1(npml-i+1) = ( 2. - dt * dampc ) ./ ( 2. + dt * dampc );
  dn2(npml-i+1) = 2. ./ ( 2. + dt * dampn );
  dc2(npml-i+1) = 2. * dt ./ ( 2. + dt * dampc );
end

