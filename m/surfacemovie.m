% Terashake map plot

clear all
field = 'vm';
meta
t = 0:10:nt;
flim = 1;
cellfocus = 0;

format compact
clf
colorscheme
pos = get( gcf, 'Position' );
set( gcf, ...
  'DefaultLineMarkerFaceColor', 'w', ...
  'DefaultLineMarkerEdgeColor', [ .1 .1 .1 ], ...
  'DefaultLineClipping', 'on', ...
  'DefaultTextClipping', 'on', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )

% Legend & Basemap
cwd = pwd;
srcdir
cd data
set( gcf, 'Position', [ pos(1:2) 1280 80 ] )
axes( 'Position', [ 0 0 1 1 ] )
text( 20, 29, 'Surface Velocity Magnitude' );
hold on
text( 20, 19, 'M7.6 Southern San Andreas Senario' );
text( 20,  9, 'SORD Rupture Dynamics Simulation' );
a = 40;
c = cos( a / 180 * pi );
s = sin( a / 180 * pi );
x = 200 + 9 * [ c -c; s -s ]';
y =  19 + 9 * [ s -s; -c c ]';
z =  [ 0 0; 0 0 ];
plot3( x, y, z )
x = 200 + 13 * [ c -c; s -s ]';
y =  19 + 13 * [ s -s; -c c ]';
h    = text( x(1), y(1), 0, 'E' );
h(2) = text( x(2), y(2), 0, 'W' );
h(3) = text( x(3), y(3), 0, 'S' );
h(4) = text( x(4), y(4), 0, 'N' );
set( h, 'Rotation', a, 'Hor', 'center', 'FontSize', 12 )
caxis( flim * [ -1 1 ] )
lengthscale( 320 + [ -50 50 ], 29 + [ -1.2 1.2 ], 'km' )
colorscale(  320 + [ -50 50 ], 18 + [ -2.4 2.4 ], 'm/s' )
scec = imread( 'scec.png'  );
sdsu = imread( 'sdsu.png' );
sio  = imread( 'sio.png'  );
igpp = imread( 'igpp.png' );
y =  19 - 12 * [ -1 1 ];
x = 600 - 24 * flipud( cumsum( [ 0
  size(scec,2) / size(scec,1)
  size(sdsu,2) / size(sdsu,1)
  size(sio,2)  / size(sio,1)
  size(igpp,2) / size(igpp,1) ] ) );
image( x(1:2) - 50, y, igpp )
image( x(2:3) - 40, y, sio  )
image( x(3:4) - 30, y, sdsu )
image( x(4:5) - 20, y, scec )
axis( [ 0 600 0 37.5 ] )
axis off
leg = snap;
clf
basemap = imread( 'basemap.png' );
basemap = single( basemap );
n = size( basemap );
cd( cwd )

% Data
set( gcf, 'Position', [ pos(1:2) 1280 640 ] )
axes( 'Position', [ 0 0 1 1 ] )
meta
i1 = [  1  1 -1 ];
i2 = [ -1 -1 -1 ];
[ msg, x ] = read4d( 'x', [ i1 0 ], [ i2 0 ] );
if msg, error( msg ), end
axes( 'Position', [ 0 0 1 1 ] )
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3) );
hold on
htime = text( 8000, 294000, 10000, 'Time = 0s', 'Ver', 'top' );
view( 0, 90 )
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
axis off
caxis( flim * [ -1 1 ] )
shading flat
for it = t
  it
  set( htime, 'String', sprintf( 'Time = %5.1fs', it * dt ) )
  [ msg, s ] = read4d( field, [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
  if ~cellfocus
    s(1:end-1,1:end-1) = .25 * ( ...
      s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
      s(1:end-1,2:end)   + s(2:end,2:end) );
  end
  set( hsurf, 'CData', s )
  set( htime, 'String', sprintf( 'Time = %.1fs', it * dt ) )
  img = single( snap );
  img = reshape( img, prod( n(1:2) ), 3 );
  w = img * [ .3 .59 .11 ]' / 255;
  w = .5 * ( 1 - w ) .^ 2;
  w = reshape( w, n(1:2) );
  img = reshape( img, n );
  for i = 1:3
    img(:,:,i) = img(:,:,i) + w .* basemap(:,:,i);
  end 
  img = uint8( img );
  img([1 end],:,:) = 255;
  img(:,[1 end],:) = 255;
  img = [ img; leg ];
  img([1 end],:,:) = 255;
  img(:,[1 end],:) = 255;
  file = sprintf( 'tmp/surf/%04d.png', it );
  imwrite( img, file )
end

