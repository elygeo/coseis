%------------------------------------------------------------------------------%
% STEPW

% Gadient
% G = grad(U + gamma*V)    non PML region
% G' + DG = gradV          PML region
c = [ 1 2 3; 2 3 1; 3 1 2 ];
s2(:) = 0;
w2(:) = 0;
for ic = 1:3
s1 = u(:,:,:,ic) + gamma(1) .* v(:,:,:,ic);
for id = 1:3
  ix = 6 - ic - id;
  for iz = 1:size( operator, 1 )
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    l = i1(3):i2(3)-1;
    k = i1(2):i2(2)-1;
    j = i1(1):i2(1)-1;
    switch nrmdim
    case 1, j(j==hypocenter(1)) = [];
    case 2, k(k==hypocenter(2)) = [];
    case 3, l(l==hypocenter(3)) = [];
    end
    switch operator{iz,1}
    case 'g', s2(j,k,l) = dng( s1, 1, x, id, j, k, l );
    case 'r', s2(j,k,l) = dnr( s1, 1, x, id, j, k, l );
    case 'h', s2(j,k,l) = dnh( s1, 1, h, id, j, k, l );
    otherwise error operator
    end
  end
  i1 = halo1 + 1;
  i2 = halo1 + ncore;
  l = i1(3):i2(3)-1;
  k = i1(2):i2(2)-1;
  j = i1(1):i2(1)-1;
  switch nrmdim
  case 1, j(j==hypocenter(1)) = [];
  case 2, k(k==hypocenter(2)) = [];
  case 3, l(l==hypocenter(3)) = [];
  end
  for i = 1:npml
    if id ~= 1 && bc(1), ji = j(i);
      switch operator{1,1}
      case 'g', s2(ji,k,l) = dng( u, ic, x, id, ji, k, l );
      case 'r', s2(ji,k,l) = dnr( u, ic, x, id, ji, k, l );
      case 'h', s2(ji,k,l) = dnh( u, ic, h, id, ji, k, l );
      end
    end
    if id ~= 1 && bc(4), ji = j(end-i+1);
      switch operator{1,1}
      case 'g', s2(ji,k,l) = dng( u, ic, x, id, ji, k, l );
      case 'r', s2(ji,k,l) = dnr( u, ic, x, id, ji, k, l );
      case 'h', s2(ji,k,l) = dnh( u, ic, h, id, ji, k, l );
      end
    end
    if id ~= 2 && bc(2), ki = k(i);
      switch operator{1,1}
      case 'g', s2(j,ki,l) = dng( u, ic, x, id, j, ki, l );
      case 'r', s2(j,ki,l) = dnr( u, ic, x, id, j, ki, l );
      case 'h', s2(j,ki,l) = dnh( u, ic, h, id, j, ki, l );
      end
    end
    if id ~= 2 && bc(5), ki = k(end-i+1);
      switch operator{1,1}
      case 'g', s2(j,ki,l) = dng( u, ic, x, id, j, ki, l );
      case 'r', s2(j,ki,l) = dnr( u, ic, x, id, j, ki, l );
      case 'h', s2(j,ki,l) = dnh( u, ic, h, id, j, ki, l );
      end
    end
    if id ~= 3 && bc(3), li = l(i);
      switch operator{1,1}
      case 'g', s2(j,k,li) = dng( u, ic, x, id, j, k, li );
      case 'r', s2(j,k,li) = dnr( u, ic, x, id, j, k, li );
      case 'h', s2(j,k,li) = dnh( u, ic, h, id, j, k, li );
      end
    end
    if id ~= 3 && bc(6), li = l(end-i+1);
      switch operator{1,1}
      case 'g', s2(j,k,li) = dng( u, ic, x, id, j, k, li );
      case 'r', s2(j,k,li) = dnr( u, ic, x, id, j, k, li );
      case 'h', s2(j,k,li) = dnh( u, ic, h, id, j, k, li );
      end
    end
  end
  for i = 1:npml
    if id == 1 && bc(1), ji = j(i);
      switch operator{1,1}
      case 'g', s2(ji,k,l) = dng( v, ic, x, id, ji, k, l );
      case 'r', s2(ji,k,l) = dnr( v, ic, x, id, ji, k, l );
      case 'h', s2(ji,k,l) = dnh( v, ic, h, id, ji, k, l );
      end
      s2(ji,k,l) = dc2(i) * s2(ji,k,l) + dc1(i) * g1(i,k,l,ic);
      g1(i,k,l,ic) = s2(ji,k,l);
    end
    if id == 1 && bc(4), ji = j(end-i+1);
      switch operator{1,1}
      case 'g', s2(ji,k,l) = dng( v, ic, x, id, ji, k, l );
      case 'r', s2(ji,k,l) = dnr( v, ic, x, id, ji, k, l );
      case 'h', s2(ji,k,l) = dnh( v, ic, h, id, ji, k, l );
      end
      s2(ji,k,l) = dc2(i) * s2(ji,k,l) + dc1(i) * g4(i,k,l,ic);
      g4(i,k,l,ic) = s2(ji,k,l);
    end
    if id == 2 && bc(2), ki = k(i);
      switch operator{1,1}
      case 'g', s2(j,ki,l) = dng( v, ic, x, id, j, ki, l );
      case 'r', s2(j,ki,l) = dnr( v, ic, x, id, j, ki, l );
      case 'h', s2(j,ki,l) = dnh( v, ic, h, id, j, ki, l );
      end
      s2(j,ki,l) = dc2(i) * s2(j,ki,l) + dc1(i) * g2(j,i,l,ic);
      g2(j,i,l,ic) = s2(j,ki,l);
    end
    if id == 2 && bc(5), ki = k(end-i+1);
      switch operator{1,1}
      case 'g', s2(j,ki,l) = dng( v, ic, x, id, j, ki, l );
      case 'r', s2(j,ki,l) = dnr( v, ic, x, id, j, ki, l );
      case 'h', s2(j,ki,l) = dnh( v, ic, h, id, j, ki, l );
      end
      s2(j,ki,l) = dc2(i) * s2(j,ki,l) + dc1(i) * g5(j,i,l,ic);
      g5(j,i,l,ic) = s2(j,ki,l);
    end
    if id == 3 && bc(3), li = l(i);
      switch operator{1,1}
      case 'g', s2(j,k,li) = dng( v, ic, x, id, j, k, li );
      case 'r', s2(j,k,li) = dnr( v, ic, x, id, j, k, li );
      case 'h', s2(j,k,li) = dnh( v, ic, h, id, j, k, li );
      end
      s2(j,k,li) = dc2(i) * s2(j,k,li) + dc1(i) * g3(j,k,i,ic);
      g3(j,k,i,ic) = s2(j,k,li);
    end
    if id == 3 && bc(6), li = l(end-i+1);
      switch operator{1,1}
      case 'g', s2(j,k,li) = dng( v, ic, x, id, j, k, li );
      case 'r', s2(j,k,li) = dnr( v, ic, x, id, j, k, li );
      case 'h', s2(j,k,li) = dnh( v, ic, h, id, j, k, li );
      end
      s2(j,k,li) = dc2(i) * s2(j,k,li) + dc1(i) * g6(j,k,i,ic);
      g6(j,k,i,ic) = s2(j,k,li);
    end
  end
  if ic == id
    w1(:,:,:,ic) = s2;
  else
    w2(:,:,:,ix) = w2(:,:,:,ix) + s2;
  end
end
end

% Hook's Law, linear stress/strain relation
% S = lam*trace(G)*I + miu*(G + G^T)
s1 = lam .* sum( w1, 4 );
for i = 1:3
  w1(:,:,:,i) = 2 * miu .* w1(:,:,:,i) + s1;
  w2(:,:,:,i) =     miu .* w2(:,:,:,i);
end

% Moment source
if msrcradius, momentsrc, end

