% Render

% Slice
i1s = i1viz;
i2s = i2viz;
if ~volviz
  i = islice;
  i1s(i) = icursor(i);
  i2s(i) = icursor(i);
  if strcmp( field(1), 'w' )
    i2s(i) = i2s(i) + 1;
  end
end

% Read node locations
i1s(4) = 0;
i2s(4) = 0;
[ x, msg ] = read4d( 'x', i1s, i2s, 0 );
if msg, return, end

% Read field data
i1s(4) = icursor(4);
i2s(4) = icursor(4);
[ s, msg ] = read4d( field, i1s, i2s, 0 );
if msg, return, end

% Rearrange
x = permute( x, [ 1 2 3 5 4 ] );
s = permute( s, [ 1 2 3 5 4 ] );
nc = size( s, 4 );
if icomp > nc
  icomp = mod( icomp - 1, nc ) + 1;
end

% Magnitude
switch nc
case 1, icomp = 0;
case 3, v = s; s = sqrt( sum( v .* v, 4 ) );
case 6, v = s; s = sqrt( sum( v .* v, 4 ) + 2. * sum( v .* v, 4 ) );
end

% Read metadata
cwd = pwd;
cd 'out'
cd 'stats'
file = sprintf( 'it%06d', icursor(4) );
eval( file )
cd( cwd )
fieldinfo
fscl = lim;
if fscl < 0
  fscl = fmax;
end

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

% Isosurfaces
if doisosurf
  if icomp, isosurfviz( x, v, icomp, cellfocus, fscl * isofrac );
  else      isosurfviz( x, s, 1,     cellfocus, fscl * isofrac );
  end
end

% Cutting planes
if domesh || dosurf
  if icomp, surfviz( x, v, icomp, cellfocus, domesh, dosurf );
  else      surfviz( x, s, 1,     cellfocus, domesh, dosurf );
  end
  if ~volviz, lineviz( x ); end
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
text( .50, .05, labels( icomp + 2 ) );
text( .98, .98, sprintf( '%.3fs', t ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )

drawnow

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

