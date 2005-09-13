%------------------------------------------------------------------------------%
% FAULTVIZ

if ~inrm, return, end

i1 = i1node;
i2 = i2node;
i1(inrm) = i0(inrm);
i2(inrm) = i0(inrm);
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);
xg = squeeze( x(j,k,l,:) + xscl * u(j,k,l,:) ); 
i1(inrm) = 1;
i2(inrm) = 1;
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);
if rcrit
  hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, it * dt * vrup ) );
  if nramp
    hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, ( it - nramp ) * dt * vrup ) );
  end
end
scontour( xg, us(j,k,l), dc0 );
scontour( xg, us(j,k,l), .01 * dc0 );
scontour( xg, co(j,k,l), 1e8 );

