% SDX: SORD Data Explorer

clear all
format compact

meta

[ tmp, islice ] = max( abs( upvector ) );
i1 = nn;
i2 = [ 1 1 1 ];
field = 'x';
for i = 1 : length( out )
  fields{i} = out{i}{2};
  if strcmp( out{i}{2}, 'x' )
    i1 = min( i1, [ out{i}{4:6} ] );
    i2 = max( i2, [ out{i}{7:9} ] );
  elseif strcmp( field, 'x' )
    field = out{i}{2};
    ii = find( [ out{i}{7:9} ] - [ out{i}{4:6} ] == 0 );
    if length( ii ), islice = ii(1); end
  end
end
fields = unique( fields );
i1viz = [ i1 0 ];
i2viz = [ i2 nt ];
icomp = 0;
colorscheme = 0;
dit = 1;
colorexp = .5;
glyphcut = .1;
glyphexp = 1;
glyphtype = 'wire';
glyphtype = 'colorwire';
glyphtype = 'reynolds';
holdmovie = 1;
dooutline = 1;
domesh = 0;
dosurf = 1;
doisosurf = 0;
doglyph = 0;
volviz = 0;
isofrac = .5;
lim = -1;
flim = 0;
renderer = 'OpenGL';
renderer = 'painters';
renderer = 'zbuffer';
export = 0;
ifn = abs( faultnormal );

icursor = [ ihypo 0 ];
cellfocus = 0;
sensor = 0;
count = 0;
fmax = 0;
foldcs = 0;
i1hold = [ 1 1 1 1 ];
i2hold = [ 0 0 0 0 ];
houtline = [];
hhud = [];

hfig = gcf;
clf reset

% 'DefaultTextFontUnits', 'normalized', ...
% 'DefaultTextFontName', 'FixedWidth', ...
set( hfig, ...
  'DefaultTextFontName', 'Courier', ...
  'Renderer', renderer, ...
  'KeyPressFcn', 'control', ...
  'Name', 'SDX', ...
  'NumberTitle', 'off', ...
  'InvertHardcopy', 'off', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextFontSize', 13, ...
  'DefaultTextFontWeight', 'bold' )

haxes(1) = axes( 'Position', [ .02 .1 .96 .88 ] );
haxes(2) = axes( 'Position', [ 0 0 1 1 ], 'HitTest', 'off' );
axis( [ 0 1 0 1 ] );
hold on
hleg(1) = surf( [ 0 1 ], [ 0 .08 ], [ 0 0; 0 0 ], ...
  'EdgeColor', 'none', ...
  'FaceLighting', 'none', ...
  'EdgeLighting', 'none' );
hleg(2) = plot( [ 0 1 ], [ .08 .08 ], 'Color', .25 * [ 1 1 1 ] );
hleg(3) = imagesc( [ .1 .9 ], [ .058 .06 ], 0:.001:1 );
igpp
hleg(4) = plot( .5 + .04 * logo(:,1), .1 + .04 * logo(:,2), 'w' );
htxt(1) = text( .10, .05, '', 'Ver', 'top',    'Hor', 'center' );
htxt(2) = text( .90, .05, '', 'Ver', 'top',    'Hor', 'center' );
htxt(3) = text( .50, .05, '', 'Ver', 'top',    'Hor', 'center' );
htxt(4) = text( .98, .98, '', 'Ver', 'top',    'Hor', 'right'  );
hmsg(1) = text( .02, .10, '', 'Ver', 'bottom', 'Hor', 'left'   );
hmsg(2) = text( .98, .10, '', 'Ver', 'bottom', 'Hor', 'right'  );
hmsg(3) = text( .02, .98, '', 'Ver', 'top',    'Hor', 'left', 'Interpreter', 'none' );
hmsg(4) = text( .98, .98, '', 'Ver', 'top',    'Hor', 'right'  );
hmsg(5) = text( .50, .54, '', 'Ver', 'middle', 'Hor', 'center', ...
  'FontWeight', 'normal', ...
  'Margin', 10, ...
  'EdgeColor', 0.25 * [ 1 1 1 ] );
set( hmsg, 'Interpreter', 'none' )
set( [ hleg htxt hmsg ], 'HitTest', 'off', 'HandleVisibility', 'off' )
set( hmsg(1), 'String', 'Press F1 for help' )

set( hfig, 'CurrentAxes', haxes(1) )

if dooutline
  houtline = outline( i1viz, i2viz, ifn, ihypo, rmax );
  set( houtline, 'HandleVisibility', 'off' )
end

set( haxes, 'Visible', 'off' );
colorscale

panviz = 0;
camdist = 3 * rmax;
lookat( 0, upvector, xcenter, camdist )
[ tmp, l ] = max( abs( upvector ) );
tmp = 'xyz';
cameratoolbar( 'SetMode', 'orbit' )
cameratoolbar( 'SetCoordSys', tmp(l) )
cameratoolbar( 'ToggleSceneLight' )
set( 1, 'KeyPressFcn', 'control', ...
  'WindowButtonDownFcn', 'anim = 0; cameratoolbar(''down'')' )

