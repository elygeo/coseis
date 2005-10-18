% Viz

clear all
addpath m out
meta

field = 'v';
i1viz =  [ 1 1 1 1 ];
i2viz = -[ 1 1 1 1 ];
ic = 0;
icursor = ihypo;
lim = -1;
isofrac = .5;
glyphcut = .1;
glyphexp = 1;
glyphtype = 'wire';
glyphtype = 'colorwire';
colorexp = .5;
holdmovie = 0;
savemovie = 0;
dark = 1;
doglyph = 0;
domesh = 0;
dosurf = 0;
doisosurf = 0;
dooutline = 0;
volviz = 0;

ifn = abs( faultnormal );
if ifn, islice = ifn;
else [ tmp islice ] = max( abs( upvector ) );
end
n = [ nn nt ];
i = i1viz == 0; i1viz(i) = ihypo(i);
i = i2viz == 0; i2viz(i) = ihypo(i);
i = i1viz < 0; i1viz(i) = i1viz(i) + n(i) + 1;
i = i2viz < 0; i2viz(i) = i2viz(i) + n(i) + 1;

if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
end

if ~ishandle(1), figure(1), end
set( 0, 'CurrentFigure', 1 )
clf
set( 1, ...
  'Color', background, ...
  'DefaultAxesColorOrder', foreground, ...
  'DefaultAxesColor', background, ...
  'DefaultAxesXColor', foreground, ...
  'DefaultAxesYColor', foreground, ...
  'DefaultAxesZColor', foreground, ...
  'DefaultLineColor', foreground, ...
  'DefaultLineLinewidth', linewidth, ...
  'DefaultTextColor', foreground, ...
  'DefaultTextFontSize', 13, ...
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
set( 1, ...
  'KeyPressFcn', 'control', ...
  'WindowButtonDownFcn', 'itstep = 0; cameratoolbar(''down'')' )

hhud = [];
hmsg = [];
hhelp = [];
frame = {};
showframe = 0;
count = 0;

%lineviz
render
lookat( 0, upvector, xcenter, rmax, -1 )
panviz = 0;

keymod = '';
helpon = 0;
keypress = 'f1';
control

