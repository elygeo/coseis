% Data cursor

% Movement
way = sign( cursormove );
cursormove = abs( cursormove );
switch cursormove
case 0
case 5
  icursor = ihypo;
  if ifn, islice = ifn; end
case 6
  icursor = ihypo;
  icursor(idown) = 1;
  islice = idown;
case 7
  imax = ihypo;
  switch vizfield
  case 'a', imax = iamax;
  case 'v', imax = ivmax;
  case 'u', imax = iumax;
  case 'w', imax = iwmax;
  otherwise error 'vizfield'
  end
  [ j, k, l ] = ind2sub( nm, imax );
  icursor = [ j k l ];
otherwise
  v1 = camup;
  v3 = camtarget - campos;
  v2 = cross( v3, v1 );
  [ t, i1 ] = max( abs( v1 ) );
  [ t, i2 ] = max( abs( v2 ) );
  i3 = 1:3;
  i3( [ i1 i2 ] ) = [];
  i = [ i1 i2 i3 ];
  tmp = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) ];
  way = way * tmp(cursormove);
  cursormove = i(cursormove);
  i = abs( cursormove );
  if length( hhud ), icursor(i) = icursor(i) + way; end
  icursor = max( icursor, 1 );
  icursor = min( icursor, nn - cellfocus );
end
delete( [ hhud hhelp ] )
hhelp = [];

if showframe ~= nframe
  showframe = nframe;
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

if all( icursor == ithold ) || all( icursor >= i1hold & icursor <= i2hold )
else
  msg = num2str( icursor );
  return
end

j = icursor(1);
k = icursor(2);
l = icursor(3);
if strcmp( grid, 'contant' )
  xg = ( icursor - 1 ) * dx;
elseif ~cellfocus
  xg = x(j,k,l,:);
else
  xg = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
end
if xscl <= 0.
  ug = 0.;
elseif ~cellfocus
  ug = u(j,k,l,:);
else
  ug = 0.125 * ( ...
    u(j,k,l,:) + u(j+1,k+1,l+1,:) + ...
    u(j+1,k,l,:) + u(j,k+1,l+1,:) + ...
    u(j,k+1,l,:) + u(j+1,k,l+1,:) + ...
    u(j,k,l+1,:) + u(j+1,k+1,l,:) );
end
vg = v(j,k,l,:);
nc = size( vg, 4 );

switch nc
case 1
  msg = sprintf( 'Vs %9.2e', vg );
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
  mg = val';
  vg = vec(:)';
  tmp = [ mg([3 2 1])' vg ];
  msg = sprintf( 'W1  %9.2e\nW2  %9.2e\nW3  %9.2e\nWxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWxy %9.2e', tmp );
end

set( gcf, 'CurrentAxes', haxes(2) )
hhud = text( .02, .98, msg, 'Hor', 'left', 'Ver', 'top' );
tmp = [ it icursor; t xg ];
msg = sprintf( '%4d %8.3fs\n%4d %8.1fm\n%4d %8.1fm\n%4d %8.1fm', tmp );
hhud(2) = text( .98, .98, msg, 'Hor', 'right', 'Ver', 'top' );
msg = 'Explore';
set( gcf, 'CurrentAxes', haxes(1) )

if length( mga( mga ~= 0 ) )
  reynoldsglyph
  hhud = [ hhud hglyph ];
end

xcursor = double( xg(:) + xscl * ug(:) )';
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
if dooutline && ~volviz && dosurf
  i1 = i1node;
  i2 = i2node;
  i1(islice) = icursor(islice);
  i2(islice) = icursor(islice) + cellfocus;
  i  = [ i1; i1+1; i2; i2-1 ];
  if cellfocus
    i1 = [ 1 1 2 2; 1 1 2 2; 1 1 2 2; 1 1 2 2;
           1 1 2 2; 1 1 2 2; 1 1 2 2; 1 1 2 2 ];
    i2 = [ 1 1 1 1; 1 1 1 1; 3 3 3 3; 3 3 3 3;
           2 1 1 2; 4 3 3 4; 2 1 1 2; 4 3 3 4 ];
    i3 = [ 2 1 1 2; 4 3 3 4; 2 1 1 2; 4 3 3 4;
           1 1 1 1; 1 1 1 1; 3 3 3 3; 3 3 3 3 ];
  else
    i1 = [ 1 1 1; 1 1 1; 1 1 1; 1 1 1 ];
    i2 = [ 1 1 2; 1 1 2; 3 3 4; 3 3 4 ];
    i3 = [ 2 1 1; 4 3 3; 2 1 1; 4 3 3 ];
  end
  switch islice
  case 1, j = i(i1); k = i(i2+4); l = i(i3+8);
  case 2, j = i(i3); k = i(i1+4); l = i(i2+8);
  case 3, j = i(i2); k = i(i3+4); l = i(i1+8);
  otherwise error 'islice'
  end
  ii = sub2ind( nm(1:3), j, k, l )';
  ng = prod( nm(1:3) );
  clear xg
  for i = 0:2
    xg(:,:,i+1) = x(ii+i*ng) + xscl * u(ii+i*ng);
  end
  xg(end+1,:,:) = NaN;
  ng = size( xg );
  xg = reshape( xg, [ prod( ng(1:2) ) 3 ] );
  hhud(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Tag', 'outline' );
end

