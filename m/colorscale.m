% Color Scale

if flim, clim = flim;
else     clim = 1;
end
set( gca, 'CLim', [ -1 1 ] * clim );

if ~foldcs
  cmap = [
    0 0 0 1 1
    1 0 0 0 1
    1 1 0 0 0 ]';
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
  set( haxes(3), 'Clim', [ 0 1 ] )
  set( htxt(1), 'String', sprintf( '%g', -clim ) )
  set( htxt(2), 'String', sprintf( '%g',  clim ) )
else
  cmap = [
    0 0 0 1 4 4 4
    0 0 4 4 4 0 0
    0 4 4 1 0 0 4 ]' / 4;
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
  set( haxes(3), 'Clim', [ -1 1 ] )
  set( htxt(1), 'String', '0' )
  set( htxt(2), 'String', sprintf( '%g', clim ) )
end

colormap( interp1( x1, cmap, x2 ) );

