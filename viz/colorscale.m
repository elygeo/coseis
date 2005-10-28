% Color Scale

if flim, clim = flim;
else     clim = 1;
end

set( gca, 'CLim', [ -1 1 ] * clim );
poscolor = [ 1 .5 0 ];
negcolor = [ 0 .5 1 ];
if icomp
  if dark
    cmap = [
      0 0 0 1 1
      1 0 0 0 1
      1 1 0 0 0 ]';
  else
    cmap = [
      1 1 2 2 2
      2 1 2 1 2
      2 2 2 1 1 ]' / 2;
    cmap = [
      0 0 1 1 1
      0 1 1 1 0
      1 1 1 0 0 ]';
  end
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(2), 'Clim', [ 0 1 ] )
  set( hlegend(1), 'String', sprintf( '%g', -clim ) )
  set( hlegend(2), 'String', sprintf( '%g',  clim ) )
else
  if dark
    cmap = [
      0 0 0 1 1 1
      0 0 1 1 0 0
      0 1 1 0 0 1 ]';
  else
    cmap = [
      4 1 1 4 4 1
      4 1 4 4 1 0
      4 4 4 1 1 0 ]' / 4;
  end
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(2), 'Clim', [ -1 1 ] )
  set( hlegend(1), 'String', '0' )
  set( hlegend(2), 'String', sprintf( '%g', clim ) )
end

