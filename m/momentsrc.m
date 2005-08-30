%----------------------------------------------------------------------------%
% MOMENTSRC

if ~msrcradius; return; end

if init
  init = 0;
  fprintf( 'Initialize moment source\n' )
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
  msrcv = s1( msrci );
  msrcx = s2( msrci );
  msrcx = msrcx / sum( msrcx ) ./ msrcv;
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  [ vec, val ] = eig( moment(c) );
  m0 = max( abs( val(:) ) );
  mw = 2. / 3. * log10( m0 ) - 10.7;
  um = m0 / miu0 / dx / dx;
  fprintf( 'M0: %g\nMw: %g\nD:  %g\n', m0, mw, um )
  return
end

% time indexing goes wi vi wi+1 vi+1 ...
if 0 % increment stress
  time = ( it + .5 ) * dt;
  switch srctimefcn
  case 'delta',  msrcf = 0.; if it == 1, msrcf = 1. / dt; end
  case 'brune',  msrcf = exp( -time / domp ) / domp ^ 2. * time;
  case 'sbrune', msrcf = exp( -time / domp ) / domp ^ 3. * time * time / 2.;
  otherwise error srctimefcn
  end
  msrcf = dt * msrcf
else % direct stress
  time = it * dt;
  switch srctimefcn
  case 'delta',  msrcf = 1.; if it == 1, msrcf = 1.; end
  case 'brune',  msrcf = 1. - exp( -time / domp ) / domp * ( time + domp );
  case 'sbrune', msrcf = 1. - exp( -time / domp ) / domp * ...
    ( time + domp + time * time / domp / 2. );
  otherwise error srctimefcn
  end
end
o = prod( nm );
for i = 0:2
  w1(msrci+o*i) = w1(msrci+o*i) - msrcf * msrcx * moment(i+1);
  w2(msrci+o*i) = w2(msrci+o*i) - msrcf * msrcx * moment(i+4);
end

