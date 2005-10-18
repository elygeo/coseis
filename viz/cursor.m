% Data cursor

way = sign( cursormove );
cursormove = abs( cursormove );
switch cursormove
case 0
case 5, icursor = [ ihypo it ];
case 6, icursor = [ imax it ];
otherwise
  v1 = camup;
  v3 = camtarget - campos;
  v2 = cross( v3, v1 );
  [ t, i1 ] = max( abs( v1 ) );
  [ t, i2 ] = max( abs( v2 ) );
  i3 = 1:3;
  i3( [ i1 i2 ] ) = [];
  i = [ i1 i2 i3 4 ];
  tmp = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) 1 ];
  way = way * tmp(cursormove);
  cursormove = i(cursormove);
  i = abs( cursormove );
  if length( hhud ), icursor(i) = icursor(i) + way; end
  icursor = max( icursor, 1 );
  icursor = min( icursor, [ nn - cellfocus nt ] );
end

if ~docursor | any( icursor < i1viz | icursor > i2viz )
  msg = num2str( icursor );
  return
end

delete( [ hhud hhelp ] )
hhelp = [];

if showframe ~= nframe
  showframe = nframe;
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

j = icursor(1);
k = icursor(2);
l = icursor(3);
if strcmp( grid, 'contant' )
  xga = ( icursor(1:3) - 1 ) * dx;
elseif ~cellfocus
  xga = x(j,k,l,:);
else
  xga = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
end
vga = f(j,k,l,2:end);
nc = size( vga, 4 );

switch nc
case 1
  msg = sprintf( 'Vs %9.2e', vga );
case 3
  mg = sum( sqrt( vg .* vg ) );
  msg = sprintf( '|V| %9.2e\nVx  %9.2e\nVy  %9.2e\nVz  %9.2e', [ mg vg ] );
case 6
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  [ vec, val ] = eig( vg(c) );
  val = diag( val );
  [ tmp, i ] = sort( abs( val ) );
  val = val(i);
  vec = vec(:,i);
  mga = val';
  vga = vec(:)';
  tmp = [ mg([3 2 1])' vg ];
  msg = sprintf( 'W1  %9.2e\nW2  %9.2e\nW3  %9.2e\nWxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWxy %9.2e', tmp );
end

set( gcf, 'CurrentAxes', haxes(2) )
hhud = text( .02, .98, msg, 'Hor', 'left', 'Ver', 'top' );
tmp = [ icursor([4 1:3]); t xga ];
msg = sprintf( '%4d %8.3fs\n%4d %8.1fm\n%4d %8.1fm\n%4d %8.1fm', tmp );
hhud(2) = text( .98, .98, msg, 'Hor', 'right', 'Ver', 'top' );
msg = 'Explore';
set( gcf, 'CurrentAxes', haxes(1) )

if length( mga( mga ~= 0 ) )
  reynoldsglyph
  hhud = [ hhud hglyph ];
end

xcursor = double( xga(:) )';
xg = xcursor + dx * [ 
  -1 1 NaN  0 0 NaN  0 0
   0 0 NaN -1 1 NaN  0 0
   0 0 NaN  0 0 NaN -1 1 ]';
hhud(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3) );

xg = double( xg([2 5 8],:) );
hhud(end+1:end+3) = text( xg(:,1), xg(:,2), xg(:,3), ['xyz']', 'Ver', 'middle');
if panviz
  campos( campos + xcursor - camtarget )
  camtarget( xcursor )
end

