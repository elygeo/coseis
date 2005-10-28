% SDX: SORD Data Explorer

clear all
cd '/space/gely/sord/out'

defaults
in
meta

field = 'v';
icomp = 0;
dark = 1;
dit = 1;
colorexp = .5;
glyphcut = .1;
glyphexp = 1;
glyphtype = 'wire';
glyphtype = 'colorwire';
holdmovie = 1;
dooutline = 1;
domesh = 0;
dosurf = 1;
doisosurf = 0;
doglyph = 0;
dofault = 1;
volviz = 0;
isofrac = .5;
lim = -1;
i1viz = [ 1 1 1 0 ];
i2viz = [ nn nt ];
renderer = 'OpenGL';
renderer = 'zbuffer';

icursor = [ ihypo 0 ];
ifn = abs( faultnormal );
cellfocus = 0;
sensor = 0;
fmax = 0;
i1hold = [ 1 1 1 1 ];
i2hold = [ 0 0 0 0 ];

if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
end

if ~ishandle(1), figure(1), end
set( 0, 'CurrentFigure', 1 )
clf reset
set( 1, ...
  'Renderer', renderer, ...
  'KeyPressFcn', 'control', ...
  'Name', 'SDX', ...
  'NumberTitle', 'off', ...
  'Color', background, ...
  'DefaultAxesColorOrder', foreground, ...
  'DefaultAxesColor', background, ...
  'DefaultAxesXColor', foreground, ...
  'DefaultAxesYColor', foreground, ...
  'DefaultAxesZColor', foreground, ...
  'DefaultLineClipping', 'off', ...
  'DefaultLineColor', foreground, ...
  'DefaultLineLinewidth', linewidth, ...
  'DefaultTextFontSize', 13, ...
  'DefaultTextFontName', 'FixedWidth', ...
  'DefaultTextColor', foreground, ...
  'DefaultTextHitTest', 'off', ...
  'DefaultTextVerticalAlignment', 'top', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultAxesPosition', [ 0 0 1 1 ], ...
  'DefaultAxesVisible', 'off' )
haxes = axes( 'Position', [ .02 .1 .96 .88 ] );

houtline = [];
hhud = [];
frame = {};
count = 0;
showframe = 0;

if ifn
  islice = ifn;
  field = 'sv';
  i1fault = i1viz;
  i2fault = i2viz;
  i1fault(ifn) = ihypo(ifn);
  i2fault(ifn) = ihypo(ifn);
else
  dofault = 0;
  [ tmp, l ] = max( abs( upvector ) );
  j = 1;
  if l == 1, j = 2; end
  islice = 6 - l - j;
end

if dooutline
  houtline = outline( i1viz, i2viz, ifn, ihypo, rmax, grid, dx );
  set( houtline, 'HandleVisibility', 'off' )
end

camdist = 3 * rmax;
panviz = 0;
lookat( 0, upvector, xcenter, camdist )
[ tmp, l ] = max( abs( upvector ) );
tmp = 'xyz';
cameratoolbar( 'SetMode', 'orbit' )
cameratoolbar( 'SetCoordSys', tmp(l) )
cameratoolbar( 'ToggleSceneLight' )
set( 1, 'KeyPressFcn', 'control' )

haxes(2) = axes( 'HitTest', 'off' );
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
hmsg = text( .02, .1,  'Press F1 for help', 'Hor', 'left', 'Ver', 'bottom' );
hmsg(2) = text( .98, .1,  '', 'Ver', 'bottom', 'Hor', 'right' );
hmsg(3) = text( .02, .98, '', 'Ver', 'top',    'Hor', 'left'  );
hmsg(4) = text( .98, .98, '', 'Ver', 'top',    'Hor', 'right' );
hmsg(5) = text( .5, .54,  '', ...
  'Vertical', 'middle', ...
  'Margin', 10, ...
  'EdgeColor', 0.5 * [ 1 1 1 ], ...
  'BackgroundColor', background );
set( [ hlegend hmsg ], 'HitTest', 'off', 'HandleVisibility', 'off' )
set( gcf, 'CurrentAxes', haxes(1) )

