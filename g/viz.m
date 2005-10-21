% Viz

cd '/space/gely/sord'
%dbstop if error

clear all
addpath g
cd 'out'
defaults
in
meta
cd '..'

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
savemovie = 0;
dooutline = 1;
domesh = 0;
dosurf = 1;
doisosurf = 0;
doglyph = 0;
volviz = 0;
isofrac = .5;
lim = -1;
i1viz = [ 1 1 1 0 ];
i2viz = [ nn nt ];
icursor = [ ihypo 0 ];
ifn = abs( faultnormal );
cellfocus = 0;
i1s = [ 1 1 1 1 ];
i2s = [ 0 0 0 0 ];

if ifn, islice = ifn;
else    [ tmp islice ] = max( abs( upvector ) );
end

if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
end

if ~ishandle(1), figure(1), end
set( 0, 'CurrentFigure', 1 )
clf reset
set( 1, ...
  'KeyPressFcn', 'control', ...
  'Name', 'SORD Data Explorer', ...
  'NumberTitle', 'off', ...
  'Menubar', 'none', ...
  'Toolbar', 'none', ...
  'Renderer', 'OpenGL', ...
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
  'DefaultTextVerticalAlignment', 'top', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultAxesPosition', [ 0 0 1 1 ], ...
  'DefaultAxesVisible', 'off' )
haxes = axes( 'Position', [ .02 .1 .96 .88 ], 'Tag', 'mainaxes' );

drawnow

if 1
  [ tmp, l ] = max( abs( upvector ) );
  tmp = 'xyz';
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', tmp(l) )
  set( 1, 'KeyPressFcn', 'control' )
end

hhud = [];
hmsg = [];
hhelp = [];
frame = {};
count = 0;
showframe = 0;
houtline = [];

if dooutline
  houtline = outlineviz( nn, ifn, ihypo, rmax );
  set( houtline, 'HandleVisibility', 'off' )
end

camdist = 3 * rmax;
panviz = 0;
lookat( 0, upvector, xcenter, camdist )

fscl = 0;
colorscale

keymod = '';
keypress = 'message';
message = 'Press F1 for help';
control

