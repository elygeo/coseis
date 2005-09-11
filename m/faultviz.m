%------------------------------------------------------------------------------%
% FAULTVIZ

if ~nrmdim, return, end

i1 = i1node;
i2 = i2node;
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
if dofault
  switch field
  case 'u', vg = us(j,k,l);
  case 'v', vg = vs(j,k,l);
  case 'w', if comp == nrmdim, vg = tn(j,k,l); else, vg = ts(j,k,l); end
  otherwise error field
  end
  vg = squeeze( vg );
  vg = .25 * ( ...
    vg(1:end-1,1:end-1) + vg(2:end,1:end-1) + ...
    vg(1:end-1,2:end)   + vg(2:end,2:end) );
  hfault = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
  hold on
  set( hfault, ...
    'Tag', 'fault', ...
    'LineWidth', linewidth / 4, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'flat', ...
    'FaceAlpha', 1, ...
    'FaceLighting', 'none' );
end
if rcrit
  hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, it * dt * vrup ) );
  if nclramp
    hh = scontour( xg, squeeze( r(j,k,l) ), min( rcrit, ( it - nclramp ) * dt * vrup ) );
  end
end
scontour( xg, us(j,k,l), dc0 );
scontour( xg, us(j,k,l), .01 * dc0 );
scontour( xg, co(j,k,l), 1e8 );

