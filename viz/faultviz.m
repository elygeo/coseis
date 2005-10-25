% Fault vizualization

if ~ifn, return, end

i1 = i1viz;
i2 = i2viz;
i1(ifn) = ihypo(ifn);
i2(ifn) = ihypo(ifn);

if rcrit
  i1(4) = 0;
  i2(4) = 0;
  [ x, msg ] = read4d( 'x', i1, i2, 0 );
  if msg, error( msg ), end
  r = sqrt( sum( x .* x, 5 ) );
  h = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, it * dt * vrup ) );
  if nramp
    h = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, ( it - nramp ) * dt * vrup ) );
  end
end

scontour( xg, us(j,k,l), dc0 );
scontour( xg, us(j,k,l), .01 * dc0 );
scontour( xg, co(j,k,l), 1e8 );

