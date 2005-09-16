%------------------------------------------------------------------------------%
% GRIDGEN

fprintf( 'Grid generation\n' )

i1 = i1node;
i2 = i2node;
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);

ioper = [ 1 1 1  -1 -1 -1 ];
rand( 'state', 0 )

% Read grid files or creat basic rectangular mesh
x(:) = 0.;
if griddir
  oper = 'g';
  endian = textread( 'data/endian', '%c', 1 );
  x(j1:j2,k1:k2,l1:l2,1) = bread( 'data/x1', endian );
  x(j1:j2,k1:k2,l1:l2,2) = bread( 'data/x2', endian );
  x(j1:j2,k1:k2,l1:l2,3) = bread( 'data/x3', endian );
else
  for i = j1:j2, x(i,:,:,1) = dx * ( i - 1 - nhalo ); end
  for i = k1:k2, x(:,i,:,2) = dx * ( i - 1 - nhalo ); end
  for i = l1:l2, x(:,:,i,3) = dx * ( i - 1 - nhalo ); end
  if ifn
    i = i0(ifn);
    switch ifn
    case 1, x(i+1:end,:,:) = x(i:end-1,:,:);
    case 2, x(:,i+1:end,:) = x(:,i:end-1,:);
    case 3, x(:,:,i+1:end) = x(:,:,i:end-1);
    end
  end
end

% Coordinate system
[ i, l ] = max( abs( upvector ) );
if ~ifn | ifn == l
  k = mod( l + 2, 3 ) + 1;
else
  k = ifn;
end
j = 6 - k - l;
up = sign( upvector(l) );
crdsys = [ j k l ];

% Dimensions
lj = x(j2,k2,l2,j);
lk = x(j2,k2,l2,k);
ll = x(j2,k2,l2,l);

% Mesh models
switch grid
case ''
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
  w1([2 end-1],:,:,1) = 0;
  w1(:,[2 end-1],:,2) = 0;
  w1(:,:,[2 end-1],3) = 0;
  j = i0(1);
  k = i0(2);
  l = i0(3);
  switch ifn
  case 1, w1(j+[0 1],:,:,1) = 0;
  case 2, w1(:,k+[0 1],:,2) = 0;
  case 3, w1(:,:,l+[0 1],3) = 0;
  und
  x = x + w1;
otherwise error 'grid'
end

% Duplicate edge nodes into halo
x([1 end],:,:,:) = x([2 end-1],:,:,:);
x(:,[1 end],:,:) = x(:,[2 end-1],:,:);
x(:,:,[1 end],:) = x(:,:,[2 end-1],:);

% hypocenter location
x0 = x(i0(1),i0(2),i0(3),:);
x0 = x0(:)';

x1 = min( reshape( x, [ prod( nm ) 3 ] ) );
x2 = max( reshape( x, [ prod( nm ) 3 ] ) );
xcenter = double( x1 + x2 ) / 2;
for i = 1:3
  w1(:,:,:,i) = x(:,:,:,i) - xcenter(i);
end
s1 = sum( w1 .* w1, 4 );
xmax = 2 * sqrt( double( max( s1(:) ) ) );

