% Movie

% Basemap
clear all
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
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
if ~exist( '/tmp/gely/tmp', 'dir' ), mkdir /tmp/gely/tmp, end
meta

% Parameters
xzone = 13; fzone = 18; squared = 1; node = 1;
xzone = 0;  fzone = 1;  squared = 0; node = 0;
xzone = 2;  fzone = 1;  squared = 0; node = 0;
flim = [ 0 1 ];
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
its = i1(4):dit:i2(4);

% Surface
axes( haxes(1) )
if xzone
  x = read4d( xzone, [ 0 0 -1 0 ] );
  if isempty( x ), error, end
  x = squeeze( x );
else
  [ x, x2 ] = ndgrid( 0:dx:dx*nn(1), 0:dx:dx*nn(2) );
  x(:,:,2) = x2;
  clear x2
end
if node
  x(end+1,:,:) = x(end,:,:);
  x(:,end+1,:) = x(:,end,:);
  x(2:end-1,:,:) = .5 * ( x(1:end-2,:,:) + x(2:end-1,:,:) );
  x(:,2:end-1,:) = .5 * ( x(:,1:end-2,:) + x(:,2:end-1,:) );
end
hsurf = surf( x(:,:,1), x(:,:,2), x(:,:,2) );
clear x
set( hsurf, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .5, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );

% Legend
axes( haxes(2) )
if 0
text( x-20, y-20, { 'Earthquake on Southernmost' 'San Andreas Fault' }, 'Color', 'w', 'FontWeight', 'normal', 'FontSize', 12*scl, 'Ver', 'top', 'Hor', 'right' );
text( 20, 60, { 'SORD rupture dynamics simulation' }, 'Color', 'w', 'FontWeight', 'normal', 'Ver', 'bottom', 'Hor', 'left' );
scec = imread( 'scec.png'  );
sdsu = imread( 'sdsu.png' );
sio  = imread( 'sio.png'  );
igpp = imread( 'igpp.png' );
y = 70 * [ 1 0 ];
x = 70 * cumsum( [ 0
  size(igpp,2) / size(igpp,1)
  size(sio,2)  / size(sio,1)
  size(sdsu,2) / size(sdsu,1)
  size(scec,2) / size(scec,1) ] );
image( x(1:2) + 20, y + 100, igpp );
image( x(2:3) + 40, y + 100, sio  );
image( x(3:4) + 60, y + 100, sdsu );
image( x(4:5) + 80, y + 100, scec );
end

% Time loop
for it = its
file = sprintf( 'tmp/f%05d.png', it );
if ~exist( file, 'file' ) & ~system( [ 'mkdir ' file '.lock >& /dev/null' ] )
disp( file )
t = it * dt;
m = floor( t / 60 );
s10 = floor( mod( t, 60 ) / 10 );
s1 = floor( mod( t, 10 ) );
set( hclk, 'Visible', 'off' )
set( [ hclk(1,m+1) hclk(2,s10+1) hclk(3,s1+1) ], 'Visible', 'on' )
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
caxis( haxes(1), flim )
img = snap( [ '/tmp/gely/' file ], dpi*aa, 1 );
set( hlit, 'Visible', 'off' )
colorscheme( 'kw1' )
caxis( haxes(1), [ .04 .06 ] )
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

