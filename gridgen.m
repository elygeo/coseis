%------------------------------------------------------------------------------%
% GRIDGEN

disp( 'Grid generation' )
L = n - 3;
if nrmdim, L(nrmdim) = L(nrmdim) - 1; end
L1 = L(1);
L2 = L(2);
L3 = L(3);
[x1, x2, x3] = ndgrid( 0:L1*one, 0:L2*one, 0:L3*one );
xx1 = x1;
xx2 = x2;
xx3 = x3;
c = 0;
c = 0.2 * L3;
c = 0.01 * L3;
c = 0.06 * L3;
c = 0.1 * L3;
rand( 'state', 0 )
switch grid
case 'constant'
  operator = { 'constant'  1 -1   1 -1   1 -1 };
  %if nrmdim, operator = 'rectangular'; end
case 'staggered'
  operator = { 'staggered'  1 -1   1 -1   1 -1 };
  staggerbc1 = 1; % normal v at the surface
  staggerbc1 = 0; % horizontal v at the surface
case 'map'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  xx1 = x1 + .1 * (cos(x3./L3*2*pi)-sin(x2./L2*2*pi)) .* (L1-x1) + .1 * (L2-x2) .* (x1-L1);
  xx2 = x2 + c / 5 * (x2-L2/2) .* (L1-x1);
  xx3 = x3 + c / 5 * (x3-L2/2) .* (L1-x1);
case 'normal'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  xx1 = x1 + c * (x1./L1-1) .* atan(10*(x3./L3-.5));
  xx3 = x3 - c * (x1./L1-.5) * 4 .* (.5-abs(x3./L3-.5));
  %moment = -[0 0 0 0 0 1e18];
  h = 1.5 * h;
case 'curve'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  dem = .2 * rand( [ 1 L2+1 L3+1 ] ) .* (-1.5-atan(10*(x3(1,:,:)./L3-.5))) + c*(x1(1,:,:)./L1-1).*atan( 10*(x3(1,:,:)./L3-.5) );
  xx1 = x1 + (1-x1./L1) .* repmat(dem,[L1+1 1 1]);
  xx2 = x2 + c * sin(x3./L3*2*pi) .* (.5-abs(x2./L2-.5));
  xx3 = x3 - c * sin(x2./L2*2*pi) .* (.5-abs(x3./L3-.5));
  h = 1.5 * h;
case 'spherical'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  da = pi / 2 / max( [ L2 L3 ] );
  %rr = 2 * L1 - x1 - 1 / da;
  rr = 2 * L1 - x1;
  a = ( x2 - L2 / 2 ) * da;
  b = ( x3 - L3 / 2 ) * da;
  xx1 = -rr ./ sqrt( 1 + tan(a).^2 + tan(b).^2 );
  xx2 = -tan(a) .* xx1;
  xx3 = -tan(b) .* xx1;
  xx1 = xx1 - min( xx1(:) );
  h = 1.5 * h;
case 'slant'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  theta = 30 * pi / 180;
  xx1 = x1 * cos( theta );
  xx2 = x2 - x1 * sin( theta );
  scl = 1.25;
  xx1 = scl * xx1;
  xx2 = scl * xx2;
case 'stretch'
  operator = { 'rectangular'  1 -1   1 -1   1 -1 };
  xx2 = 2 * x2;
case 'hill'
  operator = { 'som'  1 -1   1 -1   1 -1 };
  xx1 = x1 - .25 * (L1-x1) .* exp(-((x2-L2/2).^2 + (x3-L3/2).^2) / ((L2 + L3)/10) ^ 2);
case 'rand'
  operator = { 'som'  1 -1   1 -1   1 -1 };
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
if noise, operator = { 'som'  1 -1   1 -1   1 -1 }; end
clear x1 x2 x3
%x = repmat( zero, [ n 3 ] );
tmp = rand( [ L1 L2 L3 ] + 1 ); x(:,:,:,1) = xx1 + noise * ( tmp - .5 );
tmp = rand( [ L1 L2 L3 ] + 1 ); x(:,:,:,2) = xx2 + noise * ( tmp - .5 );
tmp = rand( [ L1 L2 L3 ] + 1 ); x(:,:,:,3) = xx3 + noise * ( tmp - .5 );
clear xx1 xx2 xx3
x = x([1 1:end end],[1 1:end end],[1 1:end end],:);
switch nrmdim
case 1, x = x([1:hypocenter(1) hypocenter(1):end],:,:,:);
case 2, x = x(:,[1:hypocenter(2) hypocenter(2):end],:,:);
case 3, x = x(:,:,[1:hypocenter(3) hypocenter(3):end],:);
end
h = h / ( 1 - noise );
x = h * x;
r0 = min( reshape( x, [ prod(n) 3 ] ) );
r1 = max( reshape( x, [ prod(n) 3 ] ) );
rc = double( r1 + r0 ) / 2;
L  = double( max( r1 - r0 ) );

