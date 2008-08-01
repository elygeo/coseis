% ShakeOut figure

clear all
xzone = 0;  fzone = 1;  squared = 0; % TeraShake
xzone = 13; fzone = 18; squared = 1; % SORD
name = '';
vscale = 1;
itoff = 0;
meta
xzone = 1; fzone = 2; squared = 0; % ShakeOut
its = 900;
bg = 'k'; fg = 'w'; clk = 'g'; atran = [ 0  1 ]; its = 0:2:nt-itoff;
bg = 'w'; fg = 'k'; clk = 'k'; atran = [ 1 -1 ]; its = 300:300:nt-itoff;
its = nt; fzone = 3; % Shakeout Disp
its = nt; fzone = 5; % Shakeout PGV

panes = { 'URS/USC' 'SDSU/SDSC' 'CMU/PSC' };
flim = [ .08   2 ];
cs = [ bg 'hot' ]; alim = [ .035 .065 ]; lite = 0; cslim = [ 0.05 2 ]; fc = 'flat';
cs = [ bg '0'  ];  alim = [ -2 -1 ]; lite = 1; cslim = [ 0 2 ]; fc = [ .7 .7 .7 ];
shadow = [ .1 .1 .1 ];
ms = [ bg 'earth' ];
as = [ bg fg '1' ]; 
ce = .5;
ae = 1;
inches = [ 3.2 5.4 ];
dpi = 300;
ppi = 100;

% Setup
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
clf
drawnow
colorscheme( ms, .4 )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'Position', [ pos(1:2) inches * ppi ], ...
  'PaperPosition', [ 0 0 inches ], ...
  'DefaultAxesColor', 'none', ...
  'DefaultTextFontSize', 8, ...
  'DefaultTextFontWeight', 'bold', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes(2) = axes( 'Position', [ .005 .003 .99 .994 ] );
axis off
hold on
axis( 100 * [ 0 inches(1) 0 inches(2) ] )
haxes(1) = axes( 'Position', [ .005 .013 .99 .984 ] );
axis off
hold on
axis equal
axis( 1000 * [ 0 290 60 510 -80 80 ] )
axis ij

% Basemap
file = 'tmp/basemap.png';
if ~exist( file, 'file' )
disp( file )
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
  'FaceColor', fc, ...
  'AmbientStrength',  0.5, ...
  'DiffuseStrength',  0.5, ...
  'SpecularStrength', 0.5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
camlight( 'infinite' )
caxis( 4000 * [ -1 1 ] )
[ y, x, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' );
plot( x, y, 'LineWidth', .2, 'Color', [ .6 .6 .6 ] );
[ y, x, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ y, x, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ y, x, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' );
plot( x, y, '-',  'Color', shadow,  'LineWidth', 2.5 );
plot( x, y, '--', 'Color', 'w', 'LineWidth', 1.5 );
img = snap( file, dpi, 1 );
imwrite( uint8( img ), file, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
delete( get( haxes(1), 'Children' ) )
end

% Overlay
file = 'tmp/overlay.png';
if ~exist( file, 'file' )
disp( file )
hlite = [];
if lite
  [ y, x, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' );  hlite    = plot( x, y );
  [ y, x, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' );  hlite(2) = plot( x, y );
  [ y, x, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' ); hlite(3) = plot( x, y, '--' ); 
end
sites = {
   82188 188340 129 'top'    'center' 'Bakersfield'
   99691  67008  21 'top'    'center' 'Santa Barbara'
  152641  77599  16 'top'    'right'  'Oxnard'
  191871 180946 714 'bottom' 'left'   'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  263052 216515 831 'bottom' 'left'   'Victorville'
  268435 120029  47 'top'    'right'  'Anaheim'
  293537 180173 327 'top'    'right'  'San Bernardino'
  366020 200821 140 'top'    'right'  'Palm Springs'
  402013  69548  23 'top'    'center' 'San Diego'
  501570  31135  24 'bottom' 'left'   'Ensenada'
};
hdots = [];
htxtf = [];
htxtb = [];
if length( sites )
  x = [ sites{:,2} ];
  y = [ sites{:,1} ];
  ver = sites(:,4);
  hor = sites(:,5);
  txt = sites(:,6);
  hdots = plot( x, y, 'o', 'MarkerSize', 3.2, 'LineWidth', .5 );
  htxtf = [];
  for i = 1:length(x)
    dy = -1600;
    if strcmp( ver{i}, 'top' ), dy = 1600; end
    htxtf(end+1) = text( x(i), y(i)+dy, 10, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
  end
  htxtb = pmb( htxtf, 500, 500 );
end
x = xlim; x = x([ 1 1 2 2 1]);
y = ylim; y = y([ 1 2 2 1 1]);
plot( x, y, 'Clipping', 'off' );
axes( haxes(2) )
h = text( 125, 12, name );
if strcmp( name, panes{2} )
  h(2) = text( 160, 531, 'SCEC ShakeOut Simulations' );
end
set( h, 'FontSize', 12, 'FontWeight', 'normal' )
x = 250 + [ -40 40 ];
y = 18 + [ -2.5 2.5 ];
h = colorscale( '1', x, y, cslim, 'b', num2str( cslim(1) ), [ num2str( cslim(2) ) ' m/s' ] );
caxis( flim )
axis off
colorscheme( as, ae )
caxis( haxes(2), alim )
alpha = snap( file, dpi, 1 );
colorscheme( cs, ce )
set( hdots, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', shadow )
set( htxtf, 'Color', 'w' )
set( htxtb, 'Color', shadow )
set( hlite, 'Color', shadow )
caxis( haxes(2), flim )
img = snap( file, dpi, 1 );
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
  if isempty( x ), error 'no x data found', end
  x = squeeze( x );
else
  [ x, x2 ] = ndgrid( 0:dx:dx*nn(1), 0:dx:dx*nn(2) );
  x(:,:,2) = x2;
  clear x2
end
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
node = all( nn(1:2) == i2(1:2) - i1(1:2) + 1 );
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
  'AmbientStrength',  0, ...
  'DiffuseStrength',  1.3, ...
  'SpecularStrength', .0, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
hlit = camlight( 'infinite' );

% Clock
axes( haxes(2) )
hclk = digitalclock( 20, 5, 14, clk );

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
if isempty( s ), error 'no v data found', end 
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
alpha = snap( file, dpi, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
set( hlit, 'Visible', 'on' )
c = get( hclk(1), 'Tag' );
set( hclk, 'Color', c, 'MarkerFaceColor', c )
colorscheme( cs, ce )
caxis( haxes(1), flim )
img = snap( file, dpi, 1 );
imwrite( uint8( img ), file, 'Alpha', alpha, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
system( [ 'rmdir ' file '.lock' ] );
end
end

