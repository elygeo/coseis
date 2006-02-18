% Data cursor

docursor = 1;
if any( dicursor ) && length( hmsg(2) )
  v2 = camup;
  v3 = camtarget - campos;
  v1 = cross( v3, v2 );
  [ tmp, i1 ] = max( abs( v1 ) );
  [ tmp, i2 ] = max( abs( v2 ) );
  i3 = 6 - i1 - i2;
  i = 1:4;
  i([ i1 i2 i3 ]) = 1:3;
  way = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) 1 ];
  icursor = icursor + way(i) .* dicursor(i);
  rehash
  currentstep
  icursor = max( icursor, i1viz );
  icursor = min( icursor, [ i2viz(1:3) - cellfocus it ] );
end

delete( hhud )
hhud = [];
set( hmsg(2), 'String', sprintf( '%4d\n%4d\n%4d\n%4d', icursor ) )
set( hmsg(3:5), 'String', '' )
msg = 'Explore';

if ~docursor || ...
  any( icursor < i1hold | icursor > i2hold )
  %( any( icursor < i1hold | icursor > i2hold ) && any( icursor(1:3) ~= sensor ) )
  xcursor = xcenter;
  return
end

j = icursor(1) - i1hold(1) + 1;
k = icursor(2) - i1hold(2) + 1;
l = icursor(3) - i1hold(3) + 1;

if strcmp( grid, 'contant' )
  xx = ( icursor(1:3) - 1 ) * dx;
elseif ~cellfocus
  xx = x(j,k,l,:);
else
  xx = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
end

xx = shiftdim( xx )';
xcursor = xx;

x1 = xx(1) + dx * [ -1 1 NaN  0 0 NaN  0 0 ];
x2 = xx(2) + dx * [  0 0 NaN -1 1 NaN  0 0 ];
x3 = xx(3) + dx * [  0 0 NaN  0 0 NaN -1 1 ];
hhud(1) = plot3( x1, x2, x3 );

x1 = xx(1) + [ dx 0 0 ];
x2 = xx(2) + [ 0 dx 0 ];
x3 = xx(3) + [ 0 0 dx ];
hhud(2:4) = text( x1, x2, x3, ['xyz']', 'Ver', 'middle', 'Color', foreground );

if panviz
  campos( campos + xx - camtarget )
  camtarget( xx )
end

switch nc
case 1
  str = sprintf( 'Vs %11.4e', s(j,k,l) );
case 3
  vv = shiftdim( v(j,k,l,:) )';
  m = sum( sqrt( vv .* vv ) );
  str = sprintf( '|V| %11.4e\nVx  %11.4e\nVy  %11.4e\nVz  %11.4e', m, vv );
case 6
  vv = shiftdim( v(j,k,l,:) )';
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  m = eig( vv(c) );
  [ tmp, i ] = sort( abs( m ), 'descend' );
  m = m(i);
  str = sprintf( 'W1  %11.4e\nW2  %11.4e\nW3  %11.4e\nWxx %11.4e\nWyy %11.4e\nWzz %11.4e\nWyz %11.4e\nWzx %11.4e\nWxy %11.4e', m, vv );
end

if nc > 1
  hhud = [ hhud reynoldsglyph( xx, vv, flim, glyphexp, dx ) ];
end

set( hmsg(3), 'String', str )
set( hmsg(4), 'String', sprintf( 's\n%8.1fm\n%8.1fm\n%8.1fm', xx ) );

