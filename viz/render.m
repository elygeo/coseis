% Render

fscl = flim; if fscl < 0, fscl = double( fmax ); end;
xscl = xlim; if xscl < 0, xscl = double( umax ); end;
if xscl, xscl = .5 * dx / xscl; end
fscl = double( fscl );
if ic > nc, ic = mod( ic, nc ); end

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

i = i1viz == 0; i1viz(i) = i1viz(i) + nn(i) + 1;
i = i2viz == 0; i2viz(i) = i2viz(i) + nn(i) + 1;
i1volume = i1viz;
i2volume = i2viz;
if ifn
  i1volume = [ i1volume; i1volume ];
  i2volume = [ i2volume; i2volume ];
  i1volume(2,ifn) = ihypo(ifn);
  i2volume(1,ifn) = ihypo(ifn);
end
i1slice = i1viz;
i2slice = i2viz;
i = islice;
i1slice(i) = icursor(i) - nnoff(i);
i2slice(i) = icursor(i) - nnoff(i) + cellfocus;
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

