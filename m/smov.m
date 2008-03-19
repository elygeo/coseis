% Movie

% Basemap
clear all
%tsmap
%somap
sofig
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
if ~exist( '/tmp/gely/tmp', 'dir' ), mkdir /tmp/gely/tmp, end
vscale = 1;
meta

% Parameters
xzone = 0;  fzone = 1;  squared = 0; % TeraShake
xzone = 13; fzone = 18; squared = 1; % SORD
xzone = 2;  fzone = 1;  squared = 0; % ShakeOut
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
node = all( nn(1:2) == i2(1:2) - i1(1:2) + 1 );
its = i1(4):dit:i2(4);
its = 900;

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
hsurf = surf( x(:,:,2), x(:,:,1), x(:,:,2) );
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
hlit = camlight;

% Legend
axes( 'Position', [ 0 0 1 1 ] )
hclk = digitalclock( 7, 7, 16, 'k' );
axis off
axis( [ 0 300 0 620 ] )
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
set( [ hclk(1,m+1) hclk(2,s10+1) hclk(3,s1+1) hclk(1,11) ], 'Visible', 'on' )
s = vscale * read4d( fzone, it );
if isempty( s ), error, end 
if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
if squared, s = sqrt( s ); end
z = s ./ flim(2);
z(end+1,:) = z(end,:);
z(:,end+1) = z(:,end);
z(2:end-1,:) = .5 * ( z(1:end-2,:) + z(2:end-1,:) );
z(:,2:end-1) = .5 * ( z(:,1:end-2) + z(:,2:end-1) );
z = sqrt( z );
set( hsurf, 'CData', s )
set( hsurf, 'ZData', 2000 * z - 4000 )
set( hlit, 'Visible', 'on' )
c = get( hclk(1), 'Tag' );
set( hclk, 'Color', c, 'MarkerFaceColor', c )
colorscheme( cs, ce )
caxis( haxes(1), flim )
img = snap( [ '/tmp/gely/' file ], dpi*aa, 1 );
set( hlit, 'Visible', 'off' )
set( hclk, 'Color', fg, 'MarkerFaceColor', fg )
colorscheme( as, ae )
caxis( haxes(1), alim )
alpha = snap( [ '/tmp/gely/' file ], dpi*aa, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
imwrite( uint8( img ), file, 'Alpha', alpha )
system( [ 'rmdir ' file '.lock' ] );
end
end

