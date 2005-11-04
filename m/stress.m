% Stress calculations

% Modified dislplacement
w1 = u + dt * v * viscosity(1);
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
  s1(j,k,l) = diffnc( oper(iz), w1, x, dx, ic, id, j, k, l );
end

% PML region, non-damped directions: G = gradU
if id ~= 1
  k = i1cell(2):i2cell(2);
  l = i1cell(3):i2cell(3);
  j = i1cell(1):i1pml(1);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
  j = i2pml(1)-1:i2cell(1);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
end
if id ~= 2
  j = i1cell(1):i2cell(1);
  l = i1cell(3):i2cell(3);
  k = i1cell(2):i1pml(2);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
  k = i2pml(2)-1:i2cell(2);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
end
if id ~= 3
  j = i1cell(1):i2cell(1);
  k = i1cell(2):i2cell(2);
  l = i1cell(3):i1pml(3);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
  l = i2pml(3)-1:i2cell(3);
  s1(j,k,l) = diffnc( oper(1), u, x, dx, ic, id, j, k, l );
end

% PML region, damped direction: G' + DG = gradV
switch id
case 1
  k = i1cell(2):i2cell(2);
  l = i1cell(3):i2cell(3);
  for j = i1cell(1):i1pml(1)
    i = j - nnoff(1);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g1(i,k,l,ic);
    g1(i,k,l,ic) = s1(j,k,l);
  end
  for j = i2pml(1)-1:i2cell(1)
    i = nn(1) - j + nnoff(1);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g4(i,k,l,ic);
    g4(i,k,l,ic) = s1(j,k,l);
  end
case 2
  j = i1cell(1):i2cell(1);
  l = i1cell(3):i2cell(3);
  for k = i1cell(2):i1pml(2)
    i = k - nnoff(2);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g2(j,i,l,ic);
    g2(j,i,l,ic) = s1(j,k,l);
  end
  for k = i2pml(2)-1:i2cell(2)
    i = nn(2) - k + nnoff(2);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g5(j,i,l,ic);
    g5(j,i,l,ic) = s1(j,k,l);
  end
case 3
  j = i1cell(1):i2cell(1);
  k = i1cell(2):i2cell(2);
  for l = i1cell(3):i1pml(3)
    i = l - nnoff(3);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g3(j,k,i,ic);
    g3(j,k,i,ic) = s1(j,k,l);
  end
  for l = i2pml(3)-1:i2cell(3)
    i = nn(3) - l + nnoff(3);
    s1(j,k,l) = diffnc( oper(1), v, x, dx, ic, id, j, k, l );
    s1(j,k,l) = dc2(i) * s1(j,k,l) + dc1(i) * g6(j,k,i,ic);
    g6(j,k,i,ic) = s1(j,k,l);
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

