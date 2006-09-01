% Fault vizualization

if ~ifn, return, end

i1 = i1viz;
i2 = i2viz;
i1(ifn) = ihypo(ifn);
i2(ifn) = ihypo(ifn);
i1(4) = 0;
i2(4) = 0;
[ msg, xx ] = read4d( 'x', i1, i2 );
if msg, return, end

if rcrit > 0. && vrup > .0
  r = 0;
  for i = 1:3
    r = r + ( xx(:,:,:,:,i) - xhypo(i) ) .* ( xx(:,:,:,:,i) - xhypo(i) );
  end
  r = sqrt( r );
  surfcontour( xx, r, min( rcrit, icursor(4) * dt * vrup ) );
  if trelax > 0.
    surfcontour( xx, r, min( rcrit, ( icursor(4) * dt - trelax ) * vrup ) );
  end
end

[ msg, dc ] = read4d( 'dc', i1, i2 );
if msg
  msg = '';
else
  h = surfcontour( xx, dc, 1 ); set( h, 'LineWidth', 2 )
  h = surfcontour( xx, dc, 2 ); set( h, 'LineWidth', 2 )
end

i1(4) = icursor(4);
i2(4) = icursor(4);
[ msg, sl ] = read4d( 'sl', i1, i2 );
if msg
  msg = '';
else
  surfcontour( xx, sl, dc0 );
  surfcontour( xx, sl, .01 * dc0 );
end

