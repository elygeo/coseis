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
  sv = sqrt( sum( t1 * t1, 4 ) );
  sl = sl + dt * sv;
  where ( trup == 0. .and. sv > truptol ) trup = t;
  % Rupture time
  if truptol
    i1 = ihypo;
    i1(ifn) = 1;
    l = i1(3);
    k = i1(2);
    j = i1(1);
    i = vs > truptol;
    if find( i )
      tarrest = t;
      if i(j,k,l), tarresthypo = tarrest; end
      trup( i & ( ~ trup ) ) = t;
    end
  end
end if

