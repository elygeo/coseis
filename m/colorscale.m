% Color Scale

if flim, clim = flim;
else     clim = 1;
end
set( gca, 'CLim', [ -1 1 ] * clim );
poscolor = [ 1 .5 0 ];
negcolor = [ 0 .5 1 ];
if colorscheme
  set( hfig, 'InvertHardcopy', 'on' )
  set( hleg(4:5), 'Visible', 'off' )
else
  set( hfig, 'InvertHardcopy', 'off' )
  set( hleg(4:5), 'Visible', 'on' )
end

if ~foldcs
  switch colorscheme
  case 0
    cmap = [
      0 0 0 1 1
      1 0 0 0 1
      1 1 0 0 0 ]';
  case 1
    cmap = [
      1 0 4 4 4
      1 4 4 4 1
      4 4 4 0 1 ]' / 4;
  case 2
    cmap = [
      0 1 0
      0 1 0
      0 1 0 ]';
  end
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(3), 'Clim', [ 0 1 ] )
  set( htxt(1), 'String', sprintf( '%g', -clim ) )
  set( htxt(2), 'String', sprintf( '%g',  clim ) )
else
  switch colorscheme
  case 0
    cmap = [
      0 0 0 0 1 1 1
      0 0 1 1 1 0 0
      0 1 1 0 0 0 1 ]';
  case 1
    cmap = [
      4 2 0 1 4 4 4
      4 2 4 4 4 1 0
      4 4 4 1 0 1 4 ]' / 4;
  case 2
    cmap = [
      1 0
      1 0
      1 0 ]';
  end
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
  colormap( interp1( x1, cmap, x2 ) );
  set( haxes(3), 'Clim', [ -1 1 ] )
  set( htxt(1), 'String', '0' )
  set( htxt(2), 'String', sprintf( '%g', clim ) )
end

