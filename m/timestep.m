% Time integration

it = it + 1;
t  = t  + dt;
v  = v  + dt * w1;
u  = u  + dt * v;

% Fault time integration
if ifn, then
  i1 = 1;
  i2 = nm;
  i1(ifn) = ihypo(ifn);
  i2(ifn) = ihypo(ifn);
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  i1(ifn) = ihypo(ifn) + 1;
  i2(ifn) = ihypo(ifn) + 1;
  j3 = i1(1); j4 = i2(1);
  k3 = i1(2); k4 = i2(2);
  l3 = i1(3); l4 = i2(3);
  t1 = v(j3:j4,k3:k4,l3:l4,:) - v(j1:j2,k1:k2,l1:l2,:);
  f1 = sqrt( sum( t1 * t1, 4 ) );
  if svtol > 0.
    i = f1 >= svtol & trup > 1e8;
    trup(i) = t - dt * ( .5 + (svtol - f1(i)) ./ (sv(i) - f1(i)) );
    i = f1 >= svtol;
    tarr(i) = 1e9
    i = sv >= svtol & f1 < svtol;
    tarr(i) = t - dt * ( .5 + (svtol - f1(i)) ./ (sv(i) - f1(i)) );
  end
  sv = f1;
  sl = sl + dt * sv;
end if

