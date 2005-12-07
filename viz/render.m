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
i1s(4) = icursor(4);
i2s(4) = icursor(4);

% Read field data
[ f, msg ] = read4d( field, i1s, i2s );
if msg, return, end
[ x, msg ] = read4d( 'x', [ i1s(1:3) 1 ], [ i2s(1:3) 1 ] );
if msg, error 'no mesh data not found', end
i1hold = i1s;
i2hold = i2s;

% Rearrange
x = permute( x, [ 1 2 3 5 4 ] );
f = permute( f, [ 1 2 3 5 4 ] );
nc = size( f, 4 );
if icomp > nc
  icomp = mod( icomp - 1, nc ) + 1;
end

% Magnitude
switch nc
case 1, s = f; icomp = 0;
case 3, v = f; s = sqrt( sum( v .* v, 4 ) );
case 6, v = f; s = sqrt( sum( v .* v, 4 ) + 2. * sum( v .* v, 4 ) );
end
clear f

% Read metadata
cd 'stats'
file = sprintf( 'st%06d', icursor(4) );
eval( file )
cd '..'
fieldinfo
flim = lim;
if flim < 0, flim = fmax; end

% Setup figure
set( 0, 'CurrentFigure', hfig );
kids = get( haxes, 'Children' );
delete( [ kids{1}; kids{2}; hhud' ] );
hhud = [];
colorscale
set( hmsg,    'String', '' )
set( htxt(3), 'String', labels( icomp + 2 ) )
set( htxt(4), 'String', sprintf( '%.3fs', t ) )

% Isosurfaces
if doisosurf
  if icomp, isosurfviz( x, v, icomp, cellfocus, flim * isofrac, volviz );
  else      isosurfviz( x, s, 1,     cellfocus, flim * isofrac, volviz );
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
  faultviz
end

