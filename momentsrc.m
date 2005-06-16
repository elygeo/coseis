%------------------------------------------------------------------------------%
% MOMENTSRC

if initialize
  if msrcradius && exist( 'msrcnodealign' ) && exist( 'srctimefcn' ) ...
  && sum( abs( moment ) )
  else
    msrcradius = 0;
    return
  end
  w1(:) = 0;
  w1(j,k,l,:) = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  l = hypocenter(3);
  k = hypocenter(2);
  j = hypocenter(1);
  for i = 1:3
    if msrcnodealign
      w1(:,:,:,i) = w1(:,:,:,i) - x(j,k,l,i);
    else
      w1(:,:,:,i) = w1(:,:,:,i) - w1(j,k,l,i);
    end
  end
  s1 = sum( w1 .* w1, 4 );
  msrci = find( s1 < msrcradius ^ 2 );
  msrcx = msrcradius - sqrt( s1( msrci ) );
  msrcx = msrcx / sum( msrcx );
  w1(:) = 0;
  s1(:) = 0;
  i1 = halo1 + 1;
  i2 = halo1 + ncore;
  l = i1(3):i1(3)-1;
  k = i1(2):i1(2)-1;
  j = i1(1):i1(1)-1;
  s1(j,k,l) = dng( x, 1, x, 1, j, k, l );
  i = s1 ~= 0; s1(i) = 1 ./ s1(i);
  msrcx = msrcx .* s1( msrci );
  s1(:) = 0;
  msrct = [];
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  [ vec, val ] = eig( moment(c) );
  m0 = max( abs( val(:) ) );
  mw = 2 / 3 * log10( m0 ) - 10.7;
  um = m0 / miu0 / h / h;
  fprintf( 'Momnent Source\nM0: %g\nMw: %g\nD:  %g\n', m0, mw, um )
  return
end

domp = 8 * dt;
time = ( .5 : it-.5 ) * dt;  % time indexing goes wi vi wi+1 vi+1 ...
switch srctimefcn
case 'delta',  msrct = zeros( size( time ) ); msrct(1) = 1;
case 'sine',   msrct = dt * sin( 2 * pi * time / domp ) * pi / domp;
case 'brune',  msrct = dt * time .* exp( -time / domp ) / domp ^ 2;
case 'sbrune', msrct = dt * time .^ 2 .* exp( -time / domp ) / 2 / domp ^ 3;
otherwise error srctimefcn
end
o = prod( n );
for i = 0:2
  w1(msrci+o*i) = w1(msrci+o*i) + msrct(it) * msrcx * moment(i+1);
  w2(msrci+o*i) = w2(msrci+o*i) + msrct(it) * msrcx * moment(i+4);
end

