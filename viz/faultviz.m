% Fault vizualization

if ~ifn, return, end

i1 = i1viz;
i2 = i2viz;
i1(ifn) = ihypo(ifn);
i2(ifn) = ihypo(ifn);
i1(4) = 0;
i2(4) = 0;
[ x, msg ] = read4d( 'x', i1, i2, 0 );
if msg, error( msg ), end

if rcrit
  r = sqrt( sum( x .* x, 5 ) );
  scontour( x, r, min( rcrit, it * dt * vrup ) );
  if nramp
    scontour( x, r, min( rcrit, ( it - nramp ) * dt * vrup ) );
  end
end

i1(4) = it;
i2(4) = it;
[ sl, msg ] = read4d( 'sl', i1, i2, 0 );
if msg, error( msg ), end

scontour( x, sl, dc0 );
scontour( x, sl, .01 * dc0 );

