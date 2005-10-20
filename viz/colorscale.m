% Color Scale

if ~exist( 'hlegend', 'var' )
  haxes(end+1) = axes( 'HitTest', 'off' );
  set( gcf, 'CurrentAxes', haxes(end) )
  axis( [ 0 1 0 1 ] );
  hold on
  hlegend(3) = surf( [ 0 1 ], [ 0 .08 ], [ 0 0; 0 0 ], ...
    'FaceColor', background, ...
    'EdgeColor', 'none', ...
    'FaceLighting', 'none', ...
    'EdgeLighting', 'none' );
  hlegend(4) = plot( [ 0 1 ], [ .08 .08 ], 'Color', .5 * [ 1 1 1 ] );
  hlegend(1) = text( .1, .05, '0' );
  hlegend(2) = text( .9, .05, '1' );
  hlegend(5) = imagesc( [ .1 .9 ], [ .058 .06 ], 0:.001:1 );
  set( hlegend,  'HitTest', 'off', 'HandleVisibility', 'off' )
  %set( haxes(2), 'HitTest', 'off' )
  set( gcf, 'CurrentAxes', haxes(1) )
end

clim = fscl;
if ~clim, clim = 1; end
set( gca, 'CLim', clim * [ -1 1 ] );
poscolor = [ 1 .5 0 ];
negcolor = [ 0 .5 1 ];
if icomp
  if dark
    cmap = [
      0 0 0 1 1
      1 0 0 0 1
      1 1 0 0 0 ]';
  else
    cmap = [
      1 1 2 2 2
      2 1 2 1 2
      2 2 2 1 1 ]' / 2;
    cmap = [
      0 0 1 1 1
      0 1 1 1 0
      1 1 1 0 0 ]';
  end
  hh = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : hh : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(2), 'Clim', [ 0 1 ] )
  set( hlegend(1), 'String', sprintf( '%g', -clim ) )
  set( hlegend(2), 'String', sprintf( '%g',  clim ) )
else
  if dark
    cmap = [
      0 0 0 1 1 1
      0 0 1 1 0 0
      0 1 1 0 0 1 ]';
  else
    cmap = [
      4 1 1 4 4 1
      4 1 4 4 1 0
      4 4 4 1 1 0 ]' / 4;
  end
  hh = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : hh : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(2), 'Clim', [ -1 1 ] )
  set( hlegend(1), 'String', '0' )
  set( hlegend(2), 'String', sprintf( '%g',  clim ) )
end

