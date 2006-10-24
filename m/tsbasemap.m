% Terashake basemap and legend

clear all
clf

cwd = pwd;
srcdir
cd data

colorscheme
pos = get( gcf, 'Position' );
set( gcf, ...
  'DefaultLineMarkerFaceColor', 'w', ...
  'DefaultLineMarkerEdgeColor', .15 * [ 1 1 1 ], ...
  'DefaultLineClipping', 'on', ...
  'DefaultTextClipping', 'on', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )
set( gcf, 'Position', [ pos(1:2) 1280 640 ] )
axes( 'Position', [ 0 0 1 1 ] )

% Topo
n = [ 960 780 ];
fid = fopen( 'topo1.l', 'r', 'l' ); x = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo2.l', 'r', 'l' ); y = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.l', 'r', 'l' ); z = fread( fid, n, 'float32' ); fclose( fid );
hsurf = surf( x, y, z - 4000 );
set( hsurf, ...
  'FaceColor', [ .2 .2 .2 ], ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .1, ...
  'DiffuseStrength',  .1, ...
  'SpecularColorReflectance', 1, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
light( 'Position', [ -300000 150000 100000 ] );

hold on
view( 0, 90 )
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
axis off

text( 3000, 3000, 0, 'GPE', 'Hor', 'left', 'Ver', 'bottom', 'FontSize', 8 )
[ x, y, z ] = textread( 'fault.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z, '--', 'LineW', 3 )
[ x, y, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z )
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot3( x, y, z )
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot3( x, y, z )

cd( cwd )

% Cities
sites = {
   82188 188340 129 'bottom' 'right'  'Bakersfield'
   99691  67008  21 'bottom' 'right'  'Santa Barbara'
  152641  77599  16 'bottom' 'right'  'Oxnard'
  191871 180946 714 'bottom' 'right'  'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  253599  98027   7 'bottom' 'center' 'Long Beach'
  256108 263112 648 'bottom' 'right'  'Barstow'
  263052 216515 831 'bottom' 'right'  'Victorville'
  278097 115102  36 'bottom' 'left'   'Santa Ana'
  293537 180173 327 'top'    'left'   'San Bernardino'
  296996 160683 261 'top'    'left'   'Riverside'
  351928  97135  18 'bottom' 'left'   'Oceanside'
  366020 200821 140 'top'    'center' 'Palm Springs'
  403002 210421 -18 'top'    'center' 'Coachella'
  402013  69548  23 'bottom' 'center' 'San Diego'
  501570  31135  24 'bottom' 'left'   'Ensenada'
  526989 167029   1 'top'    'left'   'Mexicali'
  581530 224874  40 'bottom' 'right'  'Yuma'
};
x = [ sites{:,1} ];
y = [ sites{:,2} ];
z = [ sites{:,3} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
plot3( x, y, z + 1000, 'ow', 'MarkerSize', 8, 'LineWidth', 2 );
hold on
for i = 1:length(x)
  dy = 3000;
  if strcmp( ver{i}, 'top' ), dy = -3000; end
  text( x(i), y(i)+dy, z(i) + 1000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end

img = snap;
img([1 end],:,:) = 255;
img(:,[1 end],:) = 255;
imwrite( img, 'basemap.png' )

