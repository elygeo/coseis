%------------------------------------------------------------------------------%
% STEPW

% Gadient
% G = grad(U + gamma*V)    non PML region
% G' + DG = gradV          PML region
c = [ 1 2 3; 2 3 1; 3 1 2 ];
w2(:) = 0;
for iii = 1:3
  s1 = u(:,:,:,iii) + gamma(1) .* v(:,:,:,iii);
  s2(:) = 0;
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
      case 1
        if bc(1) == 1
          ji = j(i);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g1(i,k,l,iii) = dampc1(i) * s2(ji,k,l) + dampc2(i) * g1(i,k,l,iii);
          s2(ji,k,l) = g1(i,k,l,iii);
        end
        if bc(4) == 1
          ji = j(end-i+1);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g4(i,k,l,iii) = dampc1(i) * s2(ji,k,l) + dampc2(i) * g4(i,k,l,iii);
          s2(ji,k,l) = g4(i,k,l,iii);
        end
      case 2
        if bc(2) == 1
          ki = k(i);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g2(j,i,l,iii) = dampc1(i) * s2(j,ki,l) + dampc2(i) * g2(j,i,l,iii);
          s2(j,ki,l) = g2(j,i,l,iii);
        end
        if bc(5) == 1
          ki = k(end-i+1);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g5(j,i,l,iii) = dampc1(i) * s2(j,ki,l) + dampc2(i) * g5(j,i,l,iii);
          s2(j,ki,l) = g5(j,i,l,iii);
        end
      case 3
        if bc(3) == 1
          li = l(i);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g3(j,k,i,iii) = dampc1(i) * s2(j,k,li) + dampc2(i) * g3(j,k,i,iii);
          s2(j,k,li) = g3(j,k,i,iii);
        end
        if bc(6) == 1
          li = l(end-i+1);
          s2(ji,k,l) = dh( v, 1, ii, ji, k, l );
          g6(j,k,i,iii) = dampc1(i) * s2(j,k,li) + dampc2(i) * g6(j,k,i,iii);
          s2(j,k,li) = g6(j,k,i,iii);
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

