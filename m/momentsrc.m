%----------------------------------------------------------------------------%
% MOMENTSRC

if rsource <= 0.; return; end

if init

init = 0;
fprintf( 'Moment source\n' )
if rsource && sum( abs( moment ) )
else
  rsource = 0.;
  return
end
i1 = i1cell;
i2 = i2cell;
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);

% Cell volumes
s1(:) = 0.;
s1(j,k,l) = dfnc( 'g', x, x, dx, 1, 1, j, k, l );

% Cell center locations
w1(:) = 2 * rsource;
w1(j,k,l,:) = 0.125 * ...
  ( x(j,k,l,:) + x(j+1,k+1,l+1,:) ...
  + x(j+1,k,l,:) + x(j,k+1,l+1,:) ...
  + x(j,k+1,l,:) + x(j+1,k,l+1,:) ...
  + x(j,k,l+1,:) + x(j+1,k+1,l,:) );

% Cell hypocenter distance
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) - x0(i);
end

% Find cells within source radius
s2 = rsource - sqrt( sum( w1 .* w1, 4 ) );
imsrc = find( s2 > 0. );

% Weight by distance from hypocenter
msrcv = s1( imsrc );
msrcx = s2( imsrc );
msrcx = msrcx / sum( msrcx ) ./ msrcv;

s1(:) = 0.;
s2(:) = 0.;

% Useful info
c = [ 1 6 5; 6 2 4; 5 4 3 ];
[ vec, val ] = eig( moment(c) );
m0 = max( abs( val(:) ) );
mw = 2. / 3. * log10( m0 ) - 10.7;
um = m0 / mu0 / dx / dx;
fprintf( '  M0:%12.4e\n', m0 )
fprintf( '  Mw:%12.4e\n', mw )
fprintf( '  D: %12.4e\n', um )

return

end

%----------------------------------------------------------------------------%

switch sourcetimefn
case 'delta',  msrcf = 1.; if it == 1, msrcf = 1.; end
case 'brune',  msrcf = 1. - exp( -t / tsource ) / tsource * ( t + tsource );
case 'sbrune', msrcf = 1. - exp( -t / tsource ) / tsource * ...
  ( t + tsource + t * t / tsource / 2. );
otherwise error 'sourcetimefn'
end

o = prod( nm );
for i = 0:2
  w1(imsrc+o*i) = w1(imsrc+o*i) - msrcf * msrcx * moment(i+1);
  w2(imsrc+o*i) = w2(imsrc+o*i) - msrcf * msrcx * moment(i+4);
end

