%------------------------------------------------------------------------------%
% MATMODEL

disp('Material model')
u   = repmat( zero, [ n 3 ] );
v   = repmat( zero, [ n 3 ] );
w1  = repmat( zero, [ n 3 ] );
w2  = repmat( zero, [ n 3 ] );
s1  = repmat( zero, n );
s2  = repmat( zero, n );
rho = repmat( zero, n );
miu = repmat( zero, n );
lam = repmat( zero, n );
vsmax = 0;
vsmin = 0;
for iz = 1:size( material, 1 )
  zone = material(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  rho0  = material(iz,1);
  vp    = material(iz,2);
  vs    = material(iz,3);
  vsmax = max( vsmax, vs );
  vsmin = max( vsmin, vs );
  miu0  = rho0 .* vs .* vs;
  lam0  = rho0 .* ( vp .* vp - 2 * vs .* vs );
  nu    = .5 * lam0 / ( lam0 + miu0 );
  courant = dt * vp * sqrt( 3 ) / h;   % TODO: check, make general
  fprintf( 1, 'courant: %g < 1\n', courant )
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  rho(j,k,l) = dt / rho0;
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  lam(j,k,l) = lam0;
  miu(j,k,l) = miu0;
end
l = hypocenter(3);
k = hypocenter(2);
j = hypocenter(1);
rho0 = dt / rho(j,k,l);
lam0 = lam(j,k,l);
miu0 = miu(j,k,l);
gamma = dt * viscosity;
vs0 = 1 / ( 1 / vsmin + 1 / vsmax );

y = lam + 2 * lam;
i = y ~= 0;
y(i) = 1 ./ y(i);
y = y .* miu .* ( lam + miu );

for iz = 1:size( operator, 1 )
  zone = [ operator{iz,8:13} ];
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  bc = [ operator{iz,2:7} ];
  opi1(iz,:) = i1;
  opi2(iz,:) = i2;
  switch operator{iz,1}
  case { 'g', 'r' }
    l = i1(3):i2(3)-1;
    k = i1(2):i2(2)-1;
    j = i1(1):i2(1)-1;
    switch operator{iz,1}
    case 'g', s2(j,k,l) = dncg( x, 1, x, 1, j, k, l );
    case 'r', s2(j,k,l) = dncr( x, 1, x, 1, j, k, l );
    end
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    s1(j,k,l) = 0.125 * ( ...
      s2(j,k,l) + s2(j-1,k-1,l-1) + ...
      s2(j-1,k,l) + s2(j,k-1,l-1) + ...
      s2(j,k-1,l) + s2(j-1,k,l-1) + ...
      s2(j,k,l-1) + s2(j-1,k-1,l) );
  case 'h'
    l = i1(3):i2(3)-1;
    k = i1(2):i2(2)-1;
    j = i1(1):i2(1)-1;
    s2(j,k,l) = h;
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    s1(j,k,l) = h;
  case '4'
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    s2(j,k,l) = h;
    s1(j,k,l) = h;
  otherwise
    error( [ 'unknown operator type: ' operator{iz,1} ] )
  end
  nn = [ n 3 ];
  nn(1) = npml;
  if bc(1), f1 = repmat( zero, nn ); e1 = repmat( zero, nn ); end
  if bc(4), f4 = repmat( zero, nn ); e4 = repmat( zero, nn ); end
  nn = [ n 3 ];
  nn(2) = npml;
  if bc(2), f2 = repmat( zero, nn ); e2 = repmat( zero, nn ); end
  if bc(5), f5 = repmat( zero, nn ); e5 = repmat( zero, nn ); end
  nn = [ n 3 ];
  nn(3) = npml;
  if bc(3), f3 = repmat( zero, nn ); e3 = repmat( zero, nn ); end
  if bc(6), f6 = repmat( zero, nn ); e6 = repmat( zero, nn ); end
end

if s2(s2<0); disp( 'Negative cell volume!' ), end
i = s1 ~= 0; s1(i) = 1 ./ s1(i);
i = s2 ~= 0; s2(i) = 1 ./ s2(i);
rho = rho .* s1;
lam = lam .* s2;
miu = miu .* s2;
s1(:) = 0;
s2(:) = 0;

% PML damping
c1 =  8/15;
c2 = -3/100;
c3 =  1/1500;
tune = 3.5;
damp = tune * vs0 / h * ( c1 + ( c2 + c3 * npml ) * npml );
i = npml:-1:1;
dampn = damp * ( i ./ npml ) .^ 2;
dampc = .5 * ( dampn(1:end-1) + dampn(2:end) );
dampn1 = ( 2 - dt * dampn ) ./ ( 2 + dt * dampn );
dampc1 = ( 2 - dt * dampc ) ./ ( 2 + dt * dampc );
dampn2 = 2 * dt ./ ( 2 + dt * dampn );
dampc2 = 2 * dt ./ ( 2 + dt * dampc );

