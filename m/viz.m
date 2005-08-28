%------------------------------------------------------------------------------%
% VIZ

% range selector
% initial plot: mesh, prestress, hypo
% restart capable

if plotstyle, else
  init = 0;
  gui = 0;
  return
end

if init == 1
  init = 0;
  if ~ishandle(1), figure(1), end
  set( 0, 'CurrentFigure', 1 )
  clf
  drawnow
  return
elseif init
  init = 0;
  fprintf( 'Initialize visualization\n' )
  plotinterval = 1;
  holdmovie = 1;
  savemovie = 0;
  field = 'v';
  comp = 0;
  isofrac = .5;
  glyphcut = .1;
  glyphexp = 1;
  glyphtype = 1;
  dark = 1;
  colorexp = .5;
  ulim = -1;
  vlim = -1;
  wlim = -1;
  xlim = 0;
  usliplim = -1;
  vsliplim = -1;
  tnlim = -1;
  tslim = -1;
  camdist = -1;
  look = 4;
  xhair = hypocenter;
  if nrmdim, slicedim = nrmdim; else slicedim = crdsys(2); end
  if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
  else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
  end
  hhud = [];
  hmsg = [];
  hhelp = [];
  frame = {};
  itpause = nt;
  showframe = 0;
  count = 0;
  keymod = '';
  keypress = 'h';
  helpon = 0;
  set( 1, ...
    'Color', background, ...
    'KeyPressFcn', 'control', ...
    'DefaultAxesColorOrder', foreground, ...
    'DefaultAxesColor', background, ...
    'DefaultAxesXColor', foreground, ...
    'DefaultAxesYColor', foreground, ...
    'DefaultAxesZColor', foreground, ...
    'DefaultLineColor', foreground, ...
    'DefaultLineLinewidth', linewidth, ...
    'DefaultTextColor', foreground, ...
    'DefaultTextFontSize', 12, ...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextHitTest', 'off', ...
    'DefaultLineClipping', 'off', ...
    'DefaultTextVerticalAlignment', 'top', ...
    'DefaultTextHorizontalAlignment', 'center', ...
    'DefaultAxesPosition', [ 0 0 1 1 ], ...
    'DefaultAxesVisible', 'off' )
  haxes = axes( 'Position', [ .02 .1 .96 .88 ], 'Tag', 'mainaxes' );
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'z' )
end

switch plotstyle
case 'hold'
otherwise
  dofault = 0;
  doglyph = 0;
  domesh = 0;
  dosurf = 0;
  doisosurf = 0;
  dooutline = 1;
  volviz = 1;
  switch plotstyle
  case 'outline'
  case 'fault',      dofault = 1;
  case 'slice',      dosurf = 1; volviz = 0;
  case 'cube',       dosurf = 1;
  case 'glyphs',     doglyph = 1;
  case 'isosurface', doisosurf = 1;
  otherwise error plotstyle
  end
  plotstyle = 'hold';
end

if mod( it, plotinterval ), return, end

set( 0, 'CurrentFigure', 1 )
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = {};
end
delete( [ hhud hmsg hhelp ] )
hhud = []; hmsg = []; hhelp = [];
colorscale
set( gcf, 'CurrentAxes', haxes(2) )
text( .50, .05, titles( comp + 1 ) );
switch field
case 'v', time = ( it - .5 ) * dt;
otherwise time = it * dt;
end
text( .98, .98, sprintf( '%.3fs', time ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )

volumes = [ 1 1 1   -1 -1 -1 ];
if nrmdim
  volumes = [ volumes; volumes ];
  i = nrmdim + [ 0 3 ];
  volumes(1,i) = [ 1  0 ];
  volumes(2,i) = [ 0 -1 ];
end
slices = [ 1 1 1   -1 -1 -1 ];
i = slicedim;
slices(i)   = xhair(i) - offset(i);
slices(i+3) = xhair(i) - offset(i) + cellfocus;
if nrmdim & slicedim ~= nrmdim
  slices = [ slices; slices ];
  i = nrmdim + [ 0 3 ];
  slices(1,i) = [ 1  0 ];
  slices(2,i) = [ 0 -1 ];
end

if nrmdim,           faultviz,   end
if doglyph,          glyphviz,   end
if doisosurf,        isosurfviz, end
if domesh || dosurf, surfviz,    end
if dooutline,        outlineviz, end
if look,             lookat,     end

clear xg mg vg xga mga vga
drawnow

kids = get( haxes, 'Children' );
kids = [ kids{1}; kids{2} ]';
frame{end+1} = kids;
showframe = length( frame );
if savemovie && ~holdmovie
  count = count + 1;
  file = sprintf( 'out/viz/%05d', count );
  saveas( gcf, file )
end

init = 0;

