%------------------------------------------------------------------------------%
% GRIDGEN

disp( 'Grid generation' )
nn = n - 3;
if nrmdim, nn(nrmdim) = nn(nrmdim) - 1; end
n1 = nn(1);
n2 = nn(2);
n3 = nn(3);
[x1, x2, x3] = ndgrid( 0:n1*one, 0:n2*one, 0:n3*one );
xx1 = x1;
xx2 = x2;
xx3 = x3;
c = 0;
c = 0.2 * n3;
c = 0.01 * n3;
c = 0.06 * n3;
c = 0.1 * n3;
rand( 'state', 0 )
switch grid
case 'constant'
  operator = { 'h'  0 1 1  1 1 1   1 1 1  -1 -1 -1 };
  %if nrmdim, operator = 'rec'; end
case 'staggered'
  operator = { '4'  0 1 1  1 1 1    1 1 1   -1 -1 -1 };
  staggerbc1 = 1; % normal v at the surface
  staggerbc1 = 0; % horizontal v at the surface
case 'map'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  xx1 = x1 + .1 * (cos(x3./n3*2*pi)-sin(x2./n2*2*pi)) .* (n1-x1) + .1 * (n2-x2) .* (x1-n1);
  xx2 = x2 + c / 5 * (x2-n2/2) .* (n1-x1);
  xx3 = x3 + c / 5 * (x3-n2/2) .* (n1-x1);
case 'normal'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  xx1 = x1 + c * (x1./n1-1) .* atan(10*(x3./n3-.5));
  xx3 = x3 - c * (x1./n1-.5) * 4 .* (.5-abs(x3./n3-.5));
  %moment = -[0 0 0 0 0 1e18];
  h = 1.5 * h;
case 'curve'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  dem = .2 * rand( [ 1 n2+1 n3+1 ] ) .* (-1.5-atan(10*(x3(1,:,:)./n3-.5))) + c*(x1(1,:,:)./n1-1).*atan( 10*(x3(1,:,:)./n3-.5) );
  xx1 = x1 + (1-x1./n1) .* repmat(dem,[n1+1 1 1]);
  xx2 = x2 + c * sin(x3./n3*2*pi) .* (.5-abs(x2./n2-.5));
  xx3 = x3 - c * sin(x2./n2*2*pi) .* (.5-abs(x3./n3-.5));
  h = 1.5 * h;
case 'spherical'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  da = pi / 2 / max( [ n2 n3 ] );
  %rr = 2 * n1 - x1 - 1 / da;
  rr = 2 * n1 - x1;
  a = ( x2 - n2 / 2 ) * da;
  b = ( x3 - n3 / 2 ) * da;
  xx1 = -rr ./ sqrt( 1 + tan(a).^2 + tan(b).^2 );
  xx2 = -tan(a) .* xx1;
  xx3 = -tan(b) .* xx1;
  xx1 = xx1 - min( xx1(:) );
  h = 1.5 * h;
case 'slant'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  theta = 30 * pi / 180;
  xx1 = x1 * cos( theta );
  xx2 = x2 - x1 * sin( theta );
  scl = 1.25;
  xx1 = scl * xx1;
  xx2 = scl * xx2;
case 'stretch'
  operator = { 'r'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  xx2 = 2 * x2;
case 'hill'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  xx1 = x1 - .25 * (n1-x1) .* exp(-((x2-n2/2).^2 + (x3-n3/2).^2) / ((n2 + n3)/10) ^ 2);
case 'rand'
  operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 };
  a = .2;
  %h = h / ( 1 - a );
  x1 = a * ( rand( size( x1 ) ) - .5 );
  x2 = a * ( rand( size( x2 ) ) - .5 );
  x3 = a * ( rand( size( x3 ) ) - .5 );
  x1([1 end],:,:) = 0;
  x2(:,[1 end],:) = 0;
  x3(:,:,[1 end]) = 0;
  i = hypocenter - 1;
  switch 3
  case 1, x1(i(1),:,:) = 0;
  case 2, x2(:,i(2),:) = 0;
  case 3, x3(:,:,i(3)) = 0;
  end
  %x2([8 9],9,:) = .95;
  xx1 = xx1 + x1;
  xx2 = xx2 + x2;
  xx3 = xx3 + x3;
otherwise, error( 'unknown grid type' )
end
if noise, operator = { 'g'  0 1 1  1 1 1    1 1 1  -1 -1 -1 }; end
%x = repmat( zero, [ n 3 ] );
x1 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,1) = xx1 + noise * ( x1 - .5 );
x2 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,2) = xx2 + noise * ( x2 - .5 );
x3 = rand( [ n1 n2 n3 ] + 1 ); x(:,:,:,3) = xx3 + noise * ( x3 - .5 );
clear x1 x2 x3 xx1 xx2 xx3
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
x0 = ( x1 + x2 ) / 2;
xmax = max( x2 - x1 );

