%------------------------------------------------------------------------------%
% GRIDGEN

fprintf( 'Grid generation\n' )
downdim = 3;
if nrmdim && nrmdim ~= downdim
  crdsys = [ 6 - downdim - nrmdim nrmdim downdim ];
else
  crdsys = [ downdim+1:3 1:downdim ];
end
l1 = one * np(1) - 1;
l2 = one * np(2) - 1;
l3 = one * np(3) - 1;
j = -halo : l1 + halo;
k = -halo : l2 + halo;
l = -halo : l3 + halo;
i = hypocenter(nrmdim) + halo;
switch nrmdim
case 1, j(i:end) = j(i:end) - 1;
case 2, k(i:end) = k(i:end) - 1;
case 3, l(i:end) = l(i:end) - 1;
end
l1 = j(end-halo);
l2 = k(end-halo);
l3 = l(end-halo);
[s1, s2, s3] = ndgrid( j, k, l ); % ALLOC
x  = repmat( zero, [ nm 3 ] );    % ALLOC
u  = repmat( zero, [ nm 3 ] );    % ALLOC
v  = repmat( zero, [ nm 3 ] );    % ALLOC
w1 = repmat( zero, [ nm 3 ] );    % ALLOC
w2 = repmat( zero, [ nm 3 ] );    % ALLOC
x(:,:,:,1) = s1;
x(:,:,:,2) = s2;
x(:,:,:,3) = s3;
c = 0;
c = 0.2 * l1;
c = 0.01 * l1;
c = 0.06 * l1;
c = 0.1 * l1;
rand( 'state', 0 )
switch grid
case 'constant'
  operator = { 'h'  1 1 1  -1 -1 -1 };
case 'stretch'
  operator = { 'r'  1 1 1  -1 -1 -1 };
  x(:,:,:,3) = 2 * x(:,:,:,3);
case 'slant'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  theta = 20 * pi / 180;
  scl = sqrt( cos( theta ) ^ 2 + ( 1 - sin( theta ) ) ^ 2 );
  scl = sqrt( 2 ) / scl
  x(:,:,:,1) = x(:,:,:,1) - x(:,:,:,3) * sin( theta );
  x(:,:,:,3) = x(:,:,:,3) * cos( theta );
  x(:,:,:,1) = x(:,:,:,1) * scl;
  x(:,:,:,3) = x(:,:,:,3) * scl;
case 'map'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  x(:,:,:,1) = s1 + c / 5 * (s1-l1/2) .* (l3-s3);
  x(:,:,:,2) = s2 + c / 5 * (s2-l1/2) .* (l3-s3);
  x(:,:,:,3) = s3 + .1 * (cos(s2./l2*2*pi)-sin(s1./l1*2*pi)) .* (l3-s3) + .1 * (l1-s1) .* (s3-l3);
case 'normal'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  x(:,:,:,2) = s2 - c * (s3./l3-.5) * 4 .* (.5-abs(s2./l2-.5));
  x(:,:,:,3) = s3 + c * (s3./l3-1) .* atan(10*(s2./l2-.5));
  x(:,:,:,3) = x(:,:,:,3) - x(1,1,1,3);
  %moment = -[0 0 0 0 0 1e18];
  dx = 1.5 * dx;
case 'curve'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  dem = .2 * rand( [ 1 l1+1 l2+1 ] ) .* (-1.5-atan(10*(s2(1,:,:)./l2-.5))) + c*(s3(1,:,:)./l3-1).*atan( 10*(s2(1,:,:)./l2-.5) );
  x(:,:,:,1) = s1 + c * sin(s2./l2*2*pi) .* (.5-abs(s1./l1-.5));
  x(:,:,:,2) = s2 - c * sin(s1./l1*2*pi) .* (.5-abs(s2./l2-.5));
  x(:,:,:,3) = s3 + (1-s3./l3) .* repmat(dem,[l3+1 1 1]);
  dx = 1.5 * dx;
case 'spherical'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  da = pi / 2 / max( [ l1 l2 ] );
  %s3 = 2 * l3 - s3 - 1 / da;
  s3 = 2 * l3 - s3;
  s1 = ( s1 - l1 / 2 ) * da;
  s2 = ( s2 - l2 / 2 ) * da;
  x(:,:,:,3) = -s3 ./ sqrt( 1 + tan(s1).^2 + tan(s2).^2 );
  x(:,:,:,1) = -tan(s1) .* x(:,:,:,3);
  x(:,:,:,2) = -tan(s2) .* x(:,:,:,3);
  x(:,:,:,3) = x(:,:,:,3) - min( min( min( x(:,:,:,3) ) ) );
  dx = 1.5 * dx;
case 'hill'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  x(:,:,:,3) = s3 - .25 * (l3-s3) .* exp(-((s1-l1/2).^2 + (s2-l2/2).^2) / ((l1 + l2)/10) ^ 2);
case 'rand'
  operator = { 'g'  1 1 1  -1 -1 -1 };
  a = .2;
  %dx = dx / ( 1 - a );
  s1 = a * ( rand( nm ) - .5 );
  s2 = a * ( rand( nm ) - .5 );
  s3 = a * ( rand( nm ) - .5 );
  s1([1 2 end-1 end],:,:) = 0;
  s2(:,[1 2 end-1 end],:) = 0;
  s3(:,:,[1 2 end-1 end]) = 0;
  i = hypocenter;
  switch nrmdim
  case 1, s1(i(1)+[0 1],:,:) = 0;
  case 2, s2(:,i(2)+[0 1],:) = 0;
  case 3, s3(:,:,i(3)+[0 1]) = 0;
  end
  %s2([8 9],9,:) = .95;
  x(:,:,:,1) = x(:,:,:,1) + s1;
  x(:,:,:,2) = x(:,:,:,2) + s2;
  x(:,:,:,3) = x(:,:,:,3) + s3;
otherwise error grid
end
x = dx * x;
x1 = min( reshape( x, [ prod(nm) 3 ] ) );
x2 = max( reshape( x, [ prod(nm) 3 ] ) );
x0 = double( x1 + x2 ) / 2;
for i = 1:3
  w1(:,:,:,i) = x(:,:,:,i) - x0(i);
end
s1 = sum( w1 .* w1, 4 );
xmax = 2 * sqrt( double( max( s1(:) ) ) );
clear s3
s1(:) = 0;
s2(:) = 0;
w1(:) = 0;
hypoloc = x(hypocenter(1),hypocenter(2),hypocenter(3),:);

