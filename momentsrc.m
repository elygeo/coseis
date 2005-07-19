%------------------------------------------------------------------------------%
% MOMENTSRC

if initialize
  if msrcradius && exist( 'msrcnodealign' ) && exist( 'srctimefcn' ) ...
  && sum( abs( moment ) )
  else
    msrcradius = 0;
    return
  end
  s1(:) = 0;
  w1(:) = 0;
  i1 = halo + [ 1 1 1 ];
  i2 = halo + np;
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  s1(j,k,l) = dfnc( 'g', x, x, dx, 1, 1, j, k, l );
  i = s1 ~= 0;
  s1(i) = 1 ./ s1(i);
  w1(j,k,l,:) = 0.125 * ...
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) ...
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) ...
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) ...
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  l1 = hypocenter(3);
  k1 = hypocenter(2);
  j1 = hypocenter(1);
  for i = 1:3
    if msrcnodealign
      w1(:,:,:,i) = w1(:,:,:,i) - x(j1,k1,l1,i);
    else
      w1(:,:,:,i) = w1(:,:,:,i) - w1(j1,k1,l1,i);
    end
  end
  s2(:) = 2 * msrcradius ^ 2;
  s2(j,k,l) = sum( w1(j,k,l,:) .* w1(j,k,l,:), 4 );
  msrci = find( s2 < msrcradius ^ 2 );
  msrcx = msrcradius - sqrt( s2( msrci ) );
  msrcx = msrcx / sum( msrcx );
  msrcx = msrcx .* s1( msrci );
  s1(:) = 0;
  s2(:) = 0;
  w1(:) = 0;
  msrct = [];
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  [ vec, val ] = eig( moment(c) );
  m0 = max( abs( val(:) ) );
  mw = 2 / 3 * log10( m0 ) - 10.7;
  um = m0 / miu0 / dx / dx;
  fprintf( 'Momnent Source\nM0: %g\nMw: %g\nD:  %g\n', m0, mw, um )
  return
end

domp = 8 * dt;
time = ( .5 : it - .5 ) * dt;  % time indexing goes wi vi wi+1 vi+1 ...
switch srctimefcn
case 'delta',  msrcdf = zeros( size( time ) ); msrct(1) = 1 / dt;
case 'brune',  msrcdf = time .* exp( -time / domp ) / domp ^ 2;
case 'sbrune', msrcdf = time .^ 2 .* exp( -time / domp ) / 2 / domp ^ 3;
otherwise error srctimefcn
end
msrcf = dt * cumsum( msrcdf );
o = prod( m );
for i = 0:2
  w1(msrci+o*i) = w1(msrci+o*i) - msrcf(it) * msrcx * moment(i+1);
  w2(msrci+o*i) = w2(msrci+o*i) - msrcf(it) * msrcx * moment(i+4);
end

