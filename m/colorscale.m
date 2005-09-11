%------------------------------------------------------------------------------%
% COLORSCALE

if ~exist( 'hlegend', 'var' )
  inti = 0;
  haxes(end+1) = axes;
  set( gcf, 'CurrentAxes', haxes(end) )
  axis( [ 0 1 0 1 ] );
  hold on
  hlegend(3) = surf( [ 0 1 ], [ 0 .08 ], [ 0 0; 0 0 ], ...
    'FaceColor', background, ...
    'EdgeColor', 'none', ...
    'FaceLighting', 'none', ...
    'EdgeLighting', 'none' );
  hlegend(4) = plot( [ 0 1 ], [ .08 .08 ], 'Color', 0.5 * [ 1 1 1 ] );
  hlegend(1) = text( .1, .05, '0' );
  hlegend(2) = text( .9, .05, '1' );
  hlegend(5) = imagesc( [ .1 .9 ], [ .058 .06 ], 0:.001:1 );
  set( hlegend, 'HitTest', 'off', 'HandleVisibility', 'off' )
  set( gcf, 'CurrentAxes', haxes(1) )
end

ascl = alim; if ascl < 0, ascl = double( amax ); end;
vscl = vlim; if vscl < 0, vscl = double( vmax ); end;
uscl = ulim; if uscl < 0, uscl = double( umax ); end;
wscl = wlim; if wscl < 0, wscl = double( wmax ); end;
xscl = xlim; if xscl < 0, xscl = double( umax ); end;
usscl = uslim; if usscl < 0, usscl = double( usmax ); end;
vsscl = vslim; if vsscl < 0, vsscl = double( vsmax ); end;
tnscl = tnlim; if tnscl < 0, tnscl = double( tnmax ); end;
tsscl = tslim; if tsscl < 0, tsscl = double( tsmax ); end;
if xscl, xscl = .5 * dx / xscl; end
cellfocus = 0;
breakon = 'v';
switch field
case 'a', fscl = ascl; titles = { '|A|' 'Ax' 'Ay' 'Az' };
case 'v', fscl = vscl; titles = { '|V|' 'Vx' 'Vy' 'Vz' };
case 'u', fscl = uscl; titles = { '|U|' 'Ux' 'Uy' 'Uz' }; breakon = 'w';
case 'w', fscl = wscl; titles = { '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
  breakon = 'w'; cellfocus = 1;
case 'us', fscl = usscl; titles = { 'Uslip' };
case 'vs', fscl = vsscl; titles = { 'Vslip' };
case 'tn', fscl = tnscl; titles = { 'Tn' };
case 'ts', fscl = tsscl; titles = { 'Ts' };
otherwise error field
end
ncomp = length( titles ) - 1;
if comp > ncomp, comp = mod( comp, ncomp ); end
fscl = double( fscl );
clim = fscl;
if ~clim, clim = 1; end
set( gca, 'CLim', clim * [ -1 1 ] );
poscolor = [ 1 .5 0 ];
negcolor = [ 0 .5 1 ];
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
    cmap = [
      0 0 1 1 1
      0 1 1 1 0
      1 1 1 0 0 ]';
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
      4 1 1 4 4 1
      4 1 4 4 1 0
      4 4 4 1 1 0 ]' / 4;
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

