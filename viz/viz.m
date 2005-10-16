% Viz

clear all
addpath m out
meta

vizfield = 'v';
comp = 0;
icursor = ihypo;
flim = -1;
xlim = 0;
isofrac = .5;
glyphcut = .1;
glyphexp = 1;
glyphtype = 1;
colorexp = .5;
holdmovie = 0;
savemovie = 0;
dark = 1;
camdist = -1;
look = 4;
doglyph = 0;
domesh = 0;
dosurf = 0;
doisosurf = 0;
dooutline = 1;
volviz = 0;

ifn = abs( faultnormal );
if ifn, islice = ifn;
else [ tmp islice ] = max( abs( upvector ) );
end

if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
end

if ~ishandle(1), figure(1), end
set( 0, 'CurrentFigure', 1 )
clf
set( 1, ...
  'Color', background, ...
  'KeyPressFcn', 'control', ...
  'WindowButtonDownFcn', 'itstep = 0;', ...
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
itpause = nt;
showframe = 0;
count = 0;
keymod = '';
helpon = 0;

keypress = 'f1';
render
control

