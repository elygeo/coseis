% Terashake blocks

clear all
format compact
clf
pos = get( gcf, 'Position' );
set( gcf, 'Position', [ pos(1:2) 1280 720 ], 'Color', 'w' )

meta
isurf = [
   1  1  1     1  0 -1   -1
   1  0  1     1 -1 -1    1
  -1  1  1    -1  0 -1   -1
  -1  0  1    -1 -1 -1    1
   1  1  1    -1  1 -1   -1
   1 -1  1    -1 -1 -1    1
   1  0  1    -1  0 -1   -1
   1  0  1    -1  0 -1    1
   1  1 -1    -1  0 -1   -1
   1  0 -1    -1 -1 -1    1
];
clear h
for i = 1:size(isurf,1)
  i1 = isurf(i,1:3);
  i2 = isurf(i,4:6);
  off = 20000 * isurf(i,7);
  [ msg, x ] = read4d( 'x', [ i1 0 ], [ i2 0 ] );
  if msg, error( msg ), end
  x1 = squeeze(x(:,:,:,:,1));
  x2 = squeeze(x(:,:,:,:,2));
  x3 = squeeze(x(:,:,:,:,3));
  h(i) = surf( x1, x2 + off, x3 );
  hold on
end
shading interp
set( h, ...
  'FaceColor', [ .9 .9 .9 ], ...
  'EdgeColor', 'k', ...
  'AmbientStrength',  .6, ...
  'DiffuseStrength',  .4, ...
  'SpecularStrength', .5, ...
  'SpecularExponent',  5, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );

axis equal
axis vis3d
axis off
camtarget( 1000 * [ 338 120 -100 ] )
campos( 1000 * [ 877 237 150 ] )
camva( 28 )
camproj perspective
lighting phong
hl = light( 'Position', 1000 * [ -300 600 400 ], 'Style', 'local' );

