%------------------------------------------------------------------------------%
% STEPU

% Displacement
u = u + dt * v;
%x = x + dt * v;
s1 = sum( u .* u, 4 ); [ umax, umaxi ] = max( s1(:) );
umax = sqrt( umax );
if umax > h / 10
  disp( 'Warning: u !<< h' )
end
if nrmdim, uslip = uslip + dt * vslip; end

