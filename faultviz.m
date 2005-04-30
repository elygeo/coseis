%------------------------------------------------------------------------------%
% FAULTVIZ

if ~nrmdim, return, end

i1 = halo1 + 1;
i2 = halo1 + ncore;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);
xg = squeeze( x(j,k,l,:) + xscl * u(j,k,l,:) ); 
i1(nrmdim) = 1;
i2(nrmdim) = 1;
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);
if rcrit
  hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, it * dt * vrup ) );
  if nclramp
    hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, ( it - nclramp ) * dt * vrup ) );
  end
end
scontour( xg, uslip(j,k,l), dc0 );
scontour( xg, uslip(j,k,l), .01 * dc0 );
switch model
case { 'the2', 'the3' }
  scontour( xg, fd(j,k,l), 10 );
end

