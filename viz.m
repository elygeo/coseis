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
  dosurf = 1;
  doisosurf = 1;
  isofrac = .5;
  doglyph = 1;
  glyphcut = .1;
  glyphexp = 1;
  dark = 1;
  colorexp = .5;
  ulim = -1;
  vlim = -1;
  wlim = -1;
  xlim = 0;
  camdist = -1;
  look = 4;

  disp( 'Initialize visualization' )
  xhair = hypocenter - halo1;
  if nrmdim, slicedim = nrmdim; else slicedim = 3; end
  if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
  else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 2;
  end
  hhud = [];
  hmsg = [];
  hhelp = [];
  frame = {};
  showframe = 0;
  itpause = nt;
  count = 0;
  helpon = 0;
  if ~ishandle(1), figure(1), end
  set( 0, 'CurrentFigure', 1 )
  clf
  set( 1, ...
    'Color', background, ...
    'KeyPressFcn', 'control', ...
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
  haxes = axes( 'Position', [ 0 .08 1 .92 ] );
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'x' )
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

glyphtype = 1;
%if dosurf || isosurf, glyphtype = -1; end
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
  planes = [ 1 1 1  -1 -1 -1 ];
  planes(slicedim)   = xhair(slicedim);
  planes(slicedim+3) = xhair(slicedim) + cellfocus;
  if nrmdim & slicedim ~= nrmdim
    planes = [ planes; planes ];
    i = nrmdim + [ 0 3 ];
    planes(1,i) = [ 1  0 ];
    planes(2,i) = [ 0 -1 ];
  else
  end
  lines = [ lines; planes ];
otherwise
  error( [ 'unknown plotstyle ' newplot ] )
end

lineviz
if nrmdim,           faultviz,   end
if doglyph,          glyphviz,   end
if doisosurf,        isosurfviz, end
if domesh || dosurf, surfviz,    end
if look,             lookat,     end

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

