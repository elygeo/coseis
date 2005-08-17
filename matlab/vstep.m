%------------------------------------------------------------------------------%
% STEPV

% Restoring force
% P' + DP = [del]S, F = 1.P'             PML region
% F = divS                               non PML region (D=0)
s2(:) = 0;
for ic = 1:3
for id = [ ic:3 1:ic-1 ];
  ix = 6 - ic - id;
  for iz = 1:size( operator, 1 )
    op = operator{iz,1};
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    if ic == id
      s2(j,k,l) = dfcn( op, w1, x, dx, ic, id, j, k, l );
    else
      s2(j,k,l) = dfcn( op, w2, x, dx, ix, id, j, k, l );
    end
  end
  i1 = halo + [ 1 1 1 ];
  i2 = halo + np;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  for i = 1:npml
    if id == 1 && bc(1), ji = i1(1) + i - 1;
      s2(ji,k,l) = dn2(i) * s2(ji,k,l) + dn1(i) * p1(i,k,l,ic);
      p1(i,k,l,ic) = p1(i,k,l,ic) + dt * s2(ji,k,l);
    end
    if id == 1 && bc(4), ji = i2(1) - i + 1;
      s2(ji,k,l) = dn2(i) * s2(ji,k,l) + dn1(i) * p4(i,k,l,ic);
      p4(i,k,l,ic) = p4(i,k,l,ic) + dt * s2(ji,k,l);
    end
    if id == 2 && bc(2), ki = i1(2) + i - 1;
      s2(j,ki,l) = dn2(i) * s2(j,ki,l) + dn1(i) * p2(j,i,l,ic);
      p2(j,i,l,ic) = p2(j,i,l,ic) + dt * s2(j,ki,l);
    end
    if id == 2 && bc(5), ki = i2(2) - i + 1;
      s2(j,ki,l) = dn2(i) * s2(j,ki,l) + dn1(i) * p5(j,i,l,ic);
      p5(j,i,l,ic) = p5(j,i,l,ic) + dt * s2(j,ki,l);
    end
    if id == 3 && bc(3), li = i1(3) + i - 1;
      s2(j,k,li) = dn2(i) * s2(j,k,li) + dn1(i) * p3(j,k,i,ic);
      p3(j,k,i,ic) = p3(j,k,i,ic) + dt * s2(j,k,li);
    end
    if id == 3 && bc(6), li = i2(3) - i + 1;
      s2(j,k,li) = dn2(i) * s2(j,k,li) + dn1(i) * p6(j,k,i,ic);
      p6(j,k,i,ic) = p6(j,k,i,ic) + dt * s2(j,k,li);
    end
  end
  if ic == id
    w1(:,:,:,ic) = s2;
  else
    w1(:,:,:,ic) = w1(:,:,:,ic) + s2;
  end
end
end

% Newton's Law, dV = F / m * dt
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) .* rho;
end

% Hourglass correction
i1 = halo + [ 1 1 1 ];
i2 = halo + np;
s1(:) = 0;
s2(:) = 0;
w2 = u + gamma(2) .* v;
for ic = 1:3
for iq = 1:4
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  s1(j,k,l) = yc(j,k,l) .* hgnc( w2, ic, iq, j, k, l );
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = yn(j,k,l) .* hgcn( s1, 1, iq, j, k, l );
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2;
end
end

% Fault calculations
if nrmdim, fault, end

% Velocity, V = V + dV
for iz = 1:size( locknodes, 1 )
  i1 = locki1(iz,:);
  i2 = locki2(iz,:);
  i = locknodes(iz,1:3) == 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  w1(j,k,l,i) = 0;
end
v = v + w1;

if planewavedim, planewave, end

