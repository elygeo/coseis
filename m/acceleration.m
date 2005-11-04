% Acceleration

s1(:) = 0.;

% Loop over component and derivative direction
for ic  = 1:3
for iid = 1:3; id = mod( ic + iid - 2, 3 ) + 1;

% Elastic region: F = divS
for iz = 1:size( oper, 1 )
  i1 = max( i1oper(iz,:), i1node );
  i2 = min( i2oper(iz,:), i2node );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  if ic == id
    s1(j,k,l) = diffcn( oper(iz), w1, x, dx, ic, id, j, k, l );
  else
    i = 6 - ic - id;
    s1(j,k,l) = diffcn( oper(iz), w2, x, dx, i, id, j, k, l );
  end
end

% PML region: P' + DP = [del]S, F = 1.P'
switch id
case 1
  k = i1node(2):i2node(2);
  l = i1node(3):i2node(3);
  for j = i1node(1):i1pml(1)
    i = j - nnoff(1);
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p1(i,k,l,ic);
    p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s1(j,k,l);
  end
  for j = i2pml(1):i2node(1)
    i = nn(1) - j + nnoff(1) + 1;
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p4(i,k,l,ic);
    p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s1(j,k,l);
  end
case 2
  j = i1node(1):i2node(1);
  l = i1node(3):i2node(3);
  for k = i1node(2):i1pml(2)
    i = k - nnoff(2);
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p2(j,i,l,ic);
    p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s1(j,k,l);
  end
  for k = i2pml(2):i2node(2)
    i = nn(2) - k + nnoff(2) + 1;
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p5(j,i,l,ic);
    p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s1(j,k,l);
  end
case 3
  j = i1node(1):i2node(1);
  k = i1node(2):i2node(2);
  for l = i1node(3):i1pml(3)
    i = l - nnoff(3);
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p3(j,k,i,ic);
    p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s1(j,k,l);
  end
  for l = i2pml(3):i2node(3)
    i = nn(3) - l + nnoff(3) + 1;
    s1(j,k,l) = dn2(i) * s1(j,k,l) + dn1(i) * p6(j,k,i,ic);
    p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s1(j,k,l);
  end
end

% Add contribution to force vector
if ic == id
  w1(:,:,:,ic) = s1;
else
  w1(:,:,:,ic) = w1(:,:,:,ic) + s1;
end

end
end

% Hourglass correction
w2 = u + dt * viscosity(2) * v;
s1(:) = 0.;
s2(:) = 0.;
for ic = 1:3
for iq = 1:4
  l = i1cell(3):i2cell(3);
  k = i1cell(2):i2cell(2);
  j = i1cell(1):i2cell(1);
  s1(j,k,l) = hourglassnc( w2, ic, iq, j, k, l );
  s1 = y .* s1;
  l = i1node(3):i2node(3);
  k = i1node(2):i2node(2);
  j = i1node(1):i2node(1);
  s2(j,k,l) = hourglasscn( s1, iq, j, k, l );
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2;
end
end

% Newton's Law: A = F / m
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) .* mr;
end

