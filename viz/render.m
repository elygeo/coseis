% Render

i1 = i1viz;
i2 = i2viz;
i1(4) = it;
i2(4) = it;
if ~volviz
  i = slicedim;
  i1(i) = icursor(i);
  i2(i) = icursor(i) + cellfocus;
end

[ x, msg ] = read4d( 'x', i1, i2, 0 );
[ v, msg ] = read4d( field, i1, i2, 0 );
if msg, error( msg ), end
nc = size( f, 2 );
if nc > 1
  [ s, msg ] = read4d( [ field 'm' ], i1, i2, 0 );
  if msg, error( msg ), end
end

fscl = flim;
if fscl < 0
  fscl = double( fmax );
end
if ic > nc
  ic = mod( ic, nc );
end

set( 0, 'CurrentFigure', 1 )
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = {};
end
delete( [ hhud hmsg hhelp ] )
hhud = []; hmsg = []; hhelp = [];
colorscale
set( gcf, 'CurrentAxes', haxes(2) )
text( .50, .05, titles( comp + 1 ) );
text( .98, .98, sprintf( '%.3fs', t ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )

if doglyph,          glyphviz,   end
if doisosurf,        isosurfviz, end
if domesh || dosurf, surfviz,    end
%if ifn,              faultviz,   end

drawnow

kids = get( haxes, 'Children' );
kids = [ kids{1}; kids{2} ]';
frame{end+1} = kids;
showframe = length( frame );
if savemovie && ~holdmovie
  count = count + 1;
  file = sprintf( 'out/viz/%06d', count );
  saveas( gcf, file )
end

