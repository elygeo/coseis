%------------------------------------------------------------------------------%
% COLORSCALE

if initialize
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

uscl = ulim; if uscl < 0, uscl = double( umax ); end;
vscl = vlim; if vscl < 0, vscl = double( vmax ); end;
wscl = wlim; if wscl < 0, wscl = double( wmax ); end;
xscl = xlim; if xscl < 0, xscl = double( umax ); end;
uslipscl = usliplim; if uslipscl < 0, uslipscl = double( uslipmax ); end;
vslipscl = vsliplim; if vslipscl < 0, vslipscl = double( vslipmax ); end;
tnscl = tnlim; if tnscl < 0, tnscl = double( tnmax ); end;
tsscl = tslim; if tsscl < 0, tsscl = double( tsmax ); end;
if xscl, xscl = .5 * dx / xscl; end
cellfocus = 1;
switch field
case 'u', fscl = uscl; titles = { '|U|' 'Ux' 'Uy' 'Uz' }; cellfocus = 0;
case 'v', fscl = vscl; titles = { '|V|' 'Vx' 'Vy' 'Vz' }; cellfocus = 0;
case 'w', fscl = wscl; titles = { '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
case 'uslip', fscl = uslipscl; titles = { 'Uslip' }; cellfocus = 0;
case 'vslip', fscl = vslipscl; titles = { 'Vslip' }; cellfocus = 0;
case 'tn', fscl = tnscl; titles = { 'Tn' }; cellfocus = 0;
case 'ts', fscl = tsscl; titles = { 'Ts' }; cellfocus = 0;
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

