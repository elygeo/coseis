%------------------------------------------------------------------------------%
% FAULTVIZ

if ~nrmdim, return, end

j = 2:n(1) - 1;
k = 2:n(2) - 1;
l = hypocenter(3) + 1;
xg = squeeze( x(j,k,l,:) + xscl * u(j,k,l,:) ); 
if rcrit
  hh = scontour( xg, r(j,k), min( rcrit, it * dt * vrup ) );
  set( hh, 'LineStyle', ':' );
  if nclramp
    hh = scontour( xg, r(j,k), min( rcrit, ( it - nclramp ) * dt * vrup ) );
    set( hh, 'LineStyle', ':' );
  end
end
scontour( xg, uslip(j,k), dc0 );
scontour( xg, uslip(j,k), .01 * dc0 );
switch model
case { 'the2', 'the3' }
  scontour( xg, fd(j,k), 10 );
end

