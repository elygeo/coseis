%------------------------------------------------------------------------------%
% VIZ
% TODO
% time series
% range selector
% initial plot: mesh, prestress, hypo
% backward time
% restart capable

if initialize > 1

  plotstyle = 'slice';
  plotinterval = 1;
  holdmovie = 1;
  savemovie = 1;
  field = 'v';
  comp = 0;
  domesh = 0;
  dosurf = 0;
  doisosurf = 0;
  dooutline = 1;
  isofrac = .5;
  doglyph = 1;
  glyphcut = .1;
  glyphexp = 1;
  glyphtype = 1;
  dark = 1;
  colorexp = .5;
  ulim = -1;
  vlim = -1;
  wlim = -1;
  xlim = 0;
  camdist = -1;
  look = 4;

  fprintf( 'Initialize visualization\n' )
  xhair = hypocenter - halo1;
  if nrmdim, slicedim = nrmdim; else slicedim = 3; end
  if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
  else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
  end
  hhud = [];
  hmsg = [];
  hhelp = [];
  frame = {};
  showframe = 0;
  itpause = nt;
  count = 0;
  helpon = 0;
  keypress = 'h';
  keymod = '';
  if ~ishandle(1), figure(1), end
  set( 0, 'CurrentFigure', 1 )
  clf
  set( 1, ...
    'Color', background, ...
    'KeyPressFcn', 'ckey = get( gcf, ''CurrentKey'' ); cmod = get( gcf, ''CurrentMod'' ); control', ...
    'DefaultAxesPosition', [ 0 0 1 1 ], ...
    'DefaultAxesVisible', 'off', ...
    'DefaultAxesColorOrder', foreground, ...
    'DefaultAxesColor', background, ...
    'DefaultAxesXColor', foreground, ...
    'DefaultAxesYColor', foreground, ...
    'DefaultAxesZColor', foreground, ...
    'DefaultLineColor', foreground, ...
    'DefaultLineClipping', 'off', ...
    'DefaultLineLinewidth', linewidth, ...
    'DefaultTextColor', foreground, ...
    'DefaultTextVerticalAlignment', 'top', ...
    'DefaultTextHorizontalAlignment', 'center', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextHitTest', 'off' )
  haxes = axes( 'Position', [ .02 .1 .96 .88 ] );
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'z' )
  drawnow
  colorscale
  if ~exist( 'out/viz', 'dir' ), mkdir out/viz, end
  return
elseif initialize
  newplot = 'initial';
end

set( 0, 'CurrentFigure', 1 )
if newplot, else
  if ~mod( it, plotinterval ), newplot = plotstyle;
  else return
  end
end
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = { [] };
end
delete( [ hhud hmsg hhelp ] )
hhud = []; hmsg = []; hhelp = [];
colorscale
set( gcf, 'CurrentAxes', haxes(2) )
text( .50, .05, titles( comp + 1 ) );
text( .98, .98, sprintf( '%.3fs', it * dt ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )
volumes = [ 1 1 1   -1 -1 -1 ];
if nrmdim
  volumes = [ volumes; volumes ];
  i = nrmdim + [ 0 3 ];
  volumes(1,i) = [ 1  0 ];
  volumes(2,i) = [ 0 -1 ];
end
slices = [ 1 1 1   -1 -1 -1 ];
slices(slicedim)   = xhair(slicedim);
slices(slicedim+3) = xhair(slicedim) + cellfocus;
if nrmdim & slicedim ~= nrmdim
  slices = [ slices; slices ];
  i = nrmdim + [ 0 3 ];
  slices(1,i) = [ 1  0 ];
  slices(2,i) = [ 0 -1 ];
end

glyphs = volumes;
if nrmdim,    faultviz,   end
if doglyph,   glyphviz,   end
if doisosurf, isosurfviz, end
if domesh || dosurf
  switch newplot
  case 'cube'
    planes = volumes; surfviz
  case 'slice'
    planes = slices; surfviz
    lines  = slices; lineviz, set( hand, 'Tag', 'surfline' )
  end
end
if dooutline
  lines = volumes;
  lineviz
  houtline = hand;
  i = halo1 + 1;
  xg = double( squeeze( x(i(1),i(2),i(3),:) + xscl * u(i(1),i(2),i(3),:) ) );
  xg = [ xg xg + xmax / 16 xg + xmax / 15 ];
  j = [ 4 1 1 1 1 ];
  k = [ 2 2 5 2 2 ];
  l = [ 3 3 3 3 6 ];
  houtline(2) = plot3( xg(j), xg(k), xg(l) );
  j = [ 7 1 1 ];
  k = [ 2 8 2 ];
  l = [ 3 3 9 ];
  houtline(3:5) = text( xg(j), xg(k), xg(l), ['xyz']', 'Ver', 'middle' );
  set( houtline, 'Tag', 'outline' )
end
if look, lookat, end

clear xg mg vg xga mga vga

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

