% Movie

clear all

% Basemap
tsmap
basemap = single( imread( 'basemap.png' ) );
[ overlay, tmp, alpha ] = imread( 'overlay.png' );
alpha = single( alpha );
overlay = single( overlay );
alpha = ( 1. - alpha / 255 );
for i = 1:3
  basemap(:,:,i) = alpha .* basemap(:,:,i);
end
delete( [ hmap hover ] )

meta
fzone = 1;
squared = 0;
node = 0;
flim = [ 0 1 ];
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
its = i1(4):dit:i2(4);
its = 3000;
tt = nt * dt;

% Data
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
if ~exist( '/tmp/gely/tmp', 'dir' ), mkdir /tmp/gely/tmp, end
meta
[ x, x2 ] = ndgrid( 0:dx:dx*nn(1), 0:dx:dx*nn(2) );
x(:,:,2) = x2;
if node
  x(end+1,:,:) = x(end,:,:);
  x(:,end+1,:) = x(:,end,:);
  x(2:end-1,:,:) = .5 * ( x(1:end-2,:,:) + x(2:end-1,:,:) );
  x(:,2:end-1,:) = .5 * ( x(:,1:end-2,:) + x(:,2:end-1,:) );
end
axes( haxes(1) )
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
file = sprintf( 'tmp/f%05d.png', it );
if ~exist( file, 'file' ) & ~system( [ 'mkdir ' file '.lock >& /dev/null' ] )
disp( file )
t = 2 * pi * it * dt;
set( hclk(1), ...
  'XData', xx(1) + rr * sin( t / 360 ) * [ -.2 1 ], ...
  'YData', yy(1) + rr * cos( t / 360 ) * [ -.2 1 ] );
set( hclk(1), ...
  'XData', xx(1) + rr * sin( t ) * [ -.2 1 ], ...
  'YData', yy(1) + rr * cos( t ) * [ -.2 1 ] );
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
set( hlit, 'Visible', 'on' )
colorscheme( 'hot', .25 )
caxis( haxes, flim )
img = snap( [ '/tmp/gely/' file ], dpi*aa, 1 );
set( hlit, 'Visible', 'off' )
colorscheme( 'kw1' )
caxis( haxes, [ .04 .06 ] )
w = snap( [ '/tmp/gely/' file ], dpi*aa, 1 );
w = alpha .* w(:,:,1) ./ 255;
for i = 1:3
  img(:,:,i) = ( 1 - w ) .* basemap(:,:,i) + w .* img(:,:,i) + overlay(:,:,i);
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
system( [ 'rmdir ' file '.lock' ] );
end
end

