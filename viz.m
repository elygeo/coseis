%------------------------------------------------------------------------------%
% VIZ
% TODO
% time series
% range selector
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
    'DefaultTextVerticalAlignment', 'top', ...
    'DefaultTextHorizontalAlignment', 'center', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextHitTest', 'off' )
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'x' )
  set( 0, 'CurrentFigure', 1 )
  clf
  haxes = axes( 'Position', [ 0 .08 1 .92 ] );
  set( gcf, 'CurrentAxes', haxes(1) )
  drawnow
  if ~exist( 'out/viz', 'dir' ), mkdir out/viz, end
  hhud = [];
  hmsg = [];
  hhelp = [];
  look = 4;
  viz3d = 0;
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
  isofrac = .5;
  glyph = 1;
  glyphtype = 1;
  gexp = 1;
  gcut = .3;
  zoomed = 0;
  camdist = -1;
  ulim = -1;
  vlim = -1;
  wlim = -1;
  xlim = 0;
  cexp = .5;
  plotinterval = 1;
  colorscale
  haxes(2) = hand;
  set( gcf, 'CurrentAxes', haxes(1) )
  return
elseif initialize
  newplot = 'initial';
end

savemovie = 1;
holdmovie = 1;
play = 0;
uscl = ulim; if uscl < 0, uscl = umax; end;
vscl = vlim; if vscl < 0, vscl = vmax; end;
wscl = wlim; if wscl < 0, wscl = wmax; end;
xscl = xlim; if xscl < 0, xscl = umax; end;
if xscl, xscl = .5 * h / xscl; end
if newplot, else
  if ~mod( it, plotinterval )
    newplot = plotstyle;
  else
    return
  end
end
glyphtype = 1;
if dosurf || isosurf, glyphtype = -1; end
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
  glyphs = planes;
otherwise
  error( [ 'unknown plotstyle ' newplot ] )
end

% One time stuff
clear xg vg
set( 0, 'CurrentFigure', 1 )
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

colorscale
if domesh || dosurf,  surfviz,    end
if isosurf,           isosurfviz, end
if glyph,             glyphviz,   end
if length( lines ),   lineviz,    end

% Fault plane contours
if nrmdim
  j = 2:n(1) - 1;
  k = 2:n(2) - 1;
  l = hypocenter(3) + 1;
  xg = squeeze( x(j,k,l,:) + xscl * u(j,k,l,:) ); 
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
set( gcf, 'CurrentAxes', haxes(2) )
text( .50, .05, titles( comp + 1 ) );
text( .98, .98, sprintf( '%.3fs', it * dt ), 'Hor', 'right' )
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

