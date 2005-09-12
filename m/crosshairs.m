%------------------------------------------------------------------------------%
% CROSSHAIRS

way = sign( xhairmove );
xhairmove = abs( xhairmove );
if xhairmove == 4
  xhair = hypocenter;
  if nrmdim, slicedim = nrmdim; end
elseif xhairmove == 5
  xhair = hypocenter;
  xhair(downdim) = 1;
  slicedim = downdim;
elseif xhairmove == 6
  imax = hypocenter;
  switch field
  case 'a', imax = iamax;
  case 'v', imax = ivmax;
  case 'u', imax = iumax;
  case 'w', imax = iwmax;
  otherwise error 'xhfield'
  end
  [ j, k, l ] = ind2sub( nm, imax );
  xhair = [ j k l ];
else
  v1 = camup;
  v3 = camtarget - campos;
  v2 = cross( v3, v1 );
  [ t, i1 ] = max( abs( v1 ) );
  [ t, i2 ] = max( abs( v2 ) );
  i3 = 1:3;
  i3( [ i1 i2 ] ) = [];
  i = [ i1 i2 i3 ];
  tmp = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) ];
  way = way * tmp(xhairmove);
  xhairmove = i(xhairmove);
  slicedim = abs( xhairmove );
  i = slicedim;
  if length( hhud ), xhair(i) = xhair(i) + way; end
  xhair = max( xhair, i1node );
  xhair = min( xhair, i2node - cellfocus );
end
delete( [ hhud hhelp ] )
hhelp = [];
j = xhair(1);
k = xhair(2);
l = xhair(3);
clear xg xga mga vga
if cellfocus
  for i = 1:3
    xg(i) = 0.125 * ( ...
      x(j,k,l,i) + x(j+1,k+1,l+1,i) + ...
      x(j+1,k,l,i) + x(j,k+1,l+1,i) + ...
      x(j,k+1,l,i) + x(j+1,k,l+1,i) + ...
      x(j,k,l+1,i) + x(j+1,k+1,l,i) );
    xga(i) = xg(i) + 0.125 * xscl * ( ...
      u(j,k,l,i) + u(j+1,k+1,l+1,i) + ...
      u(j+1,k,l,i) + u(j,k+1,l+1,i) + ...
      u(j,k+1,l,i) + u(j+1,k,l+1,i) + ...
      u(j,k,l+1,i) + u(j+1,k+1,l,i) );
  end
else
  xg(1:3) = x(j,k,l,:);
  xga(1:3) = x(j,k,l,:) + xscl * u(j,k,l,:);
end
xhairtarg = double( xga(:)' );
switch field
case 'a'
  time = it * dt;
  if pass == 'w', mga = []; msg = ''; else
    vga(1:3) = w1(j,k,l,:);
    mga = s1(j,k,l);
    tmp = [ mga vga mr(j,k,l) ];
    msg = sprintf( '|A| %9.2e\nAx  %9.2e\nAy  %9.2e\nAz  %9.2e\nmr  %9.2e', tmp );
  end
case 'v'
  time = ( it + .5 ) * dt;
  vga(1:3) = v(j,k,l,:);
  mga = sqrt( sum( v(j,k,l,:) .* v(j,k,l,:), 4 ) );
  tmp = [ mga vga mr(j,k,l) ];
  msg = sprintf( '|V| %9.2e\nVx  %9.2e\nVy  %9.2e\nVz  %9.2e\nmr  %9.2e', tmp );
case 'u'
  time = it * dt;
  vga(1:3) = u(j,k,l,:);
  mga = sqrt( sum( u(j,k,l,:) .* u(j,k,l,:), 4 ) );
  tmp = [ mga vga mr(j,k,l) ];
  msg = sprintf( '|U| %9.2e\nUx  %9.2e\nUy  %9.2e\nUz  %9.2e\nmr  %9.2e', tmp );
case 'w'
  time = it * dt;
  if pass == 'v', mga = []; msg = ''; else
    c = [ 1 6 5; 6 2 4; 5 4 3 ];
    clear wg
    wg(1:3) = w1(j,k,l,:);
    wg(4:6) = w2(j,k,l,:);
    [ vec, val ] = eig( wg(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    mga = val';
    vga = vec(:)';
    tmp = [ val([3 2 1])' wg lm(j,k,l) mu(j,k,l) ];
    msg = sprintf( 'W1  %9.2e\nW2  %9.2e\nW3  %9.2e\nWxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWxy %9.2e\nlm  %9.2e\nmu  %9.2e', tmp );
  end
otherwise error 'xhfield'
end
set( gcf, 'CurrentAxes', haxes(2) )
hhud = text( .02, .98, msg, 'Hor', 'left', 'Ver', 'top' );
tmp = [ it xhair-offset; time xg ];
msg = sprintf( '%4d %8.3fs\n%4d %8.1fm\n%4d %8.1fm\n%4d %8.1fm', tmp );
hhud(2) = text( .98, .98, msg, 'Hor', 'right', 'Ver', 'top' );
msg = 'Explore';
set( gcf, 'CurrentAxes', haxes(1) )
if length( mga( mga ~= 0 ) )
  reynoldsglyph
  hhud = [ hhud hglyph ];
end
i1 = xhair;
i = [ i1-1; i1; i1+1 ];
if cellfocus
  j = [ 1 1 1 1 1 2 2 2 2 2 2 1 1 2 2 1 ] + 1;
  k = [ 1 1 2 2 1 1 1 2 2 1 1 1 2 2 2 2 ] + 1;
  l = [ 1 2 2 1 1 1 2 2 1 1 2 2 2 2 1 1 ] + 1;
  iorig = 1;
  inan = [];
  itext = [ 6 4 2 ];
else
  j = [ 3 2 1 1 2 2 2 1 2 2 2 ];
  k = [ 2 2 2 1 3 2 1 1 2 2 2 ];
  l = [ 2 2 2 1 2 2 2 1 3 2 1 ];
  iorig = 2;
  inan = [ 4 8 ];
  itext = [ 1 5 9 ];
end
j = i(j);
k = i(k+3);
l = i(l+6);
ii = sub2ind( nm(1:3), j, k, l )';
ng = prod( nm(1:3) );
clear xg
for i = 0:2
  xg(:,i+1) = x(ii+i*ng) + xscl * u(ii+i*ng);
end
xg(inan,:) = NaN;
hhud(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3) );
xgo = xg(iorig,:);
xg  = xg(itext,:);
for i = 1:3;
  xg(:,i) = 1.1 * xg(:,i) - .1 * xgo(i);
end
xg = double( xg );
hhud(end+1:end+3) = text( xg(:,1), xg(:,2), xg(:,3), ['jkl']', 'Ver', 'middle');
if panviz
  campos( campos + xhairtarg - camtarget )
  camtarget( xhairtarg )
end
if dooutline && ~volviz && ( dosurf || domesh || doglyph  )
  i1 = i1node;
  i2 = i2node;
  i1(slicedim) = xhair(slicedim);
  i2(slicedim) = xhair(slicedim) + cellfocus;
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
  switch slicedim
  case 1, j = i(i1); k = i(i2+4); l = i(i3+8);
  case 2, j = i(i3); k = i(i1+4); l = i(i2+8);
  case 3, j = i(i2); k = i(i3+4); l = i(i1+8);
  otherwise error 'slicedim'
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

if showframe ~= nframe
  showframe = nframe;
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

