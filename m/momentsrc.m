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

% Indeices
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
  w1(:,:,:,i) = w1(:,:,:,i) - xsource(i);
end
s2 = sqrt( sum( w1 .* w1, 4 ) );
[ junk, isource ] = min( s2(:) );
isrc = find( s2 <= rsource );

% Weight by distance from hypocenter
clear srcfr
switch spacefn
case 'box',  srcfr = ones( size( isrc ) );
case 'tent', srcfr = rsource - s2( isrc );
end

% Normalize and devide by cell volume
srcfr = srcfr / sum( srcfr ) ./ s1( isrc );

s1(:) = 0.;
s2(:) = 0.;

% Metadata
c = [ 1 6 5; 6 2 4; 5 4 3 ];
[ vec, val ] = eig( moment(c) );
m0 = max( abs( val(:) ) );
mw = 2. / 3. * log10( m0 ) - 10.7;
d  = m0 / ( rho * vs * vs * dx * dx );
fid = fopen( 'out/sourcemeta', 'w' );
fprintf( fid, 'xsource   %g %g %g\n',          xsource          );
fprintf( fid, 'rsource   %g\n',                rsource          );
fprintf( fid, 'tsource   %g\n',                tsource          );
fprintf( fid, 'spacefn   %s\n',                spacefn          );
fprintf( fid, 'timefn    %s\n',                timefn           );
fprintf( fid, 'moment    %g %g %g %g %g %g\n', moment1, moment2 );
fprintf( fid, 'vp        %g\n',                vp               );
fprintf( fid, 'm0        %g\n',                m0               );
fprintf( fid, 'mw        %g\n',                mw               );
fprintf( fid, 'd         %g\n',                d                );
close( fid )

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
  w1(isrc+o*i) = w1(isrc+o*i) - srcft * srcfr * moment(i+1);
  w2(isrc+o*i) = w2(isrc+o*i) - srcft * srcfr * moment(i+4);
end

