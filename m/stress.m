%------------------------------------------------------------------------------%
% Stress calculations

% Modified dislplacement
w1 = u + dt * viscosity(1) * v;
s1(:) = 0;
w2(:) = 0;

% Loop over component and derivative direction
for ic  = 1:3
for iid = 1:3; id = mod( ic + iid - 1, 3 ) + 1;

% Elastic region: G = grad(U + gamma*V)
for iz = 1:size( oper, 1 )
  i1 = max( max( i1oper(iz,:), i1pml + 1 ),     i1cell )
  i2 = min( min( i2oper(iz,:), i2pml - 1 ) - 1, i2cell )
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  s1(j,k,l) = dfnc( oper(iz), w1, x, dx, ic, id, j, k, l );
end
i1 = i1cell;
i2 = i2cell;
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);

% PML region, non-damped directions: G = gradU
for i = 1:npml
  if id ~= 1 && bc1(1) == 1
    ji = i1(1) + i - 1;
    s1(ji,k,l) = dfnc( oper(1), u, x, dx, ic, id, ji, k, l );
  end
  if id ~= 1 && bc2(1) == 1
    ji = i2(1) - i + 1;
    s1(ji,k,l) = dfnc( oper(1), u, x, dx, ic, id, ji, k, l );
  end
  if id ~= 2 && bc1(2) == 1
    ki = i1(2) + i - 1;
    s1(j,ki,l) = dfnc( oper(1), u, x, dx, ic, id, j, ki, l );
  end
  if id ~= 2 && bc2(2) == 1
    ki = i2(2) - i + 1;
    s1(j,ki,l) = dfnc( oper(1), u, x, dx, ic, id, j, ki, l );
  end
  if id ~= 3 && bc1(3) == 1
    li = i1(3) + i - 1;
    s1(j,k,li) = dfnc( oper(1), u, x, dx, ic, id, j, k, li );
  end
  if id ~= 3 && bc2(3) == 1
    li = i2(3) - i + 1;
    s1(j,k,li) = dfnc( oper(1), u, x, dx, ic, id, j, k, li );
  end
end

% PML region, damped direction: G' + DG = gradV
for i = 1:npml
  if id == 1 && bc1(1) == 1
    ji = i1(1) + i - 1;
    s1(ji,k,l) = dfnc( oper(1), v, x, dx, ic, id, ji, k, l );
    s1(ji,k,l) = dc2(i) * s1(ji,k,l) + dc1(i) * g1(i,k,l,ic);
    g1(i,k,l,ic) = s1(ji,k,l);
  end
  if id == 1 && bc2(1) == 1
    ji = i2(1) - i + 1;
    s1(ji,k,l) = dfnc( oper(1), v, x, dx, ic, id, ji, k, l );
    s1(ji,k,l) = dc2(i) * s1(ji,k,l) + dc1(i) * g4(i,k,l,ic);
    g4(i,k,l,ic) = s1(ji,k,l);
  end
  if id == 2 && bc1(2) == 1
    ki = i1(2) + i - 1;
    s1(j,ki,l) = dfnc( oper(1), v, x, dx, ic, id, j, ki, l );
    s1(j,ki,l) = dc2(i) * s1(j,ki,l) + dc1(i) * g2(j,i,l,ic);
    g2(j,i,l,ic) = s1(j,ki,l);
  end
  if id == 2 && bc2(2) == 1
    ki = i2(2) - i + 1;
    s1(j,ki,l) = dfnc( oper(1), v, x, dx, ic, id, j, ki, l );
    s1(j,ki,l) = dc2(i) * s1(j,ki,l) + dc1(i) * g5(j,i,l,ic);
    g5(j,i,l,ic) = s1(j,ki,l);
  end
  if id == 3 && bc1(3) == 1
    li = i1(3) + i - 1;
    s1(j,k,li) = dfnc( oper(1), v, x, dx, ic, id, j, k, li );
    s1(j,k,li) = dc2(i) * s1(j,k,li) + dc1(i) * g3(j,k,i,ic);
    g3(j,k,i,ic) = s1(j,k,li);
  end
  if id == 3 && bc2(3) == 1
    li = i2(3) - i + 1;
    s1(j,k,li) = dfnc( oper(1), v, x, dx, ic, id, j, k, li );
    s1(j,k,li) = dc2(i) * s1(j,k,li) + dc1(i) * g6(j,k,i,ic);
    g6(j,k,i,ic) = s1(j,k,li);
  end
end

% Add contribution to strain
if ic == id
  w1(:,:,:,ic) = s1;
else
  i = 6 - ic - id;
  w2(:,:,:,i) = w2(:,:,:,i) + s1;
end

end
end

% Hook's Law: W = lam*trace(G)*I + mu*(G + G^T)
s1 = lam .* sum( w1, 4 );
for i = 1:3
  w1(:,:,:,i) = 2. * mu .* w1(:,:,:,i) + s1;
  w2(:,:,:,i) =      mu .* w2(:,:,:,i);
end

