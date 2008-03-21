% ShakeOut figure

clear all
mov = 0; bg = 'w'; fg = 'k'; clockcolor = 'k'; atran = [ 1 -1 ]; dpi = 600;
mov = 1; bg = 'k'; fg = 'w'; clockcolor = 'g'; atran = [ 0  1 ]; dpi = 300;
xzone = 0;  fzone = 1;  squared = 0; % TeraShake
xzone = 13; fzone = 18; squared = 1; % SORD
xzone = 2;  fzone = 1;  squared = 0; % ShakeOut
name = '';
vscale = 1;
itoff = 0;
meta
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
node = all( nn(1:2) == i2(1:2) - i1(1:2) + 1 );
its = 300:300:1500;
its = 900;
its = i1(4):dit:i2(4);

flim = [ .07   2 ];
alim = [ .03 .05 ];
shadow = [ .1 .1 .1 ];
ms = [ bg 'earth' ];
cs = [ bg 'hot' ];
as = [ bg fg '1' ]; 
ce = .5;
ae = 1;
inches = [ 3.2 5.4 ];
ppi = 150;

% Setup
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
if ~exist( '/tmp/gely/tmp', 'dir' ), mkdir /tmp/gely/tmp, end
clf
drawnow
colorscheme( ms, .4 )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'Position', [ pos(1:2) inches * ppi ], ...
  'PaperPosition', [ 0 0 inches ], ...
  'DefaultAxesColor', 'none', ...
  'DefaultAxesColorOrder', [ 0 0 0 ], ...
  'DefaultTextFontSize', 10, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes(2) = axes( 'Position', [ .005 .005 .99 .99 ] );
axis off
hold on
xl = 300;
yl = xl * inches(2) / inches(1);
axis( [ .01 xl .98 yl ] )
haxes(1) = axes( 'Position', [ .005 .04 .99 .94 ] );
axis off
hold on
axis equal
axis( 1000 * [ 0 300 50 510 -80 80 ] )
axis ij

% Basemap
file = 'tmp/basemap.png';
if ~exist( file, 'file' )
n = [ 960 780 ];
fid = fopen( 'topo2.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo1.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
x = upsamp( x );
c = x(:,:,3);
c(x(:,:,1)>102000) = max( 10., c(x(:,:,1)>102000) );
c = .25 * ...
  ( c(1:end-1,1:end-1) + c(2:end,2:end) ...
  + c(1:end-1,2:end) + c(2:end,1:end-1) );
h = surf( x(:,:,1), x(:,:,2), x(:,:,3) - 4000, c );
clear x c
[ y, x, z ] = textread( 'salton.xyz', '%n%n%n%*[^\n]' );
z(:) = -1;
h(end+1) = patch( x, y, z - 4000, z );
set( h, ...
  'EdgeColor', 'none', ...
  'FaceColor', 'flat', ...
  'AmbientStrength',  .5, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
camlight;
caxis( 4000 * [ -1 1 ] )
[ y, x, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' );
plot( x, y, 'LineWidth', .2, 'Color', [ .6 .6 .6 ] );
[ y, x, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ y, x, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ y, x, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' );
plot( x, y, '-',  'Color', shadow,  'LineWidth', 2.5 );
plot( x, y, '--', 'Color', 'w', 'LineWidth', 1.5 );
img = snap( [ '/tmp/gely/' file ], dpi, 1 );
imwrite( uint8( img ), file, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
delete( get( haxes(1), 'Children' ) )
end

% Overlay
file = 'tmp/overlay.png';
if ~exist( file, 'file' )
x = xlim; x = x([ 1 1 2 2 1]);
y = ylim; y = y([ 1 2 2 1 1]);
plot( x, y, 'Clipping', 'off' );
sites = {
   82188 188340 129 'bottom' 'center' 'Bakersfield'
   99691  67008  21 'bottom' 'center' 'Santa Barbara'
  152641  77599  16 'bottom' 'right'  'Oxnard'
  191871 180946 714 'bottom' 'left'   'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  263052 216515 831 'bottom' 'left'   'Victorville'
  268435 120029  47 'bottom' 'right'  'Anaheim'
  293537 180173 327 'top'    'right'  'San Bernardino'
  366020 200821 140 'bottom' 'right'  'Palm Springs'
  402013  69548  23 'top'    'center' 'San Diego'
};
x = [ sites{:,2} ];
y = [ sites{:,1} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
hdots = plot( x, y, 'o', 'MarkerSize', 3.5, 'LineWidth', .75 );
htxtf = [];
for i = 1:length(x)
  dy = -1600;
  if strcmp( ver{i}, 'top' ), dy = 1600; end
  htxtf(end+1) = text( x(i), y(i)+dy, 10, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end
set( htxtf, 'FontWeight', 'bold', 'FontSize', 9 );
htxtb = pmb( htxtf, 800, 800 );

axes( haxes(2) )
htitle = text( 150, yl, name, 'Hor', 'center', 'Ver', 'top' );
x = 175 + [ -100 100 ];
y = 22 + [ -3 3 ];
caxis( flim )
h = colorscale( '1', x, y, [ alim(2) flim(2) ], 'b', num2str(alim(2)), '2 m/s' );
if mov, set( h(2), 'Visible', 'off' ), end
axis off
colorscheme( as, ae )
caxis( haxes(2), alim )
alpha = snap( '', dpi, 1 );
colorscheme( cs, ce )
set( hdots, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', shadow )
set( htxtf, 'Color', 'w' )
set( htxtb, 'Color', shadow )
caxis( haxes(2), flim )
img = snap( '', dpi, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
imwrite( uint8( img ), file, 'Alpha', alpha, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
delete( get( haxes(1), 'Children' ) )
delete( get( haxes(2), 'Children' ) )
end

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

% Clock
axes( haxes(2) )
hclk = digitalclock( 5, 5, 16, clockcolor );

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
s = vscale * read4d( fzone, it+itoff );
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
set( hlit, 'Visible', 'off' )
set( hclk, 'Color', fg, 'MarkerFaceColor', fg )
colorscheme( as, ae )
caxis( haxes(1), alim )
alpha = snap( [ '/tmp/gely/' file ], dpi, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
set( hlit, 'Visible', 'on' )
c = get( hclk(1), 'Tag' );
set( hclk, 'Color', c, 'MarkerFaceColor', c )
colorscheme( cs, ce )
caxis( haxes(1), flim )
img = snap( [ '/tmp/gely/' file ], dpi, 1 );
imwrite( uint8( img ), file, 'Alpha', alpha, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
system( [ 'rmdir ' file '.lock' ] );
end
end

