%------------------------------------------------------------------------------%
% COLORSCALE

if initialize > 1
  hand = axes;
  haxes(end+1) = hand;
  set( gcf, 'CurrentAxes', hand )
  axis( [ 0 1 0 1 ] );
  hold on
  hlegend(3) = surf( [ 0 1 ], [ 0 .08 ], [ 0 0; 0 0 ], ...
    'FaceColor', 'k', ...
    'EdgeColor', 'none', ...
    'FaceLighting', 'none', ...
    'EdgeLighting', 'none' );
  hlegend(1) = text( .1, .05, '0' );
  hlegend(2) = text( .9, .05, '1' );
  hlegend(4) = plot( [ 0 1 ], [ .08 .08 ], 'Color', 0.25 * [ 1 1 1 ] );
  hlegend(5) = imagesc( [ .1 .9 ], [ .058 .06 ], 0:.001:1 );
  set( hlegend, 'HandleVisibility', 'off' )
  set( gcf, 'CurrentAxes', haxes(1) )
  return
end

uscl = ulim; if uscl < 0, uscl = umax; end;
vscl = vlim; if vscl < 0, vscl = vmax; end;
wscl = wlim; if wscl < 0, wscl = wmax; end;
xscl = xlim; if xscl < 0, xscl = umax; end;
if xscl, xscl = .5 * h / xscl; end
cellfocus = 1;
switch field
case 'u', fscl = uscl; titles = { '|V|' 'Ux' 'Uy' 'Uz' }; cellfocus = 0;
case 'v', fscl = vscl; titles = { '|V|' 'Vx' 'Vy' 'Vz' }; cellfocus = 0;
case 'w', fscl = wscl; titles = { '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
end
clim = fscl;
if ~clim, clim = 1; end
set( gca, 'CLim', clim * [ -1 1 ] );
if comp
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
  end
  hh = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : hh : 1;
  x2 = -1 : .0001 : 1;
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
      2 1 1 2 2 1
      2 1 2 2 1 0
      2 2 2 1 1 0 ]' / 2;
  end
  hh = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : hh : 1;
  x2 = -1 : .0001 : 1;
  x2 = abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(2), 'Clim', [ -1 1 ] )
  set( hlegend(1), 'String', '0' )
  set( hlegend(2), 'String', sprintf( '%g',  clim ) )
end

