%------------------------------------------------------------------------------%
% MATMODEL

disp('Material model')
m = repmat( zero, [ n 3 ] );
for iz = 1:size( material, 1 )
  [ i1, i2 ] = zoneselect( material(iz,:), 3, core, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  rho   = material(iz,1);
  vp    = material(iz,2);
  vs    = material(iz,3);
  miu0  = rho .* vs .* vs;
  lam0  = rho .* ( vp .* vp - 2 * vs .* vs );
  nu    = .5 * lam0 / ( lam0 + miu0 );
  courant = dt * vp * sqrt( 3 ) / h;   % TODO: check, make general
  fprintf( 1, 'courant: %g < 1\n', courant )
  m(j,k,l,1) = dt / rho;
  m(j,k,l,2) = lam0;
  m(j,k,l,3) = miu0;
end
j = hypocenter(1);
k = hypocenter(2);
l = hypocenter(3);
rho0 = 1 / m(j,k,l,1);
lam0 = m(j,k,l,2);
miu0 = m(j,k,l,3);

m0 = m;
vc = repmat( zero, n );
vn = repmat( zero, n );
for iz = 1:size( operator, 1 )
  [ i1, i2 ] = zoneselect( [ operator{iz,2:7} ], 0, core, hypocenter, nrmdim );
  opi1(iz,:) = i1;
  opi2(iz,:) = i2;
  switch operator{iz,1}
  case { 'som', 'rectangular' }
    j  = i1(1):i2(1)-1;
    k  = i1(2):i2(2)-1;
    l  = i1(3):i2(3)-1;
    switch operator{iz,1}
    case 'som',         vc(j,k,l) = dncg( x, 1, x, 1, j, k, l );
    case 'rectangular', vc(j,k,l) = dncr( x, 1, x, 1, j, k, l );
    end
    i = 2:3;
    m(j,k,l,i) = 0.125 * ( ...
      m0(j,k,l,i) + m0(j+1,k+1,l+1,i) + ...
      m0(j+1,k,l,i) + m0(j,k+1,l+1,i) + ...
      m0(j,k+1,l,i) + m0(j+1,k,l+1,i) + ...
      m0(j,k,l+1,i) + m0(j+1,k+1,l,i) );
    j  = i1(1):i2(1);
    k  = i1(2):i2(2);
    l  = i1(3):i2(3);
    vn(j,k,l) = 0.125 * ( ...
      vc(j,k,l) + vc(j-1,k-1,l-1) + ...
      vc(j-1,k,l) + vc(j,k-1,l-1) + ...
      vc(j,k-1,l) + vc(j-1,k,l-1) + ...
      vc(j,k,l-1) + vc(j-1,k-1,l) );
  case 'constant'
    j  = i1(1):i2(1)-1;
    k  = i1(2):i2(2)-1;
    l  = i1(3):i2(3)-1;
    vc(j,k,l) = h;
    j  = i1(1):i2(1);
    k  = i1(2):i2(2);
    l  = i1(3):i2(3);
    vn(j,k,l) = h;
  case 'staggered'
    j  = i1(1):i2(1);
    k  = i1(2):i2(2);
    l  = i1(3):i2(3);
    vc(j,k,l) = h;
    vn(j,k,l) = h;
  end
end

if vc(vc<0); disp( 'Negative cell volume!' ), end
i = vn ~= 0; vn(i) = 1 ./ vn(i);
i = vc ~= 0; vc(i) = 1 ./ vc(i);
m(:,:,:,1) = m(:,:,:,1) .* vn;
m(:,:,:,2) = m(:,:,:,2) .* vc;
m(:,:,:,3) = m(:,:,:,3) .* vc;
clear vn vc m0

