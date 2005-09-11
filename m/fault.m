%------------------------------------------------------------------------------%
% FAULT

if ~nrmdim; return; end

if init

init = 0;
fprintf( 'Initialize fault\n' )

% Friction model
fs(:) = 0;
fd(:) = 0;
dc(:) = 0;
co(:) = 1e9;
if fricdir
  i1 = i1nodepml;
  i2 = i2nodepml;
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  fs(j1:j2,k1:k2,l1:l2) = bread( fricdir, 'fs' );
  fd(j1:j2,k1:k2,l1:l2) = bread( fricdir, 'fd' );
  dc(j1:j2,k1:k2,l1:l2) = bread( fricdir, 'dc' );
  co(j1:j2,k1:k2,l1:l2) = bread( fricdir, 'co' );
end
for iz = 1:size( friction, 1 )
  [ i1, i2 ] = zone( ifric(iz,:), nn, offset, hypocenter, nrmdim );
  i1 = max( i1, i1nodepml );
  i2 = min( i2, i2nodepml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  fs(j1:j2,k1:k2,l1:l2) = friction(iz,1);
  fd(j1:j2,k1:k2,l1:l2) = friction(iz,2);
  dc(j1:j2,k1:k2,l1:l2) = friction(iz,3);
  co(j1:j2,k1:k2,l1:l2) = friction(iz,4);
end

% Prestress
t1(:) = 0.;
t2(:) = 0.;
if stressdir
  i1 = i1nodepml;
  i2 = i2nodepml;
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  t1(j1:j2,k1:k2,l1:l2,1) = bread( stressdir, 'xx' );
  t1(j1:j2,k1:k2,l1:l2,2) = bread( stressdir, 'yy' );
  t1(j1:j2,k1:k2,l1:l2,3) = bread( stressdir, 'zz' );
  t2(j1:j2,k1:k2,l1:l2,1) = bread( stressdir, 'yz' );
  t2(j1:j2,k1:k2,l1:l2,2) = bread( stressdir, 'zx' );
  t2(j1:j2,k1:k2,l1:l2,3) = bread( stressdir, 'xy' );
end
for iz = 1:size( stress, 1 )
  [ i1, i2 ] = zone( istress(iz,:), nn, offset, hypocenter, nrmdim );
  i1 = max( i1, i1nodepml );
  i2 = min( i2, i2nodepml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  t1(j1:j2,k1:k2,l1:l2,1) = stress(iz,1);
  t1(j1:j2,k1:k2,l1:l2,2) = stress(iz,2);
  t1(j1:j2,k1:k2,l1:l2,3) = stress(iz,3);
  t2(j1:j2,k1:k2,l1:l2,1) = stress(iz,4);
  t2(j1:j2,k1:k2,l1:l2,2) = stress(iz,5);
  t2(j1:j2,k1:k2,l1:l2,3) = stress(iz,6);
end

% Pretraction
t3(:) = 0.;
if tracdir
  i1 = i1nodepml;
  i2 = i2nodepml;
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  t3(j1:j2,k1:k2,l1:l2,1) = bread( tracdir, 'tn' );
  t3(j1:j2,k1:k2,l1:l2,2) = bread( tracdir, 'ts' );
  t3(j1:j2,k1:k2,l1:l2,3) = bread( tracdir, 'td' );
end
for iz = 1:size( traction, 1 )
  [ i1, i2 ] = zone( itrac(iz,:), nn, offset, hypocenter, nrmdim );
  i1 = max( i1, i1nodepml );
  i2 = min( i2, i2nodepml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  t3(j1:j2,k1:k2,l1:l2,1) = traction(iz,1);
  t3(j1:j2,k1:k2,l1:l2,2) = traction(iz,2);
  t3(j1:j2,k1:k2,l1:l2,3) = traction(iz,3);
end

% Normal vectors
i1 = i1node;
i2 = i2node;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
nrm(:,:,:,:) = snormals( x, i1, i2 );
area = sqrt( sum( nrm .* nrm, 4 ) );
f1 = area;
ii = f1 ~= 0.;
f1(ii) = 1 ./ f1(ii);
for i = 1:3
  nrm(:,:,:,i) = nrm(:,:,:,i) .* f1;
end

% Resolve prestress onto fault
for i = 1:3
  j = mod( i , 3 ) + 1;
  k = mod( i + 1, 3 ) + 1;
  t0(:,:,:,i) = ...
    t1(:,:,:,i) .* nrm(:,:,:,i) + ...
    t2(:,:,:,j) .* nrm(:,:,:,k) + ...
    t2(:,:,:,k) .* nrm(:,:,:,j);
end

% Find orientations
if nrmdim ~= downdim
  dipdim = downdim;
  strdim = 6 - dipdim - nrmdim;
else
  strdim = mod( nrmdim, 3 ) + 1;
  dipdim = 6 - strdim - nrmdim;
end
down = [ 0 0 0 ];
down(downdim) = 1;
handed = mod( strdim - nrmdim + 1, 3 ) - 1;

% Stike vectors
t1(:,:,:,1) = down(2) .* nrm(:,:,:,3) - down(3) .* nrm(:,:,:,2);
t1(:,:,:,2) = down(3) .* nrm(:,:,:,1) - down(1) .* nrm(:,:,:,3);
t1(:,:,:,3) = down(1) .* nrm(:,:,:,2) - down(2) .* nrm(:,:,:,1);
f1 = sqrt( sum( t1 .* t1, 4 ) );
ii = f1 ~= 0.;
f1(ii) = handed ./ f1(ii);
for i = 1:3
  t1(:,:,:,i) = t1(:,:,:,i) .* f1;
end

% Dip vectors
t2(:,:,:,1) = nrm(:,:,:,2) .* t1(:,:,:,3) - nrm(:,:,:,3) .* t1(:,:,:,2);
t2(:,:,:,2) = nrm(:,:,:,3) .* t1(:,:,:,1) - nrm(:,:,:,1) .* t1(:,:,:,3);
t2(:,:,:,3) = nrm(:,:,:,1) .* t1(:,:,:,2) - nrm(:,:,:,2) .* t1(:,:,:,1);
f1 = sqrt( sum( t1 .* t1, 4 ) );
ii = f1 ~= 0.;
f1(ii) = handed ./ f1(ii);
for i = 1:3
  t2(:,:,:,i) = t2(:,:,:,i) .* f1;
end

% Total pretraction
for i = 1:3
  t0(:,:,:,i) = t0(:,:,:,i) + ...
    t3(:,:,:,nrmdim) .* nrm(:,:,:,i) + ...
    t3(:,:,:,strdim) .* t1(:,:,:,i) + ...
    t3(:,:,:,dipdim) .* t2(:,:,:,i);
end

% Hypocentral radius
i1 = [ 1 1 1 ];
i2 = nm;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
for i = 1:3
  t3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - x0(i);
end
r = sqrt( sum( t3 .* t3, 4 ) );

% Output some info
i1 = hypocenter;
i1(nrmdim) = 1;
j = i1(1);
k = i1(2);
l = i1(3);
fs0 = fs(j,k,l);
fd0 = fd(j,k,l);
dc0 = dc(j,k,l);
tn0 = sum( t0(j,k,l,:) .* nrm(j,k,l,:) );
ts0 = norm( shiftdim( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) );
tn0 = max( -tn0, 0 );
fprintf( '  S:    %11.4e\n', ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 ) )
fprintf( '  dc:   %11.4e >%11.4e\n', dc0, 3 * dx * tn0 * ( fs0 - fd0 ) / mu0 )
fprintf( '  rcrit:%11.4e >%11.4e\n', rcrit, mu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2 )

usmax = 0;
vsmax = 0;
tnmax = 0;
tsmax = 0;

return

end

%------------------------------------------------------------------------------%

i1 = [ 1 1 1 ];
i2 = nm;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
i1(nrmdim) = hypocenter(nrmdim) + 1;
i2(nrmdim) = hypocenter(nrmdim) + 1;
j3 = i1(1); j4 = i2(1);
k3 = i1(2); k4 = i2(2);
l3 = i1(3); l4 = i2(3);

% Zero slip velocity boundary condition
f1 = dt * area .* ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) );
ii = f1 ~= 0.;
f1(ii) = 1 ./ f1(ii);
for i = 1:3
  t3(:,:,:,i) = t0(:,:,:,i) + f1 .* ...
    ( v(j3:j4,k3:k4,l3:l4,i) + dt .* w1(j3:j4,k3:k4,l3:l4,i) ...
    - v(j1:j2,k1:k2,l1:l2,i) - dt .* w1(j1:j2,k1:k2,l1:l2,i) );
