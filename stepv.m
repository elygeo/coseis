%------------------------------------------------------------------------------%
% STEPV

% Restoring force
% F = divS + hourglass_correction        non PML region
% P' + DP = [del]S, F = 1.P'             PML region
wt(1) = toc;
c = [ 1 6 5; 6 2 4; 5 4 3 ];
s1(:) = 0;
for iii = 1:3
for ii  = [ iii:3 1:iii-1 ];
  for iz = 1:size( operator, 1 )
    bc = [ operator{iz,2:7} ];
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    if ii == iii
      switch operator{iz,1}
      case 'g', s1(j,k,l) = dcng( w1, ii, x, ii, j, k, l );
      case 'r', s1(j,k,l) = dcnr( w1, ii, x, ii, j, k, l );
      case 'h', s1(j,k,l) = dh(   w1, ii,    ii, j-1, k-1, l-1 );
      otherwise error operator
      end
    else
      i = 6 - iii - ii;
      switch operator{iz,1}
      case 'g', s1(j,k,l) = dcng( w2, i, x, ii, j, k, l );
      case 'r', s1(j,k,l) = dcnr( w2, i, x, ii, j, k, l );
      case 'h', s1(j,k,l) = dh(   w2, i,    ii, j-1, k-1, l-1 );
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
  for i = 1:npml
    switch ii
    case 1
      if bc(1) == 1
        ji = j(i);
        s2(ji,k,l) = p1(i,k,l,iii);
        p1(i,k,l,iii) = dampn1(i) * s1(ji,k,l) + dampn2(i) * p1(i,k,l,iii);
        s1(ji,k,l) = p1(i,k,l,iii) - s2(ji,k,l);
      end
      if bc(4) == 1
        ji = j(end-i+1);
        s2(ji,k,l) = p4(i,k,l,iii);
        p4(i,k,l,iii) = dampn1(i) * s1(ji,k,l) + dampn2(i) * p4(i,k,l,iii);
        s1(ji,k,l) = p4(i,k,l,iii) - s2(ji,k,l);
      end
    case 2
      if bc(2) == 1
        ki = k(i);
        s2(j,ki,l) = p2(j,i,l,iii);
        p2(j,i,l,iii) = dampn1(i) * s1(j,ki,l) + dampn2(i) * p2(j,i,l,iii);
        s1(j,ki,l) = p2(j,i,l,iii) - s2(j,ki,l);
      end
      if bc(5) == 1
        ki = k(end-i+1);
        s2(j,ki,l) = p5(j,i,l,iii);
        p5(j,i,l,iii) = dampn1(i) * s1(j,ki,l) + dampn2(i) * p5(j,i,l,iii);
        s1(j,ki,l) = p5(j,i,l,iii) - s2(j,ki,l);
      end
    case 3
      if bc(3) == 1
        li = l(i);
        s2(j,k,li) = p3(j,k,i,iii);
        p3(j,k,i,iii) = dampn1(i) * s1(j,k,li) + dampn2(i) * p3(j,k,i,iii);
        s1(j,k,li) = p3(j,k,i,iii) - s2(j,k,li);
      end
      if bc(6) == 1
        li = l(end-i+1);
        s2(j,k,li) = p6(j,k,i,iii);
        p6(j,k,i,iii) = dampn1(i) * s1(j,k,li) + dampn2(i) * p6(j,k,i,iii);
        s1(j,k,li) = p6(j,k,i,iii) - s2(j,k,li);
      end
    otherwise error ii
    end
  end
  if iii == ii,
    w1(:,:,:,iii) = s1;
  else
    w1(:,:,:,iii) = w1(:,:,:,iii) + s1;
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
ii = hypocenter;
s1(:) = 0;
s2(:) = 0;
w2 = u + gamma(2) .* v;
for i  = 1:3
for iq = 1:4
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==hypocenter(1)) = [];
  case 2, k(k==hypocenter(2)) = [];
  case 3, l(l==hypocenter(3)) = [];
  end
  s1(j,k,l) = hgy(j,k,l) .* hgh( 0, w2, i, iq, j, k, l );
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = hgh( 1, s1, 1, iq, j-1, k-1, l-1 );
  switch nrmdim
  case 1
    s2(ii(1),:,:)   = s2(ii(1),:,:) + s2(ii(1)+1,:,:);
    s2(ii(1)+1,:,:) = s2(ii(1),:,:);
  case 2
    s2(:,ii(2),:)   = s2(:,ii(2),:) + s2(:,ii(2)+1,:);
    s2(:,ii(2)+1,:) = s2(:,ii(2),:);
  case 3
    s2(:,:,ii(3))   = s2(:,:,ii(3)) + s2(:,:,ii(3)+1);
    s2(:,:,ii(3)+1) = s2(:,:,ii(3));
  end
  w1(:,:,:,i) = w1(:,:,:,i) - s2 .* rho;
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

