% Viz

clear all

addpath ../g

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
  'Name', 'SORD DX', ...
  'NumberTitle', 'off', ...
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
haxes = axes( 'Position', [ .02 .1 .96 .88 ] );

hhud = [];
hmsg = [];
hhelp = [];
frame = {};
count = 0;
showframe = 0;
houtline = [];

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
  if l == 1, j == 2; end
  islice = 6 - l - j;
end

if dooutline
  houtline = outline( i1viz, i2viz, ifn, ihypo, rmax );
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

fscl = 0;
colorscale

keymod = '';
keypress = 'message';
message = 'Press F1 for help';
control

