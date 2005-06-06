%------------------------------------------------------------------------------%
% MATMODEL

fprintf( 'Material model\n' )
u   = repmat( zero, [ n 3 ] );
v   = repmat( zero, [ n 3 ] );
w1  = repmat( zero, [ n 3 ] );
w2  = repmat( zero, [ n 3 ] );
s1  = repmat( zero, n );
s2  = repmat( zero, n );
rho = repmat( zero, n );
miu = repmat( zero, n );
lam = repmat( zero, n );
matmax = material(1,1:3);
matmin = material(1,1:3);
for iz = 1:size( material, 1 )
  zone = material(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  rho0  = material(iz,1);
  vp    = material(iz,2);
  vs    = material(iz,3);
  matmax = max( matmax, material(iz,1:3) );
  matmin = min( matmin, material(iz,1:3) );
  miu0  = rho0 .* vs .* vs;
  lam0  = rho0 .* ( vp .* vp - 2 * vs .* vs );
  nu    = .5 * lam0 / ( lam0 + miu0 );
  courant = dt * vp * sqrt( 3 ) / h;   % TODO: check, make general
  fprintf( 'courant: %g < 1\n', courant )
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  rho(j,k,l) = 1 / rho0;
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  lam(j,k,l) = lam0;
  miu(j,k,l) = miu0;
end

for iz = 1:size( operator, 1 )
  zone = [ operator{iz,2:7} ];
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  opi1(iz,:) = i1;
  opi2(iz,:) = i2;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  switch operator{iz,1}
  case { 'g', 'r' }, w1(j,k,l,1) = 1;
  case   'h',        w1(j,k,l,1) = h^2;
  otherwise error operator
  end
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==hypocenter(1)) = [];
  case 2, k(k==hypocenter(2)) = [];
  case 3, l(l==hypocenter(3)) = [];
  end
  switch operator{iz,1}
  case { 'g', 'r' }, w2(j,k,l,1) = 1;
  case   'h',        w2(j,k,l,1) = h^2;
  otherwise error operator
  end
end
i1 = i1full;
i2 = i2full;
l = i1(3):i2(3)-1;
k = i1(2):i2(2)-1;
j = i1(1):i2(1)-1;
i = 0:npml-1;
switch nrmdim
case 1, j(j==hypocenter(1)) = [];
case 2, k(k==hypocenter(2)) = [];
case 3, l(l==hypocenter(3)) = [];
end
s2(j,k,l) = dncg( x, 1, x, 1, j, k, l );
if s2(s2<0); fprinf( 'Negative cell volume!\n' ), end
if bc(1), ji = j(i+1);   w2(ji,k,l) = h^2; end
if bc(4), ji = j(end-i); w2(ji,k,l) = h^2; end
if bc(2), ki = k(i+1);   w2(j,ki,l) = h^2; end
if bc(5), ki = k(end-i); w2(j,ki,l) = h^2; end
if bc(3), li = l(i+1);   w2(j,k,li) = h^2; end
if bc(6), li = l(end-i); w2(j,k,li) = h^2; end
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);
s1(j,k,l,) = 0.125 * ( ...
  s2(j,k,l) + s2(j-1,k-1,l-1) + ...
  s2(j-1,k,l) + s2(j,k-1,l-1) + ...
  s2(j,k-1,l) + s2(j-1,k,l-1) + ...
  s2(j,k,l-1) + s2(j-1,k-1,l) );
if bc(1), ji = j(i+1);   w1(ji,k,l) = h^2; end
if bc(4), ji = j(end-i); w1(ji,k,l) = h^2; end
if bc(2), ki = k(i+1);   w1(j,ki,l) = h^2; end
if bc(5), ki = k(end-i); w1(j,ki,l) = h^2; end
if bc(3), li = l(i+1);   w1(j,k,li) = h^2; end
if bc(6), li = l(end-i); w1(j,k,li) = h^2; end
i = s1 ~= 0; s1(i) = w1(i) ./ s1(i);
i = s2 ~= 0; s2(i) = w2(i) ./ s2(i);
w1(:) = 0;
w2(:) = 0;

l = hypocenter(3);
k = hypocenter(2);
j = hypocenter(1);
rho0 = 1 / rho(j,k,l);
lam0 = lam(j,k,l);
miu0 = miu(j,k,l);
gamma = dt * viscosity;

hgy = 6 * ( lam + 2 * lam );
i = hgy ~= 0;
hgy(i) = 1 ./ hgy(i);
hgy = hgy .* miu .* ( lam + miu );

mdt = rho .* s1 * dt;
lam = lam .* s2;
miu = miu .* s2;
hgy = hgy * dt / h ^ 2;
s1(:) = 0;
s2(:) = 0;

if length( locknodes )
  locknodes(downdim,1:3) = 0;
  if n(1) < 5, locknodes([1 4],1:3) = 0; end
  if n(2) < 5, locknodes([2 5],1:3) = 0; end
  if n(3) < 5, locknodes([3 6],1:3) = 0; end
end
for iz = 1:size( locknodes, 1 )
  zone = locknodes(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  locki(:,:,iz) = [ i1; i2 ];
end

% PML damping
c1 =  8/15;
c2 = -3/100;
c3 =  1/1500;
tune = 0;
tune = 3.5;
hmean = 2 * matmin .* matmax ./ ( matmin + matmax );
damp = tune * hmean(3) / h * ( c1 + ( c2 + c3 * npml ) * npml );
i = npml:-1:1;
dampn = damp * ( i ./ npml ) .^ 2;
dampc = .5 * ( dampn + [ dampn(2:end) 0 ] );
dn1 = - 2 * dampn   ./ ( 2 + dt * dampn );
dc1 = ( 2 - dt * dampc ) ./ ( 2 + dt * dampc );
dn2 = 2 ./ ( 2 + dt * dampn );
dc2 = 2 * dt ./ ( 2 + dt * dampc );
nn = [ n 3 ];
nn(1) = npml;
if bc(1), p1 = repmat( zero, nn ); g1 = repmat( zero, nn ); end
if bc(4), p4 = repmat( zero, nn ); g4 = repmat( zero, nn ); end
nn = [ n 3 ];
nn(2) = npml;
if bc(2), p2 = repmat( zero, nn ); g2 = repmat( zero, nn ); end
if bc(5), p5 = repmat( zero, nn ); g5 = repmat( zero, nn ); end
nn = [ n 3 ];
nn(3) = npml;
if bc(3), p3 = repmat( zero, nn ); g3 = repmat( zero, nn ); end
if bc(6), p6 = repmat( zero, nn ); g6 = repmat( zero, nn ); end

