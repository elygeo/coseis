% Color Scale

if flim, clim = flim;
else     clim = 1;
end
set( gca, 'CLim', [ -1 1 ] * clim );

if ~foldcs
  setcolormap( 'signed', 'dark', colorexp )
  set( haxes(3), 'Clim', [ 0 1 ] )
  set( htxt(1), 'String', sprintf( '%g', -clim ) )
  set( htxt(2), 'String', sprintf( '%g',  clim ) )
else
  setcolormap( 'folded', 'dark', colorexp )
  set( haxes(3), 'Clim', [ -1 1 ] )
  set( htxt(1), 'String', '0' )
  set( htxt(2), 'String', sprintf( '%g', clim ) )
end

