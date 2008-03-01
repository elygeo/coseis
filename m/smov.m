% Movie

clear all
tsmap
meta

fzone = 1;
squared = 0;
node = 0;
flim = [ 0 1 ];
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
its = i1(4):dit:i2(4);
its = 600;
tt = nt * dt;
xbar = 450;

% Basemap
x = 1000 * res(1) / res(2); 
y = 1000;
axes( 'Position', [ 0 0 1 1 ] )
plot( 20 + [ 0 xbar ], [ 30 30 ], '-', 'Color', .3*[1 1 1], 'LineWidth', 3*scl )
hold on
hbar = plot( 20 + [ 0 0 ], [ 30 30 ], 'w-', 'LineWidth', 3*scl );
for t = 60:60:tt-1
  plot( 20 + [ 1 1 ] * xbar * t / tt, [ 20 30 ], 'k-', 'LineWidth', scl )
end
axis( [ 0 x 0 y ] )
axis off
if ~exist( 'basemap.png', 'file' ), snap( 'basemap.png', dpi*aa, 1 ), end
delete( hmap )
htime = text( 40 + xbar, 30, '0:00', 'Hor', 'left', 'Ver', 'middle' );
basemapimg = single( imread( 'basemap.png' ) );

% Data
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
meta
[ x, x2 ] = ndgrid( 0:dx:dx*nn(1), 0:dx:dx*nn(2) );
x(:,:,2) = x2;
if node
  x(end+1,:,:) = x(end,:,:);
  x(:,end+1,:) = x(:,end,:);
  x(2:end-1,:,:) = .5 * ( x(1:end-2,:,:) + x(2:end-1,:,:) );
  x(:,2:end-1,:) = .5 * ( x(:,1:end-2,:) + x(:,2:end-1,:) );
end
axes( haxes )
hsurf = surf( x(:,:,1), x(:,:,2), x(:,:,2) );
set( hsurf, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .5, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
for it = its
file = sprintf( 'tmp/surface%04d.png', it );
if ~exist( file, 'file' ) & ~system( [ 'mkdir ' file '.lock' ] )
it
t = it * dt;
mm = floor( t / 60 );
ss = round( rem( t, 60 ) );
set( htime, 'String', sprintf( '%1.0f:%02.0f', mm, ss ) )
set( hbar, 'XData', 20 + [ 0 xbar * t / tt ] )
s = read4d( fzone, it );
if isempty( s ), error, end 
if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
if squared, s = sqrt( s ); end
z = s;
z(end+1,:) = z(end,:);
z(:,end+1) = z(:,end);
z(2:end-1,:) = .5 * ( z(1:end-2,:) + z(2:end-1,:) );
z(:,2:end-1) = .5 * ( z(:,1:end-2) + z(:,2:end-1) );
set( hsurf, 'CData', s )
set( hsurf, 'ZData', 2000 * z - 4000 )
set( hsurf, 'FaceLighting', 'phong' )
colorscheme( 'hot', .25 )
caxis( haxes, flim )
img = snap( file, dpi*aa, 1 );
set( hsurf, 'FaceLighting', 'none' )
colorscheme( 'kw1' )
caxis( haxes, [ .04 .06 ] )
w = snap( file, dpi*aa, 1 );
w = w(:,:,1) ./ 255;
for i = 1:3
  img(:,:,i) = ( 1 - w ) .* basemapimg(:,:,i) + w .* img(:,:,i);
end
n1 = size( img );
n2 = floor( n1 ./ aa );
if aa > 1
  img2 = repmat( single(0), [ n2(1:2) 3 ] );
  o = round( .5 * ( n1 - aa * n2 ) );
  for j = 1:aa
  for k = 1:aa
    img2 = img2 + single( img(o(1)+j:aa:n1(1),o(2)+k:aa:n1(2),:) );
  end
  end
  img = img2 ./ ( aa * aa );
  clear img2
end
imwrite( uint8( img ), file )
system( [ 'rmdir ' file '.lock' ] )
end
end

