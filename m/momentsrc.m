%------------------------------------------------------------------------------%
% MOMENTSRC

if ~msrcradius; return; end

if init
  init = 0;
  if msrcradius && exist( 'srctimefcn' ) && sum( abs( moment ) )
  else
    msrcradius = 0.;
    return
  end
  i1 = i1cell;
  i2 = i2cell;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s1(:,:,:) = 0.;
  s1(j,k,l) = dfnc( 'g', x, x, dx, 1, 1, j, k, l );
  i = s1 ~= 0.;
  s1(i) = 1 ./ s1(i);
  w1(:) = 2 * msrcradius;
  w1(j,k,l,:) = 0.125 * ...
    ( x(j,k,l,:) + x(j+1,k+1,l+1,:) ...
    + x(j+1,k,l,:) + x(j,k+1,l+1,:) ...
    + x(j,k+1,l,:) + x(j+1,k,l+1,:) ...
    + x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  for i = 1:3
    w1(:,:,:,i) = w1(:,:,:,i) - xhypo(i);
  end
  s2 = msrcradius - sqrt( sum( w1 .* w1, 4 ) );
  msrci = find( s2 > 0. );
  msrcx = s2( msrci );
  msrcx = msrcx / sum( msrcx );
  msrcx = msrcx .* s1( msrci );
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
o = prod( nn + 2 * nhalo );
for i = 0:2
  w1(msrci+o*i) = w1(msrci+o*i) - msrcf(it) * msrcx * moment(i+1);
  w2(msrci+o*i) = w2(msrci+o*i) - msrcf(it) * msrcx * moment(i+4);
end

