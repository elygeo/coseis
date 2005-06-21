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
yc  = repmat( zero, n );
yn  = repmat( zero, n );
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
  yc0   = miu0 * ( lam0 + miu0 ) / 6 / ( lam0 + 2 * miu0 ) * 4 / h ^ 2;
  nu    = .5 * lam0 / ( lam0 + miu0 );
  courant = dt * vp * sqrt( 3 ) / h;   % TODO: check, make general
  fprintf( 'courant: %g < 1\n', courant )
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  s1(j,k,l) = rho0;
  lam(j,k,l) = lam0;
  miu(j,k,l) = miu0;
  yc(j,k,l) = yc0;
end
l = hypocenter(3);
k = hypocenter(2);
j = hypocenter(1);
rho0 = s1(j,k,l);
lam0 = lam(j,k,l);
miu0 = miu(j,k,l);
gamma = dt * viscosity;

for iz = 1:size( operator, 1 )
  zone = [ operator{iz,2:7} ];
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==hypocenter(1)) = [];
  case 2, k(k==hypocenter(2)) = [];
  case 3, l(l==hypocenter(3)) = [];
  end
  switch operator{iz,1}
  case 'g', s2(j,k,l) = dng( x, 1, x, 1, j, k, l );
  case 'r', s2(j,k,l) = dnr( x, 1, x, 1, j, k, l );
  case 'h', s2(j,k,l) = h ^ 3;
  otherwise error operator
  end
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  opi1(iz,:) = i1;
  opi2(iz,:) = i2;
end

i1 = halo1 + 1;
i2 = halo1 + ncore;

l = i1(3)-1:i2(3);
k = i1(2)-1:i2(2);
j = i1(1)-1:i2(1);

if bc(1), ji = j(1);   s1(ji,k,l) = s1(ji+1,k,l); s2(ji,k,l) = s1(ji+1,k,l); end
if bc(1), ji = j(1);   s1(ji,k,l) = s1(ji+1,k,l); s2(ji,k,l) = s1(ji+1,k,l); end
if bc(4), ji = j(end); s1(ji,k,l) = s1(ji-1,k,l); s2(ji,k,l) = s1(ji-1,k,l); end
if bc(2), ki = k(1);   s1(j,ki,l) = s1(j,ki+1,l); s2(j,ki,l) = s1(j,ki+1,l); end
if bc(5), ki = k(end); s1(j,ki,l) = s1(j,ki-1,l); s2(j,ki,l) = s1(j,ki-1,l); end
if bc(3), li = l(1);   s1(j,k,li) = s1(j,k,li+1); s2(j,k,li) = s1(j,k,li+1); end
if bc(6), li = l(end); s1(j,k,li) = s1(j,k,li-1); s2(j,k,li) = s1(j,k,li-1); end

l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);

yn(j,k,l) = 0.125 * ( ...
  s1(j,k,l) + s1(j-1,k-1,l-1) + ...
  s1(j-1,k,l) + s1(j,k-1,l-1) + ...
  s1(j,k-1,l) + s1(j-1,k,l-1) + ...
  s1(j,k,l-1) + s1(j-1,k-1,l) );
s1 = s1 .* s2;
rho(j,k,l) = 0.125 * ( ...
  s1(j,k,l) + s1(j-1,k-1,l-1) + ...
  s1(j-1,k,l) + s1(j,k-1,l-1) + ...
  s1(j,k-1,l) + s1(j-1,k,l-1) + ...
  s1(j,k,l-1) + s1(j-1,k-1,l) );
i = yn  ~= 0; yn(i)  = dt ./ yn(i);
i = rho ~= 0; rho(i) = dt ./ rho(i);

i = s2 ~= 0; s2(i) = 1 ./ s2(i);
lam = lam .* s2;
miu = miu .* s2;

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
p1 = []; p2 = []; p3 = []; p4 = []; p5 = []; p6 = [];
g1 = []; g2 = []; g3 = []; g4 = []; g5 = []; g6 = [];
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

