% ShakeOut figure

clear all
xzone = 0;  fzone = 1;  squared = 0; % TeraShake
xzone = 13; fzone = 18; squared = 1; % SORD
xzone = 2;  fzone = 1;  squared = 0; % ShakeOut
name = '';
vscale = 1;
meta
dit =  out{fzone}{3};
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
node = all( nn(1:2) == i2(1:2) - i1(1:2) + 1 );
its = i1(4):dit:i2(4);
its = 900;

dpi = 150;
dpi = 600;
ppi = 150;
cs = 'whot';
ce = .2;
as = 'wk1';
ae = .5;
flim = [  .1   2 ];
alim = [ .03 .05 ];
bg = [ 1 1 1 ];
fg = [ 0 0 0 ];
atran = [ 1 -1 ];
inches = [ 2 4.3 ];

% Setup
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
if ~exist( '/tmp/gely/tmp', 'dir' ), mkdir /tmp/gely/tmp, end
clf
drawnow
colorscheme( cs, ce )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'Position', [ pos(1:2) inches * ppi ], ...
  'PaperPosition', [ 0 0 inches ], ...
  'Color', 'w', ...
  'DefaultTextColor', fg, ...
  'DefaultTextFontSize', 8, ...
  'DefaultLineLinewidth', .5, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColor', 'none', ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
xl = 300;
yl = xl * inches(2) / inches(1);
axis( [ .01 xl .98 yl ] )
axis off
hold on
y = .5 * inches(2) / inches(1);
y0 = .4 * ( 1 - y );
haxes(1) = axes( 'Position', [ .01 y0 .98 y ] );
hold on
axis equal
axis( 1000 * [ 0 300 0 600 -80 80 ] )
axis ij
box on
set( gca, 'XTick', [], 'YTick', [] )

% Basemap
file = 'tmp/basemap.png';
if ~exist( file, 'file' )
n = [ 960 780 ];
fid = fopen( 'topo2.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo1.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
x = upsamp( x );
h = surf( x(:,:,1), x(:,:,2), x(:,:,3) - 4000 );
set( h, ...
  'EdgeColor', 'none', ...
  'FaceColor', [ .85 .85 .85 ], ...
  'AmbientStrength',  .6, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 5, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
camlight;
[ y, x, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' );
plot( x, y, 'LineWidth', .1, 'Color', [ .7 .7 .7 ] );
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
[ y, x, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' ); plot( x, y, '--', 'LineWidth', 0.75 );
[ y, x, z ] = textread( 'borders.xyz',  '%n%n%n%*[^\n]' ); plot( x, y );
[ y, x, z ] = textread( 'coast.xyz',    '%n%n%n%*[^\n]' ); plot( x, y );
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
  501570  31135  24 'top' 'left'   'Ensenada'
  526989 167029   1 'bottom'    'left'   'Mexicali'
  581530 224874  40 'bottom' 'center' 'Yuma'
};
x = [ sites{:,2} ];
y = [ sites{:,1} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
plot( x, y, 'o', 'MarkerSize', 2.5, 'LineWidth', .65 );
h = [];
for i = 1:length(x)
  dy = -1600;
  if strcmp( ver{i}, 'top' ), dy = 1600; end
  h(end+1) = text( x(i), y(i)+dy, 10, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end
h = pmb( h, 1500, 1500 );
set( h, 'Color', bg );

axes( haxes(2) )
htitle = text( 150, yl-1, name, 'Hor', 'center', 'Ver', 'top' );
x = 175 + [ -100 100 ];
y = 26 + [ -3 3 ];
caxis( flim )
colorscale( '1', x, y, [ 0 2 ], 'b', '0', '2 m/s' )
if 0
text( x-20, y-20, { 'Earthquake on Southernmost' 'San Andreas Fault' }, 'Color', 'w', 'FontWeight', 'normal', 'FontSize', 12, 'Ver', 'top', 'Hor', 'right' );
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
axis off
colorscheme( as, ae )
caxis( haxes(2), alim )
alpha = snap( '', dpi, 1 );
colorscheme( cs, ce )
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
hclk = digitalclock( 7, 7, 16, 'k' );

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

