% Render

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
text( .98, .98, sprintf( '%.3fs', time ), 'Hor', 'right' )
set( gcf, 'CurrentAxes', haxes(1) )

i1volume =  [ 1 1 1 ];
i2volume = -[ 1 1 1 ];
if ifn
  i1volume = [ i1volume; i1volume ];
  i2volume = [ i2volume; i2volume ];
  i1volume(2,ifn) = 0;
  i2volume(1,ifn) = 0;
end
i1slice =  [ 1 1 1 ];
i2slice = -[ 1 1 1 ];
i = islice;
i1slices(i) = icursor(i) - nnoff(i);
i2slices(i) = icursor(i) - nnoff(i) + cellfocus;
if ifn && islice ~= ifn
  i1slice = [ i1slice; i1slice ];
  i2slice = [ i2slice; i2slice ];
  i1slice(2,ifn) = 0;
  i2slice(1,ifn) = 0;
end

if ifn,              faultviz,   end
if doglyph,          glyphviz,   end
if doisosurf,        isosurfviz, end
if domesh || dosurf, surfviz,    end
if dooutline,        outlineviz, end
if look,             lookat,     end

clear xg mg vg xga mga vga
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

