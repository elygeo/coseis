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

igpp
i = find( isnan( logo(:,1) ) );
logo(i,:) = [];

hfig = gcf;
clf reset

set( hfig, ...
  'Renderer', renderer, ...
  'KeyPressFcn', 'control', ...
  'Resizefcn', 'resizefcn', ...
  'Name', 'SDX', ...
  'NumberTitle', 'off', ...
  'InvertHardcopy', 'off', ...
  'DefaultLineLinewidth', 1, ...
  'DefaultLineClipping', 'off', ...
  'DefaultTextFontSize', 12, ...
  'DefaultTextFontWeight', 'bold' )

haxes(1) = axes;
haxes(2) = axes;
haxes(3) = axes;
haxes(4) = axes;
resizefcn

hleg(4) = fill( logo(:,1), logo(:,2), 'w', 'EdgeColor', 'none' );
axis image

set( hfig, 'CurrentAxes', haxes(3) )
axis( [ 0 1 0 1 ] );
hold on
hleg(1) = surf( [ 0 1 ], [ 0 1 ], [ 0 0; 0 0 ], ...
  'EdgeColor', 'none', ...
  'FaceLighting', 'none', ...
  'EdgeLighting', 'none' );
hleg(2) = plot( [ 0 1 ], [ 1 1 ], 'Color', .25 * [ 1 1 1 ] );
hleg(3) = imagesc( [ .2 .8 ], [ .7 .72 ], 0:.001:1 );
htxt(1) = text( .20, .5, '', 'Ver', 'top', 'Hor', 'center' );
htxt(2) = text( .80, .5, '', 'Ver', 'top', 'Hor', 'center' );
htxt(3) = text( .50, .5, '', 'Ver', 'top', 'Hor', 'center' );
htxt(5) = text( .90, .5, 'SORD', 'Ver', 'top', 'Hor', 'center' );

set( hfig, 'CurrentAxes', haxes(2) )
axis( [ 0 1 0 1 ] );
hold on
htxt(4) = text(  1,  1, '', 'Ver', 'top',    'Hor', 'right'  );
hmsg(1) = text(  0,  0, '', 'Ver', 'bottom', 'Hor', 'left'   );
hmsg(2) = text(  1,  0, '', 'Ver', 'bottom', 'Hor', 'right'  );
hmsg(3) = text(  0,  1, '', 'Ver', 'top',    'Hor', 'left', 'Interpreter', 'none' );
hmsg(4) = text(  1,  1, '', 'Ver', 'top',    'Hor', 'right'  );
hmsg(5) = text( .5, .5, '', 'Ver', 'middle', 'Hor', 'center', ...
  'FontWeight', 'normal', ...
  'Margin', 10, ...
  'EdgeColor', 0.25 * [ 1 1 1 ] );
set( hmsg, 'Interpreter', 'none', 'FontName', 'Courier' )
set( [ hleg htxt hmsg ], 'HitTest', 'off', 'HandleVisibility', 'off' )
set( hmsg(1), 'String', 'Press F1 for help' )

set( hfig, 'CurrentAxes', haxes(1) )

if dooutline
  houtline = outline( i1viz, i2viz, ifn, ihypo, rmax );
  set( houtline, 'HandleVisibility', 'off' )
end

set( haxes, 'Visible', 'off' );
set( haxes(2:4), 'HitTest', 'off' );
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

