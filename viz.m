%------------------------------------------------------------------------------%
% VIZ
% TODO
% W "box slice"
% V glyph
% zoom into spot
% cell selector
% colorscale
% initial plot: mesh, prestress, hypo
% backward time
% restart capable

if initialize > 1
  disp( 'Initialize visualization' )
  dark = 1;
  if dark, fg = [ 1 1 1 ]; bg = [ 0 0 0 ]; linewidth = 1;
  else     fg = [ 0 0 0 ]; bg = [ 1 1 1 ]; linewidth = 2;
  end
  if ~ishandle(1), figure(1), end
  set( 0, 'CurrentFigure', 1 )
  clf
  set( 1, ...
    'Color', bg, ...
    'KeyPressFcn', 'control', ...
    'DefaultAxesPosition', [ 0 0 1 1 ], ...
    'DefaultAxesVisible', 'off', ...
    'DefaultAxesColorOrder', fg, ...
    'DefaultAxesColor', bg, ...
    'DefaultAxesXColor', fg, ...
    'DefaultAxesYColor', fg, ...
    'DefaultAxesZColor', fg, ...
    'DefaultLineColor', fg, ...
    'DefaultLineClipping', 'off', ...
    'DefaultLineLinewidth', linewidth, ...
    'DefaultTextColor', fg, ...
    'DefaultTextBackgroundColor', bg, ...
    'DefaultTextVerticalAlignment', 'bottom', ...
    'DefaultTextHorizontalAlignment', 'center', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextHitTest', 'off' )
  haxes(1) = axes;
  haxes(2) = axes; axis( [ 0 1 0 1 ] );
  set( 1, 'CurrentAxes', haxes(1) )
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'x' )
  cameratoolbar( 'ToggleSceneLight' );
  drawnow
  if ~exist( 'out/viz', 'dir' ), mkdir out/viz, end
  hhud = [];
  hmsg = [];
  hhelp = [];
  look = 4;
  % Saved data
  if nrmdim, slicedim = nrmdim; else slicedim = 3; end
  xhair = hypocenter - halo1;
  stereoangle = 4; % > 0 wall-eyed, < 0 cross-eyed
  stereoangle = 0; % > 0 wall-eyed, < 0 cross-eyed
  right = [];
  ftcam = [];
  plotstyle = 'slice';
  slicedim  = 3;
  itpause = nt;
  count = 0;
  frame = {};
  showframe = 0;
  loopmovie = 0;
  helpon = 0;
  comp = 0;
  field = 'v';
  domesh = 0;
  dosurf = 0;
  isosurf = 0;
  glyph = 0;
  glyphtype = 1;
  xglyphtype = 0;
  zoomed = 0;
  return
elseif initialize
  newplot = 'initial';
end

set( 0, 'CurrentFigure', 1 )
plotinterval = 1;
savemovie = 1;
holdmovie = 1;
ulim = -1;
vlim = -1;
wlim = -1;
xlim = -1;

if newplot
else
  if ~mod( it, plotinterval )
    newplot = plotstyle;
  else
    return
  end
end

play   = 0;
vcut   = .3;
wcut   = .3;
vexp   = 1;
wexp   = .5;
isoval = [ .1 .5 ];
cmap   = [];
if dosurf || isosurf, glyphtype = -abs( glyphtype ); end

i = xhair;
c = hypocenter;
lines = [ 1 1 1   -1 -1 -1 ];
if nrmdim
  lines = [ lines; lines ];
  i = nrmdim + [ 0 3 ];
  lines(1,i) = [ 1  0 ];
  lines(2,i) = [ 0 -1 ];
end
planes = [];
glyphs = lines;
volumes = lines;

switch newplot
case 'initial'
case 'outline'
case 'cube', planes = lines;
case 'slice'
  vcut = .001;
  planes = [ 1 1 1  -1 -1 -1 ];
  i = slicedim + [ 0 3 ];
  planes(i) = xhair(slicedim);
  if nrmdim & slicedim ~= nrmdim
    planes = [ planes; planes ];
    i = nrmdim + [ 0 3 ];
    lines(1,i) = [ 1  0 ];
    lines(2,i) = [ 0 -1 ];
  else
  end
  lines = [ lines; planes ];
  glyphs = planes;
