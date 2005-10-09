% Moment source

if rsource <= 0.; return; end

if init

init = 0;
fprintf( 'Moment source\n' )

% Indeices
i1 = i1cell;
i2 = i2cell;
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);

% Cell volumes
s1(:) = 0.;
s1(j,k,l) = diffnc( 'g', x, x, dx, 1, 1, j, k, l );

% Cell center locations
w1(:) = 2 * rsource;
w1(j,k,l,:) = 0.125 * ...
  ( x(j,k,l,:) + x(j+1,k+1,l+1,:) ...
  + x(j+1,k,l,:) + x(j,k+1,l+1,:) ...
  + x(j,k+1,l,:) + x(j+1,k,l+1,:) ...
  + x(j,k,l+1,:) + x(j+1,k+1,l,:) );

% Cell hypocenter distance
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) - xsource(i);
end
s2 = sqrt( sum( w1 .* w1, 4 ) );
isrc = find( s2 <= rsource );

% Weight by distance from hypocenter
clear srcfr
switch rfunc
case 'box',  srcfr = ones( size( isrc ) );
case 'tent', srcfr = rsource - s2( isrc );
end

% Normalize and devide by cell volume
srcfr = srcfr / sum( srcfr ) ./ s1( isrc );

s1(:) = 0.;
s2(:) = 0.;

return

end

%----------------------------------------------------------------------------%

% Source time function
switch tfunc
case 'delta',  msrcf = 1.;
case 'brune',  msrcf = 1. - exp( -t / tsource ) / tsource * ( t + tsource );
case 'sbrune', msrcf = 1. - exp( -t / tsource ) / tsource * ...
  ( t + tsource + t * t / tsource / 2. );
otherwise error 'tfunc'
end

% Add to stress variables
o = prod( nm );
for i = 0:2
  w1(isrc+o*i) = w1(isrc+o*i) - srcft * srcfr * moment1(i+1);
  w2(isrc+o*i) = w2(isrc+o*i) - srcft * srcfr * moment2(i+1);
end

