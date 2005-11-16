% Fault vizualization

if ~ifn, return, end

i1 = i1viz;
i2 = i2viz;
i1(ifn) = ihypo(ifn);
i2(ifn) = ihypo(ifn);
i1(4) = 0;
i2(4) = 0;
[ x, msg ] = read4d( 'x', i1, i2 );
if msg, error( msg ), end

if rcrit
  r = 0;
  for i = 1:3
    r = r + ( x(:,:,:,:,i) - xhypo(i) ) .* ( x(:,:,:,:,i) - xhypo(i) );
  end
  r = sqrt( r );
  surfcontour( x, r, min( rcrit, icursor(4) * dt * vrup ) );
  if trelax > 0.
    surfcontour( x, r, min( rcrit, ( icursor(4) * dt - trelax ) * vrup ) );
  end
end

i1(4) = icursor(4);
i2(4) = icursor(4);
[ sl, msg ] = read4d( 'sl', i1, i2 );
if msg, error( msg ), end

surfcontour( x, sl, dc0 );
surfcontour( x, sl, .01 * dc0 );

