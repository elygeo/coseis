%------------------------------------------------------------------------------%
% STEPW

% Gadient
% G = grad(U + gamma*V)    non PML region
% G' + DG = gradV          PML region
c = [ 1 2 3; 2 3 1; 3 1 2 ];
s2(:) = 0;
w2(:) = 0;
for iii = 1:3
s1 = u(:,:,:,iii) + gamma(1) .* v(:,:,:,iii);
for ii = 1:3
  for iz = 1:size( operator, 1 )
    bc = [ operator{iz,2:7} ];
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    i1 = i1 + npml * bc(1:3);
    i2 = i2 - npml * bc(4:6);
    l = i1(3):i2(3)-1;
    k = i1(2):i2(2)-1;
    j = i1(1):i2(1)-1;
    switch nrmdim
    case 1, j(j==hypocenter(1)) = [];
    case 2, k(k==hypocenter(2)) = [];
    case 3, l(l==hypocenter(3)) = [];
    end
    switch operator{iz,1}
    case 'g', s2(j,k,l) = dncg( s1, 1, x, ii, j, k, l );
    case 'r', s2(j,k,l) = dncr( s1, 1, x, ii, j, k, l );
    case 'h', s2(j,k,l) = dh(   s1, 1,    ii, j, k, l );
    otherwise error operator
    end
  end
  bc = [ operator{1,2:7} ];
  i1 = opi1(1,:);
  i2 = opi2(1,:);
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==hypocenter(1)) = [];
  case 2, k(k==hypocenter(2)) = [];
  case 3, l(l==hypocenter(3)) = [];
  end
  for i = 1:npml-1
    switch ii
    case { 2, 3 }
      if bc(1), ji = j(i);       s2(ji,k,l) = dh(u,iii,ii,ji,k,l); end
      if bc(4), ji = j(end-i+1); s2(ji,k,l) = dh(u,iii,ii,ji,k,l); end
    case { 3, 1 }
      if bc(2), ki = k(i);       s2(j,ki,l) = dh(u,iii,ii,j,ki,l); end
      if bc(5), ki = k(end-i+1); s2(j,ki,l) = dh(u,iii,ii,j,ki,l); end
    case { 1, 2 }
      if bc(3), li = l(i);       s2(j,k,li) = dh(u,iii,ii,j,k,li); end
      if bc(6), li = l(end-i+1); s2(j,k,li) = dh(u,iii,ii,j,k,li); end
    end
  end
  for i = 1:npml-1
    switch ii
    case 1
      if bc(1), ji = j(i);
        s2(ji,k,l) = dc1(i) * dh(v,iii,ii,ji,k,l) + dc2(i) * g1(i,k,l,iii);
        g1(i,k,l,iii) = s2(ji,k,l);
      end
      if bc(4), ji = j(end-i+1);
        s2(ji,k,l) = dc1(i) * dh(v,iii,ii,ji,k,l) + dc2(i) * g4(i,k,l,iii);
        g4(i,k,l,iii) = s2(ji,k,l);
      end
    case 2
      if bc(2), ki = k(i);
        s2(j,ki,l) = dc1(i) * dh(v,iii,ii,j,ki,l) + dc2(i) * g2(j,i,l,iii);
        g2(j,i,l,iii) = s2(j,ki,l);
      end
      if bc(5), ki = k(end-i+1);
        s2(j,ki,l) = dc1(i) * dh(v,iii,ii,j,ki,l) + dc2(i) * g5(j,i,l,iii);
        g5(j,i,l,iii) = s2(j,ki,l);
      end
    case 3
      if bc(3), li = l(i);
        s2(j,k,li) = dc1(i) * dh(v,iii,ii,j,k,li) + dc2(i) * g3(j,k,i,iii);
        g3(j,k,i,iii) = s2(j,k,li);
      end
      if bc(6), li = l(end-i+1);
        s2(j,k,li) = dc1(i) * dh(v,iii,ii,j,k,li) + dc2(i) * g6(j,k,i,iii);
        g6(j,k,i,iii) = s2(j,k,li);
      end
    otherwise error ii
    end
  end
  if ii == iii
    w1(:,:,:,iii) = s2;
  else
    i = 6 - iii - ii;
    w2(:,:,:,i) = w2(:,:,:,i) + s2;
  end
end
end

% Hook's Law, linear stress/strain relation
% S = lam*trace(G)*I + miu*(G + G^T)
s1 = lam .* sum( w1, 4 );
for i = 1:3
  w1(:,:,:,i) = 2 * miu .* w1(:,:,:,i) + s1;
  w2(:,:,:,i) = miu .* w2(:,:,:,i);
end

% Moment source
if msrcradius, momentsrc, end

