% Data cursor

docursor = 1;
way = sign( cursormove );
cursormove = abs( cursormove );
switch cursormove
case 0
case 5, icursor = [ ihypo it ];
case 6, icursor = [ fmaxi it ];
otherwise
  v1 = camup;
  v3 = camtarget - campos;
  v2 = cross( v3, v1 );
  [ tmp, i1 ] = max( abs( v1 ) );
  [ tmp, i2 ] = max( abs( v2 ) );
  i3 = 1:3;
  i3( [ i1 i2 ] ) = [];
  i = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) 1 ];
  way = way * i(cursormove);
  i = [ i1 i2 i3 4 ];
  cursormove = i(cursormove);
  i = abs( cursormove );
  if length( hhud ), icursor(i) = icursor(i) + way; end
  icursor = max( icursor, 1 );
  icursor = min( icursor, [ nn - cellfocus nt ] );
end

delete( [ hhud hhelp ] )
hhud = [];
hhelp = [];
msg = 'Explore';

if showframe ~= nframe
  showframe = nframe;
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

if ~docursor | any( icursor < i1s | icursor > i2s )
  set( gcf, 'CurrentAxes', haxes(2) )
  tmp = icursor([4 1 2 3]);
  str = sprintf( '%4d          \n', tmp );
  hhud = text( .98, .98, str, 'Hor', 'right', 'Ver', 'top' );
  set( gcf, 'CurrentAxes', haxes(1) )
  xcursor = xcenter;
  return
end

j = icursor(1) - i1s(1) + 1;
k = icursor(2) - i1s(2) + 1;
l = icursor(3) - i1s(3) + 1;
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
vv = v(j,k,l,:);
nc = size( vv, 4 );
vv = shiftdim( vv )';
xx = shiftdim( xx )';
xcursor = xx;

switch nc
case 1
  str = sprintf( 'Vs %9.2e', vv );
case 3
  m = sum( sqrt( vv .* vv ) );
  str = sprintf( '|V| %9.2e\nVx  %9.2e\nVy  %9.2e\nVz  %9.2e', m, vv );
case 6
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  m = eig( vv(c) );
  [ tmp, i ] = sort( abs( m ), 'descend' );
  m = m(i);
  str = sprintf( 'W1  %9.2e\nW2  %9.2e\nW3  %9.2e\nWxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWxy %9.2e', m, vv );
end

set( gcf, 'CurrentAxes', haxes(2) )
hhud = text( .02, .98, str, 'Hor', 'left', 'Ver', 'top' );
tmp = [ icursor xx ];
tmp = tmp([4 1 5 2 6 3 7]);
str = sprintf( '%4d          \n%4d %8.1fm\n%4d %8.1fm\n%4d %8.1fm', tmp );
hhud(2) = text( .98, .98, str, 'Hor', 'right', 'Ver', 'top' );
set( gcf, 'CurrentAxes', haxes(1) )

if nc > 1
  hglyph = reynoldsglyph( xx, vv, fscl, glyphexp, dx );
  hhud = [ hhud hglyph ];
end

x1 = xx(1) + dx * [ -1 1 NaN  0 0 NaN  0 0 ];
x2 = xx(2) + dx * [  0 0 NaN -1 1 NaN  0 0 ];
x3 = xx(3) + dx * [  0 0 NaN  0 0 NaN -1 1 ];
hhud(end+1) = plot3( x1, x2, x3 );

x1 = xx(1) + [ dx 0 0 ];
x2 = xx(2) + [ 0 dx 0 ];
x3 = xx(3) + [ 0 0 dx ];
hhud(end+1:end+3) = text( x1, x2, x3, ['xyz']', 'Ver', 'middle');

if panviz
  campos( campos + xx - camtarget )
  camtarget( xx )
end

