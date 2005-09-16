%------------------------------------------------------------------------------%
% FAULT

if ~ifn; return; end

if init

init = 0;
fprintf( 'Initialize fault\n' )

% Input
mus(:) = 0;
mud(:) = 0;
dc(:) = 0;
co(:) = 1e3;
t1(:) = 0.;
t2(:) = 0.;
t3(:) = 0.;
for i = 1:size( inkey, 1 )
if ( readfile(i) )
  i1 = i1nodepml;
  i2 = i2nodepml;
  i1(ifn) = 1;
  i2(ifn) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  endian = textread( 'data/endian', '%c', 1 );
  switch inkey(i)
  case 'mus',      mus(j1:j2,k1:k2,l1:l2)  = bread( 'data/mus',      endian );
  case 'mud',      mud(j1:j2,k1:k2,l1:l2)  = bread( 'data/mud',      endian );
  case 'dc',       dc(j1:j2,k1:k2,l1:l2)   = bread( 'data/dc',       endian );
  case 'cohesion', co(j1:j2,k1:k2,l1:l2)   = bread( 'data/cohesion', endian );
  case 'sxx',      t1(j1:j2,k1:k2,l1:l2,1) = bread( 'data/sxx',      endian );
  case 'syy',      t1(j1:j2,k1:k2,l1:l2,2) = bread( 'data/syy',      endian );
  case 'szz',      t1(j1:j2,k1:k2,l1:l2,3) = bread( 'data/szz',      endian );
  case 'syz',      t2(j1:j2,k1:k2,l1:l2,1) = bread( 'data/syz',      endian );
  case 'szx',      t2(j1:j2,k1:k2,l1:l2,2) = bread( 'data/szx',      endian );
  case 'sxy',      t2(j1:j2,k1:k2,l1:l2,3) = bread( 'data/sxy',      endian );
  case 'tnormal',  t3(j1:j2,k1:k2,l1:l2,1) = bread( 'data/tnormal',  endian );
  case 'tstrike',  t3(j1:j2,k1:k2,l1:l2,2) = bread( 'data/tstrike',  endian );
  case 'tdip',     t3(j1:j2,k1:k2,l1:l2,3) = bread( 'data/tdip',     endian );
  end
else
  [ i1, i2 ] = zone( i1in(iz,:), i2in(iz,:), nn, noff, i0, ifn );
  i1 = max( i1, i1nodepml );
  i2 = min( i2, i2nodepml );
  i1(ifn) = 1;
  i2(ifn) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  switch inkey(i)
  case 'mus',      mus(j1:j2,k1:k2,l1:l2)  = inval(i);
  case 'mud',      mud(j1:j2,k1:k2,l1:l2)  = inval(i);
  case 'dc',       dc(j1:j2,k1:k2,l1:l2)   = inval(i);
  case 'cohesion', co(j1:j2,k1:k2,l1:l2)   = inval(i);
  case 'sxx',      t1(j1:j2,k1:k2,l1:l2,1) = inval(i);
  case 'syy',      t1(j1:j2,k1:k2,l1:l2,2) = inval(i);
  case 'szz',      t1(j1:j2,k1:k2,l1:l2,3) = inval(i);
  case 'syz',      t2(j1:j2,k1:k2,l1:l2,1) = inval(i);
  case 'szx',      t2(j1:j2,k1:k2,l1:l2,2) = inval(i);
  case 'sxy',      t2(j1:j2,k1:k2,l1:l2,3) = inval(i);
  case 'tnormal',  t3(j1:j2,k1:k2,l1:l2,1) = inval(i);
  case 'tstrike',  t3(j1:j2,k1:k2,l1:l2,2) = inval(i);
  case 'tdip',     t3(j1:j2,k1:k2,l1:l2,3) = inval(i);
  end
end
end

% Normal vectors
i1 = i1node;
i2 = i2node;
i1(ifn) = i0(ifn);
i2(ifn) = i0(ifn);
nrm = snormals( x, i1, i2 );
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

% Stike vectors
t1(:,:,:,1) = upvector(2) .* nrm(:,:,:,3) - upvector(3) .* nrm(:,:,:,2);
t1(:,:,:,2) = upvector(3) .* nrm(:,:,:,1) - upvector(1) .* nrm(:,:,:,3);
t1(:,:,:,3) = upvector(1) .* nrm(:,:,:,2) - upvector(2) .* nrm(:,:,:,1);
f1 = sqrt( sum( t1 .* t1, 4 ) );
ii = f1 ~= 0.;
f1(ii) = 1. ./ f1(ii);
for i = 1:3
  t1(:,:,:,i) = t1(:,:,:,i) .* f1;
