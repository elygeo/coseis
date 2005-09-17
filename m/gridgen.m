%------------------------------------------------------------------------------%
% GRIDGEN

fprintf( 'Grid generation\n' )

% Indices
i1 = i1cell;
i2 = i2cell + 1;
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
i1oper = [ 1 1 1 ];
i2oper = [ -1 -1 -1 ];

% Read grid files or creat basic rectangular mesh
x(:) = 0.;
switch grid
case 'read'
  oper = 'g';
  endian = textread( 'data/endian', '%c', 1 );
  x(j1:j2,k1:k2,l1:l2,1) = bread( 'data/x1', endian );
  x(j1:j2,k1:k2,l1:l2,2) = bread( 'data/x2', endian );
  x(j1:j2,k1:k2,l1:l2,3) = bread( 'data/x3', endian );
otherwise
  for i = j1:j2, x(i,:,:,1) = dx * ( i - 1 - noff(1) ); end
  for i = k1:k2, x(:,i,:,2) = dx * ( i - 1 - noff(2) ); end
  for i = l1:l2, x(:,:,i,3) = dx * ( i - 1 - noff(3) ); end
  if ifn
    i = ihypo(ifn);
    switch ifn
    case 1, x(i+1:j2,:,:,:) = x(i:j2-1,:,:,:);
    case 2, x(:,i+1:k2,:,:) = x(:,i:k2-1,:,:);
    case 3, x(:,:,i+1:l2,:) = x(:,:,i:l2-1,:);
    end
  end
end

% Coordinate system
l = abs( upward );
up = sign( upward );
if ~ifn | ifn == l
  k = mod( l + 1, 3 ) + 1;
else
  k = ifn;
end
j = 6 - k - l;
crdsys = [ j k l ];

% Dimensions
lj = x(j2,k2,l2,j);
lk = x(j2,k2,l2,k);
ll = x(j2,k2,l2,l);

% Mesh models
switch grid
case 'read'
case 'constant'
  oper = 'h';
case 'stretch'
  oper = 'r';
  x(:,:,:,l) = 2 * x(:,:,:,l);
case 'slant'
  oper = 'g';
  theta = 20 * pi / 180;
  scl = sqrt( cos( theta ) ^ 2 + ( 1 - sin( theta ) ) ^ 2 );
  scl = sqrt( 2 ) / scl
  x(:,:,:,j) = x(:,:,:,j) - x(:,:,:,l) * sin( theta );
  x(:,:,:,l) = x(:,:,:,l) * cos( theta );
  x(:,:,:,j) = x(:,:,:,j) * scl;
  x(:,:,:,l) = x(:,:,:,l) * scl;
case 'hill'
  oper = 'g';
  s1 = ( x(:,:,:,j) - .5 * lj ) .^ 2 + ( x(:,:,:,k) - .5 * lk ) .^ 2;
  s1 = exp( -s1 / ( ( lj + lk ) / 10 ) ^ 2 );
  x(:,:,:,l) = x(:,:,:,l) - .25 * ( ll - x(:,:,:,l) ) .* s1;
case 'normal'
  oper = 'g';
  c = 0.1 * lj;
  s1 = x(:,:,:,l) / ll - .5;
  s2 = x(:,:,:,k) / lk - .5;
  x(:,:,:,k) = x(:,:,:,k) - c * s1 * 4. .* ( .5 - abs( s2 ) );
  x(:,:,:,l) = x(:,:,:,l) + c * ( s1 - .5 ) .* atan( 10. * s2 );
  x(:,:,:,l) = x(:,:,:,l) - x(2,2,2,3);
  x = 1.5 * x;
case 'curve'
  oper = 'g';
  c = 0.1 * lj;
  s1 = x(:,:,:,j) / lj;
  s2 = x(:,:,:,k) / lk;
  x(:,:,:,j) = s1 + c * sin( s2 * 2. * pi ) .* ( .5 - abs( s1 - .5 ) );
  x(:,:,:,k) = s2 - c * sin( s1 * 2. * pi ) .* ( .5 - abs( s2 - .5 ) );
  x = 1.5 * x;
case 'spherical'
  oper = 'g';
  da = pi / 2. / max( [ lj lk ] );
  s1 = tan( ( x(:,:,:,j) - lj / 2. ) * da );
  s2 = tan( ( x(:,:,:,k) - lk / 2. ) * da );
  x(:,:,:,l) = ( 2 * ll - x(:,:,:,l) ) ./ sqrt( 1 + s1 .* s1 + s2 .* s2 );
  x(:,:,:,j) = - s1 .* x(:,:,:,l);
  x(:,:,:,k) = - s2 .* x(:,:,:,l);
  x(:,:,:,l) = x(:,:,:,l) - min( min( min( x(:,:,:,l) ) ) );
  x = 1.5 * x;
case 'rand'
  oper = 'g';
  w1 = .2 * ( rand( [ nm 3 ] ) - .5 );
  w1(j1,:,:,1) = 0.; w1(j2,:,:,1) = 0.;
  w1(:,k1,:,2) = 0.; w1(:,k2,:,2) = 0.;
  w1(:,:,l1,3) = 0.; w1(:,:,l2,3) = 0.;
  j = ihypo(1);
  k = ihypo(2);
  l = ihypo(3);
  switch ifn
  case 1, w1(j,:,:,1) = 0.; w1(j+1,:,:,1) = 0.;
  case 2, w1(:,k,:,2) = 0.; w1(:,k+1,:,2) = 0.;
  case 3, w1(:,:,k,3) = 0.; w1(:,:,k+1,3) = 0.;
  end
  x = x + w1;
otherwise error 'grid'
end

% Duplicate edge nodes into halo
if( bc1(1) ~= -1 ) x(j1-1,:,:,:) = x(j1,:,:,:)
if( bc2(1) ~= -1 ) x(j2+1,:,:,:) = x(j2,:,:,:)
if( bc1(2) ~= -1 ) x(:,j1-1,:,:) = x(:,j1,:,:)
if( bc2(2) ~= -1 ) x(:,k2+1,:,:) = x(:,k2,:,:)
if( bc1(3) ~= -1 ) x(:,:,j1-1,:) = x(:,:,j1,:)
if( bc2(3) ~= -1 ) x(:,:,l2+1,:) = x(:,:,l2,:)

% Hypocenter location
j = ihypo(1);
k = ihypo(2);
l = ihypo(3);
xhypo = x(j,k,l,:);
xhypo = xhypo(:)';

% Grid dimensions
x1 = min( reshape( x, [ prod( nm ) 3 ] ) );
x2 = max( reshape( x, [ prod( nm ) 3 ] ) );
xcenter = double( x1 + x2 ) / 2;
for i = 1:3
  w1(:,:,:,i) = x(:,:,:,i) - xcenter(i);
end
s1 = sum( w1 .* w1, 4 );
xmax = 2 * sqrt( double( max( s1(:) ) ) );

