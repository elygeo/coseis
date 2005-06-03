%------------------------------------------------------------------------------%
% GRIDGEN

fprintf( 'Grid generation\n' )
downdim = 3;
if nrmdim && nrmdim ~= downdim
  crdsys = [ 6 - downdim - nrmdim nrmdim downdim ];
else
  crdsys = [ downdim+1:3 1:downdim ];
end
nn = n - 3;
if nrmdim, nn(nrmdim) = nn(nrmdim) - 1; end
n1 = nn(1);
n2 = nn(2);
n3 = nn(3);
[s1, s2, s3] = ndgrid( 0:n1*one, 0:n2*one, 0:n3*one );
x1 = s1;
x2 = s2;
x3 = s3;
c = 0;
c = 0.2 * n1;
c = 0.01 * n1;
c = 0.06 * n1;
c = 0.1 * n1;
rand( 'state', 0 )
switch grid
case 'constant'
  operator = { 'h'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
case 'staggered'
  operator = { '4'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  staggerbc1 = 1; % normal v at the surface
  staggerbc1 = 0; % horizontal v at the surface
case 'map'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  x1 = s1 + c / 5 * (s1-n1/2) .* (n3-s3);
  x2 = s2 + c / 5 * (s2-n1/2) .* (n3-s3);
  x3 = s3 + .1 * (cos(s2./n2*2*pi)-sin(s1./n1*2*pi)) .* (n3-s3) + .1 * (n1-s1) .* (s3-n3);
case 'normal'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  x2 = s2 - c * (s3./n3-.5) * 4 .* (.5-abs(s2./n2-.5));
  x3 = s3 + c * (s3./n3-1) .* atan(10*(s2./n2-.5));
  x3 = x3 - x3(1);
  %moment = -[0 0 0 0 0 1e18];
  h = 1.5 * h;
case 'curve'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  dem = .2 * rand( [ 1 n1+1 n2+1 ] ) .* (-1.5-atan(10*(s2(1,:,:)./n2-.5))) + c*(s3(1,:,:)./n3-1).*atan( 10*(s2(1,:,:)./n2-.5) );
  x1 = s1 + c * sin(s2./n2*2*pi) .* (.5-abs(s1./n1-.5));
  x2 = s2 - c * sin(s1./n1*2*pi) .* (.5-abs(s2./n2-.5));
  x3 = s3 + (1-s3./n3) .* repmat(dem,[n3+1 1 1]);
  h = 1.5 * h;
case 'spherical'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  da = pi / 2 / max( [ n1 n2 ] );
  %rr = 2 * n3 - s3 - 1 / da;
  rr = 2 * n3 - s3;
  a = ( s1 - n1 / 2 ) * da;
  b = ( s2 - n2 / 2 ) * da;
  x3 = -rr ./ sqrt( 1 + tan(a).^2 + tan(b).^2 );
  x1 = -tan(a) .* x3;
  x2 = -tan(b) .* x3;
  x3 = x3 - min( x3(:) );
  h = 1.5 * h;
case 'slant'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  theta = 30 * pi / 180;
  scl = 1.25;
  x1 = s1 - s3 * sin( theta );
  x3 = s3 * cos( theta );
  x1 = scl * x1;
  x3 = scl * x3;
case 'stretch'
  operator = { 'r'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  x1 = 2 * s1;
case 'hill'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  x3 = s3 - .25 * (n3-s3) .* exp(-((s1-n1/2).^2 + (s2-n2/2).^2) / ((n1 + n2)/10) ^ 2);
case 'rand'
  operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 };
  a = .2;
  %h = h / ( 1 - a );
  s1 = a * ( rand( size( s1 ) ) - .5 );
  s2 = a * ( rand( size( s2 ) ) - .5 );
  s3 = a * ( rand( size( s3 ) ) - .5 );
  s1([1 end],:,:) = 0;
  s2(:,[1 end],:) = 0;
  s3(:,:,[1 end]) = 0;
  i = hypocenter - 1;
  switch 3
  case 1, s1(i(1),:,:) = 0;
  case 2, s2(:,i(2),:) = 0;
  case 3, s3(:,:,i(3)) = 0;
  end
  %s2([8 9],9,:) = .95;
  x1 = x1 + s1;
  x1 = x1 + s2;
  x3 = x3 + s3;
otherwise error grid
end
if noise, operator = { 'g'  1 1 0  1 1 1   1 1 1  -1 -1 -1 }; end
%x = repmat( zero, [ n 3 ] );
s1 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,1) = x1 + noise * ( s1 - .5 );
s2 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,2) = x2 + noise * ( s2 - .5 );
s3 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,3) = x3 + noise * ( s3 - .5 );
clear s1 s2 s3 x1 x2 x3
x = x([1 1:end end],[1 1:end end],[1 1:end end],:);
switch nrmdim
case 1, x = x([1:hypocenter(1) hypocenter(1):end],:,:,:);
case 2, x = x(:,[1:hypocenter(2) hypocenter(2):end],:,:);
case 3, x = x(:,:,[1:hypocenter(3) hypocenter(3):end],:);
end
h = h / ( 1 - noise );
x = h * x;
x1 = min( reshape( x, [ prod(n) 3 ] ) );
x2 = max( reshape( x, [ prod(n) 3 ] ) );
x0 = double( x1 + x2 ) / 2;
for i = 1:3
  w1(:,:,:,i) = x(:,:,:,i) - x0(i);
end
s1 = sum( w1 .* w1, 4 );
xmax = 2 * sqrt( double( max( s1(:) ) ) );