end

% Dip vectors
t2(:,:,:,1) = t1(:,:,:,2) .* nrm(:,:,:,3) - t1(:,:,:,3) .* nrm(:,:,:,2);
t2(:,:,:,2) = t1(:,:,:,3) .* nrm(:,:,:,1) - t1(:,:,:,1) .* nrm(:,:,:,3);
t2(:,:,:,3) = t1(:,:,:,1) .* nrm(:,:,:,2) - t1(:,:,:,2) .* nrm(:,:,:,1);
f1 = sqrt( sum( t1 .* t1, 4 ) );
ii = f1 ~= 0.;
f1(ii) = 1. ./ f1(ii);
for i = 1:3
  t2(:,:,:,i) = t2(:,:,:,i) .* f1;
end

% Coordinate system
vector = upvector;
vector(ifn) = 0;
[ i, idip ] = max( abs( vector ) );
istrike = 6 - idip - ifn;

% Total pretraction
for i = 1:3
  t0(:,:,:,i) = t0(:,:,:,i) + ...
    t3(:,:,:,ifn)     .* nrm(:,:,:,i) + ...
    t3(:,:,:,istrike) .* t1(:,:,:,i) + ...
    t3(:,:,:,idip)    .* t2(:,:,:,i);
end

% Hypocentral radius
i1 = [ 1 1 1 ];
i2 = nm;
i1(ifn) = i0(ifn);
i2(ifn) = i0(ifn);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
for i = 1:3
  t3(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - x0(i);
end
r = sqrt( sum( t3 .* t3, 4 ) );

% Informational output
i1 = i0;
i1(ifn) = 1;
j = i1(1);
k = i1(2);
l = i1(3);
mus0 = mus(j,k,l);
mud0 = mud(j,k,l);
dc0 = dc(j,k,l);
tn0 = sum( t0(j,k,l,:) .* nrm(j,k,l,:) );
ts0 = norm( shiftdim( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) );
tn0 = max( -tn0, 0 );
fprintf( '  S:    %11.4e\n', ( tn0 * mus0 - ts0 ) / ( ts0 - tn0 * mud0 ) )
fprintf( '  dc:   %11.4e >%11.4e\n', dc0, 3 * dx * tn0 * ( mus0 - mud0 ) / mu0 )
fprintf( '  rcrit:%11.4e >%11.4e\n', rcrit, mu0 * tn0 * ( mus0 - mud0 ) * dc0 / ( ts0 - tn0 * mud0 ) ^ 2 )

return

end

%------------------------------------------------------------------------------%

i1 = [ 1 1 1 ];
i2 = nm;
i1(ifn) = i0(ifn);
i2(ifn) = i0(ifn);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
i1(ifn) = i0(ifn) + 1;
i2(ifn) = i0(ifn) + 1;
j3 = i1(1); j4 = i2(1);
k3 = i1(2); k4 = i2(2);
l3 = i1(3); l4 = i2(3);

% Zero slip velocity boundary condition
f1 = dt * area .* ( mr(j1:j2,k1:k2,l1:l2) + mr(j3:j4,k3:k4,l3:l4) );
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
f1 = mud;
ii = us < dc;
f1(ii) = f1(ii) + ( 1. - us(ii) ./ dc(ii) ) .* ( mus(ii) - mud(ii) );
f1 = f1 .* -tn + co;

% Nucleation
if rcrit && vrup
  f2(:) = 1.;
  if nramp, f2 = min( ( it * dt - r / vrup ) / ( nramp * dt ), 1. ); end
  f2 = ( 1. - f2 ) .* ts + f2 .* ( mud .* -tn + co);
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
f1 = area .* ( t1(:,:,:,i) + f2 .* t2(:,:,:,i) - t0(:,:,:,i) );
w1(j1:j2,k1:k2,l1:l2,i) = w1(j1:j2,k1:k2,l1:l2,i) + f1 .* mr(j1:j2,k1:k2,l1:l2);
w1(j3:j4,k3:k4,l3:l4,i) = w1(j3:j4,k3:k4,l3:l4,i) - f1 .* mr(j3:j4,k3:k4,l3:l4);
end

% Vslip
t2 = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) ...
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:);
vs = sqrt( sum( t2 .* t2, 4 ) );

% Rupture time
if truptol
  i1 = i0;
  i1(ifn) = 1;
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

