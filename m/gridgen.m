%------------------------------------------------------------------------------%
% GRIDGEN

fprintf( 'Grid generation\n' )
downdim = 3;
if nrmdim && nrmdim ~= downdim
  crdsys = [ 6 - downdim - nrmdim nrmdim downdim ];
else
  crdsys = [ downdim+1:3 1:downdim ];
end

x(:) = 0.;
i1 = i1node;
i2 = i2node;
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);

ioper = [ 1 1 1  -1 -1 -1 ];
rand( 'state', 0 )

%------------------------------------------------------------------------------%
if griddir

operator = 'g';
bendian = textread( [ griddir '/endian' ], '%c' );
bendian = bendian(1);
fid = fopen( [ griddir '/x1', 'r', bendian );
x(j1:j2,k1:k2,l1:l2,1) = fread( fid, inf, 'float32' );
fclose( fid );
fid = fopen( [ griddir '/x2', 'r', bendian );
x(j1:j2,k1:k2,l1:l2,2) = fread( fid, inf, 'float32' );
fclose( fid );
fid = fopen( [ griddir '/x3', 'r', bendian );
x(j1:j2,k1:k2,l1:l2,3) = fread( fid, inf, 'float32' );
fclose( fid );

%------------------------------------------------------------------------------%
else

% Basic mesh
for i = j1:j2, x(i,:,:,1) = i - 1 - nhalo; end
for i = k1:k2, x(:,i,:,2) = i - 1 - nhalo; end
for i = l1:l2, x(:,:,i,3) = i - 1 - nhalo; end

% Double nodes on fault
if nrmdim
  i = hypocenter(nrmdim) + 1;
  switch nrmdim
  case 1, x(i:end,:,:) = x(i:end,:,:) - 1;
  case 2, x(:,i:end,:) = x(:,i:end,:) - 1;
  case 3, x(:,:,i:end) = x(:,:,i:end) - 1;
  end
end

% Scale factors
l1 = nn(1) - 1;
l2 = nn(2) - 1;
l3 = nn(3) - 1;
c = 0;
c = 0.2 * l1;
c = 0.01 * l1;
c = 0.06 * l1;
c = 0.1 * l1;

switch grid
case 'constant'
  operator = 'h';
case 'stretch'
  operator = 'r';
  x(:,:,:,3) = 2 * x(:,:,:,3);
case 'slant'
  operator = 'g';
  theta = 20 * pi / 180;
  scl = sqrt( cos( theta ) ^ 2 + ( 1 - sin( theta ) ) ^ 2 );
  scl = sqrt( 2 ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case 'hill'
  operator = 'g';
  s1 = ( x(:,:,:,1) - l1/2 ) .^ 2 + ( x(:,:,:,2) - l2/2 ) .^ 2;
  s1 = exp( -s1 / ( ( l1 + l2 ) / 10 ) ^ 2 );
  x(:,:,:,3) = x(:,:,:,3) - .25 * ( l3 - x(:,:,:,3) ) .* s1;
case 'normal'
  operator = 'g';
  s1 = x(:,:,:,3) / l3 - .5;
  s2 = x(:,:,:,2) / l2 - .5;
  x(:,:,:,2) = x(:,:,:,2) - c * s1 * 4 .* ( .5 - abs( s2 ) );
  x(:,:,:,3) = x(:,:,:,3) + c * ( s1 - .5 ) .* atan( 10* s2 );
  x(:,:,:,3) = x(:,:,:,3) - x(2,2,2,3);
  dx = 1.5 * dx;
case 'curve'
  operator = 'g';
  s1 = x(:,:,:,1) / l1;
  s2 = x(:,:,:,2) / l2;
  x(:,:,:,1) = s1 + c * sin( s2 * 2 * pi ) .* ( .5 - abs( s1 - .5 ) );
  x(:,:,:,2) = s2 - c * sin( s1 * 2 * pi ) .* ( .5 - abs( s2 - .5 ) );
  dx = 1.5 * dx;
case 'spherical'
  operator = 'g';
  da = pi / 2 / max( [ l1 l2 ] );
  s1 = tan( ( x(:,:,:,1) - l1 / 2 ) * da );
  s2 = tan( ( x(:,:,:,2) - l2 / 2 ) * da );
  x(:,:,:,3) = ( 2 * l3 - x(:,:,:,3) ) ./ sqrt( 1 + s1 .* s1 + s2 .* s2 );
  x(:,:,:,1) = - s1 .* x(:,:,:,3);
  x(:,:,:,2) = - s2 .* x(:,:,:,3);
  x(:,:,:,3) = x(:,:,:,3) - min( min( min( x(:,:,:,3) ) ) );
  dx = 1.5 * dx;
case 'rand'
  operator = 'g';
  a = .2;
  w1 = a * ( rand( [ nm 3 ] ) - .5 );
  w1([2 end-1],:,:,1) = 0;
  w1(:,[2 end-1],:,2) = 0;
  w1(:,:,[2 end-1],3) = 0;
  i = hypocenter;
  switch nrmdim
  case 1, w1(i(1)+[0 1],:,:,1) = 0;
  case 2, w1(:,i(2)+[0 1],:,2) = 0;
  case 3, w1(:,:,i(3)+[0 1],3) = 0;
  end
  x = x(:,:,:,1) + w1;
otherwise error grid
end

end
%------------------------------------------------------------------------------%

% Duplicate edge nodes into halo
x([1 end],:,:,:) = x([2 end-1],:,:,:);
x(:,[1 end],:,:) = x(:,[2 end-1],:,:);
x(:,:,[1 end],:) = x(:,:,[2 end-1],:);

x = dx * x;
i1 = hypocenter;
x0 = x(i1(1),i1(2),i1(3),:);
x0 = x0(:)';

x1 = min( reshape( x, [ prod( nm ) 3 ] ) );
x2 = max( reshape( x, [ prod( nm ) 3 ] ) );
xcenter = double( x1 + x2 ) / 2;
for i = 1:3
  w1(:,:,:,i) = x(:,:,:,i) - xcenter(i);
end
s1 = sum( w1 .* w1, 4 );
xmax = 2 * sqrt( double( max( s1(:) ) ) );