otherwise
  error( [ 'unknown plotstyle ' newplot ] )
end

% One time stuff
clear xg vg
delete( [ hhud hmsg hhelp ] )
hhud = [];
hmsg = [];
hhelp = [];
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = { [] };
end
uscl = ulim;
vscl = vlim;
wscl = wlim;
xscl = xlim;
if ulim < 0, uscl = umax; end
if vlim < 0, vscl = vmax; end
if wlim < 0, wscl = wmax; end
if xlim < 0, xscl = xmax; end
isoval = vscl * isoval;
vcut   = vscl * vcut;
wcut   = wscl * wcut;
if uscl, uscl = h / 2 / uscl; end
if vscl, vscl = 1 / vscl; end
if wscl, wscl = 1 / wscl; end
clim = 1;
switch field
case 'v', if vscl, clim = 1 / vscl; end
case 'w', if wscl, clim = 1 / wscl; end
end
if comp
  if dark
    cmap = [
    -8 -4 -2  0  2  4  8
     0  0  0  0  8  8  8
     8  4  0  0  0  4  8
     8  8  8  0  0  0  0 ]' / 8;
  else
    cmap = [
    -8 -6 -4 -2  0  2  4  6  8
     0  2  2  2  8  8  8  8  4
     4  8  8  2  8  2  6  8  2
     0  2  8  8  8  2  2  2  0 ]' / 8;
  end
  hh = 0.001;
  colormap( interp1( cmap(:,1), cmap(:,2:4), -1:hh:1 ) );
else
  if dark
    cmap = [
     0 .5  2  4  6  8
     0  0  0  8  8  8
     0  0  8  8  0  0
     0  8  8  0  0  8]' / 8;
  else
    cmap = [
     0 .5  2  4  6  8
     8  2  2  8  8  4
     8  2  8  8  2  0
     8  8  8  2  2  0]' / 8;
  end
  hh = 0.001;
  colormap( interp1( cmap(:,1), cmap(:,2:4), [ -1:-hh:hh 0:hh:1 ] ) );
end

if domesh || dosurf,  surfviz,    end
if isosurf,           isosurfviz, end
if glyph,             glyphviz,   end
if length( lines ),   lineviz,    end

% Fault plane contours
if nrmdim
  j = 2:n(1) - 1;
  k = 2:n(2) - 1;
  l = hypocenter(3) + 1;
  xg = squeeze( x(j,k,l,:) + uscl * u(j,k,l,:) ); 
  if rcrit
    hh = scontour( xg, r(j,k), min( rcrit, it * dt * vrup ) );
    set( hh, 'LineStyle', ':' );
    if nclramp
      hh = scontour( xg, r(j,k), min( rcrit, ( it - nclramp ) * dt * vrup ) );
      set( hh, 'LineStyle', ':' );
    end
  end
  scontour( xg, uslip(j,k), dc0 );
  scontour( xg, uslip(j,k), .01 * dc0 );
  switch model
  case { 'the2', 'the3' }
    scontour( xg, fd(j,k), 10 );
  end
end

clear xg mg vg xga mga vga

if look, lookat, end
set( gca, 'CLim', [ -clim clim ] );

% Title
set( gcf, 'CurrentAxes', haxes(2) )
text( .98, .98, sprintf( '%.3fs', it * dt ), 'Hor', 'right', 'Ver', 'top' )
hold on
switch field
case 'v', titles = { '|V|' 'Vx' 'Vy' 'Vz' };
case 'w', titles = { '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
end
text( .02, .02, sprintf( '%g', -clim(1) ), 'Hor', 'left' )
text( .22, .02, sprintf( '%g',  clim(1) ), 'Hor', 'right' )
text( .12, .02, titles( comp + 1 ) )
imagesc( [ .02 .22 ], [ .06 .063 ], 0:1000 )
set( gcf, 'CurrentAxes', haxes(1) )

% Save frame
kids = get( haxes, 'Children' );
kids = [ kids{1}; kids{2} ]';
frame{end+1} = kids;
showframe = length( frame );
newplot = '';

% Hardcopy
if savemovie && ~holdmovie
  count = count + 1;
  file = sprintf( 'out/viz/%05d', count );
  saveas( gcf, file )
end

drawnow

