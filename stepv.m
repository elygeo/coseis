%------------------------------------------------------------------------------%
% STEPV

% Restoring force
% F = divS + hourglass_correction        non PML region
% P' + DP = [del]S, F = 1.P'             PML region
wt(1) = toc;
c = [ 1 6 5; 6 2 4; 5 4 3 ];
s2(:) = 0;
for ic = 1:3
for id = [ ic:3 1:ic-1 ];
  ix = 6 - ic - id;
  for iz = 1:size( operator, 1 )
    bc = [ operator{iz,2:7} ];
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    i1 = i1 + npml * bc(1:3);
    i2 = i2 - npml * bc(4:6);
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    if ic == id
      switch operator{iz,1}
      case 'g', s2(j,k,l) = dcng( w1, ic, x, id, j,   k,   l   );
      case 'r', s2(j,k,l) = dcnr( w1, ic, x, id, j,   k,   l   );
      case 'h', s2(j,k,l) = dh(   w1, ic,    id, j-1, k-1, l-1 );
      otherwise error operator
      end
    else
      switch operator{iz,1}
      case 'g', s2(j,k,l) = dcng( w2, ix, x, id, j,   k,   l   );
      case 'r', s2(j,k,l) = dcnr( w2, ix, x, id, j,   k,   l   );
      case 'h', s2(j,k,l) = dh(   w2, ix,    id, j-1, k-1, l-1 );
      otherwise error operator
      end
    end
  end
  bc = [ operator{1,2:7} ];
  i1 = opi1(1,:);
  i2 = opi2(1,:);
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  i = 0:npml-1
  if ic == id
    if bc(1), ji = j(i+1);   s2(ji,k,l) = dh( w1, ic, id, ji-1, k-1, l-1 ); end
    if bc(4), ji = j(end-i); s2(ji,k,l) = dh( w1, ic, id, ji-1, k-1, l-1 ); end
    if bc(2), ki = k(i+1);   s2(j,ki,l) = dh( w1, ic, id, j-1, ki-1, l-1 ); end
    if bc(5), ki = k(end-i); s2(j,ki,l) = dh( w1, ic, id, j-1, ki-1, l-1 ); end
    if bc(3), li = l(i+1);   s2(j,k,li) = dh( w1, ic, id, j-1, k-1, li-1 ); end
    if bc(6), li = l(end-i); s2(j,k,li) = dh( w1, ic, id, j-1, k-1, li-1 ); end
  else
    if bc(1), ji = j(i+1);   s2(ji,k,l) = dh( w2, ix, id, ji-1, k-1, l-1 ); end
    if bc(4), ji = j(end-i); s2(ji,k,l) = dh( w2, ix, id, ji-1, k-1, l-1 ); end
    if bc(2), ki = k(i+1);   s2(j,ki,l) = dh( w2, ix, id, j-1, ki-1, l-1 ); end
    if bc(5), ki = k(end-i); s2(j,ki,l) = dh( w2, ix, id, j-1, ki-1, l-1 ); end
    if bc(3), li = l(i+1);   s2(j,k,li) = dh( w2, ix, id, j-1, k-1, li-1 ); end
    if bc(6), li = l(end-i); s2(j,k,li) = dh( w2, ix, id, j-1, k-1, li-1 ); end
  end
  for i = 1:npml
    switch id
    case 1
      if bc(1), ji = j(i);
        s2(ji,k,l) = dn1(i) * s2(ji,k,l) + dn2(i) * p1(i,k,l,ic);
        p1(i,k,l,ic) = p1(i,k,l,ic) + s2(ji,k,l);
      end
      if bc(4), ji = j(end-i+1);
        s2(ji,k,l) = dn1(i) * s2(ji,k,l) + dn2(i) * p4(i,k,l,ic);
        p4(i,k,l,ic) = p4(i,k,l,ic) + s2(ji,k,l);
      end
    case 2
      if bc(2), ki = k(i);
        s2(j,ki,l) = dn1(i) * s2(j,ki,l) + dn2(i) * p2(j,i,l,ic);
        p2(j,i,l,ic) = p2(j,i,l,ic) + s2(j,ki,l);
      end
      if bc(5), ki = k(end-i+1);
        s2(j,ki,l) = dn1(i) * s2(j,ki,l) + dn2(i) * p5(j,i,l,ic);
        p5(j,i,l,ic) = p5(j,i,l,ic) + s2(j,ki,l);
      end
    case 3
      if bc(3), li = l(i);
        s2(j,k,li) = dn1(i) * s2(j,k,li) + dn2(i) * p3(j,k,i,ic);
        p3(j,k,i,ic) = p3(j,k,i,ic) + s2(j,k,li);
      end
      if bc(6), li = l(end-i+1);
        s2(j,k,li) = dn1(i) * s2(j,k,li) + dn2(i) * p6(j,k,i,ic);
        p6(j,k,i,ic) = p6(j,k,i,ic) + s2(j,k,li);
      end
    otherwise error id
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
  w1(:,:,:,i) = w1(:,:,:,i) .* mdt;
end

% Hourglass correction
bc = [ operator{1,2:7} ];
i1 = opi1(1,:);
i2 = opi2(1,:);
i1 = i1 + npml * bc(1:3);
i2 = i2 - npml * bc(4:6);
ih = hypocenter;
s1(:) = 0;
s2(:) = 0;
w2 = u + gamma(2) .* v;
for ic = 1:3
for iq = 1:4
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==ih(1)) = [];
  case 2, k(k==ih(2)) = [];
  case 3, l(l==ih(3)) = [];
  end
  s1(j,k,l) = hgy(j,k,l) .* hgh( 0, w2, ic, iq, j, k, l );
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = hgh( 1, s1, 1, iq, j-1, k-1, l-1 );
  switch nrmdim
  case 1
    s2(ih(1),:,:)   = s2(ih(1),:,:) + s2(ih(1)+1,:,:);
    s2(ih(1)+1,:,:) = s2(ih(1),:,:);
  case 2
    s2(:,ih(2),:)   = s2(:,ih(2),:) + s2(:,ih(2)+1,:);
    s2(:,ih(2)+1,:) = s2(:,ih(2),:);
  case 3
    s2(:,:,ih(3))   = s2(:,:,ih(3)) + s2(:,:,ih(3)+1);
    s2(:,:,ih(3)+1) = s2(:,:,ih(3));
  end
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2 .* rho;
end
end

% Fault calculations
if nrmdim, fault, end

% Velocity, V = V + dV
for iz = 1:size( locknodes, 1 )
  i1 = locki(1,:,iz);
  i2 = locki(2,:,iz);
  i = locknodes(iz,1:3) == 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  w1(j,k,l,i) = 0;
end
v = v + w1;