end

% Decompose traction to normal and sear components
tn = sum( t3 .* nrm, 4 );
tnmax = max( abs( tn(:) ) );
for i = 1:3
  t1(:,:,:,i) = tn .* nrm(:,:,:,i);
end
t2 = t3 - t1;
ts = sqrt( sum( t2 .* t2, 4 ) );
tsmax = max( abs( ts(:) ) );

% Friction Law
ii = tn > 0.;
tn(ii) = 0.;
f1 = fd
ii = us < dc;
f1 = f1(ii) + ( 1. - us(ii) ./ dc(ii) ) .* ( fs(ii) - fd(ii) );
f1 = f1 .* -tn + co;

% Nucleation
if rcrit && vrup
  f2(:) = 1.;
  if nclramp, f2 = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1. ); end
  f2 = ( 1. - f2 ) .* ts + f2 .* ( fd .* -tn + co);
  ii = r < min( rcrit, it * dt * vrup ) & f2 < f1;
  f1(ii) = f2(ii);
end

% Shear traction bounded by friction
f2(:) = 1.;
ii = ts > f1;
f2(ii) = f1(ii) ./ ts(ii);
if find( f2 <= 0. ), fprintf( 'fault opening!\n' ), end

% Update acceleration
for i = 1:3
  t3(:,:,:,i) = t1(:,:,:,i) + f2 .* t2(:,:,:,i) - t0(:,:,:,i);
  w1(j1:j2,k1:k2,l1:l2,i) = ...
  w1(j1:j2,k1:k2,l1:l2,i) + t3(:,:,:,i) .* area .* rho(j1:j2,k1:k2,l1:l2);
  w1(j3:j4,k3:k4,l3:l4,i) = ...
  w1(j3:j4,k3:k4,l3:l4,i) + t3(:,:,:,i) .* area .* rho(j3:j4,k3:k4,l3:l4);
end

% Vslip
t2 = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) ...
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:);
vs = sqrt( sum( t2 .* t2, 4 ) );

% Rupture time
if truptol
  i1 = hypocenter;
  i1(nrmdim) = 1;
  l = i1(3);
  k = i1(2);
  j = i1(1);
  i = vs > truptol;
  if find( i )
    trup( i & ( ~ trup ) ) = ( it + .5 ) * dt;
    tarrest = ( it + 1.5 ) * dt;
    if i(j,k,l), tarresthypo = tarrest; end
  end
end

