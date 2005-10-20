% Render

% Setup figure
set( 0, 'CurrentFigure', 1 )
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = {};
end
delete( [ hhud hmsg hhelp ] )
hhud = [];
hmsg = [];
hhelp = [];

% Read metadata
cwd = pwd;
cd 'out'
cd 'stats'
file = sprintf( 'it%06d', it );
eval( file )
cd( cwd )
fieldinfo
fscl = lim;
if fscl < 0
  fscl = double( fmax );
end

% Slice
i1s = i1viz;
i2s = i2viz;
if ~volviz
  i = islice;
  i1s(i) = icursor(i);
  i2s(i) = icursor(i) + cellfocus;
end

% Read node locations
i1s(4) = 0;
i2s(4) = 0;
[ x, msg ] = read4d( 'x', i1s, i2s, 0 );
if msg, error( msg ), end

% Read field data
i1s(4) = it;
i2s(4) = it;
[ v, msg ] = read4d( field, i1s, i2s, 0 );
if msg, error( msg ), end

% Rearrange
x = permute( x, [ 1 2 3 5 4 ] );
v = permute( v, [ 1 2 3 5 4 ] );
nc = size( v, 4 );
if icomp > nc
  icomp = mod( icomp - 1, nc ) + 1;
end

% Magnitude
switch nc
case 3, s = sqrt( sum( v .* v, 4 ) );
case 6, s = sqrt( sum( v .* v, 4 ) + 2. * sum( v .* v, 4 ) );
end

% Isosurfaces
if doisosurf
  if ic, isosurfviz( x, v, ic, cellfocus, fscl * isofrac );
  else   isosurfviz( x, s, 1,  cellfocus, fscl * isofrac );
  end
end

% Cutting planes
if domesh || dosurf
  if ic, surfviz( x, v, ic, cellfocus, domesh, dosurf );
  else   surfviz( x, s, 1,  cellfocus, domesh, dosurf );
  end
end

% Glyphs
if doglyph
  glyphviz
end

% Fault plane
if ifn
  %faultviz
end

% Color scale
colorscale
set( gcf, 'CurrentAxes', haxes(2) )
text( .50, .05, labels( ic + 2 ) );
text( .98, .98, sprintf( '%.3fs', t ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )

% Save frame
kids = get( haxes, 'Children' );
kids = [ kids{1}; kids{2} ]';
frame{end+1} = kids;
showframe = length( frame );
if savemovie && ~holdmovie
  count = count + 1;
  file = sprintf( 'out/viz/%06d', count );
  saveas( gcf, file )
end

