%------------------------------------------------------------------------------%
% STEPW

% Gadient
% G = grad(U + gamma*V)    non PML region
% G' + DG = gradV          PML region
s2(:) = 0;
w2(:) = 0;
for ic = 1:3
s1 = u(:,:,:,ic) + gamma(1) .* v(:,:,:,ic);
for id = 1:3
  ix = 6 - ic - id;
  for iz = 1:size( operator, 1 )
    [ i1, i2 ] = zoneselect( ioper(iz,:), nhalo, np, hypocenter, nrmdim );
    op = operator(iz);
    i2 = i2 - 1;
    i1 = max( i1, i1pml );
    i2 = min( i2, i2pml - 1 );
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    s2(j,k,l) = dfnc( op, s1, x, dx, 1, id, j, k, l );
  end
  op = operator(1);
  i1 = nhalo + [ 1 1 1 ];
  i2 = nhalo + np - 1;
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  for i = 1:npml
    if id ~= 1 && bc(1), ji = i1(1) + i - 1;
      s2(ji,k,l) = dfnc( op, u, x, dx, ic, id, ji, k, l );
    end
    if id ~= 1 && bc(4), ji = i2(1) - i + 1;
      s2(ji,k,l) = dfnc( op, u, x, dx, ic, id, ji, k, l );
    end
    if id ~= 2 && bc(2), ki = i1(2) + i - 1;
      s2(j,ki,l) = dfnc( op, u, x, dx, ic, id, j, ki, l );
    end
    if id ~= 2 && bc(5), ki = i2(2) - i + 1;
      s2(j,ki,l) = dfnc( op, u, x, dx, ic, id, j, ki, l );
    end
    if id ~= 3 && bc(3), li = i1(3) + i - 1;
      s2(j,k,li) = dfnc( op, u, x, dx, ic, id, j, k, li );
    end
    if id ~= 3 && bc(6), li = i2(3) - i + 1;
      s2(j,k,li) = dfnc( op, u, x, dx, ic, id, j, k, li );
    end
  end
  for i = 1:npml
    if id == 1 && bc(1), ji = i1(1) + i - 1;
      s2(ji,k,l) = dfnc( op, v, x, dx, ic, id, ji, k, l );
      s2(ji,k,l) = dc2(i) * s2(ji,k,l) + dc1(i) * g1(i,k,l,ic);
      g1(i,k,l,ic) = s2(ji,k,l);
    end
    if id == 1 && bc(4), ji = i2(1) - i + 1;
      s2(ji,k,l) = dfnc( op, v, x, dx, ic, id, ji, k, l );
      s2(ji,k,l) = dc2(i) * s2(ji,k,l) + dc1(i) * g4(i,k,l,ic);
      g4(i,k,l,ic) = s2(ji,k,l);
    end
    if id == 2 && bc(2), ki = i1(2) + i - 1;
      s2(j,ki,l) = dfnc( op, v, x, dx, ic, id, j, ki, l );
      s2(j,ki,l) = dc2(i) * s2(j,ki,l) + dc1(i) * g2(j,i,l,ic);
      g2(j,i,l,ic) = s2(j,ki,l);
    end
    if id == 2 && bc(5), ki = i2(2) - i + 1;
      s2(j,ki,l) = dfnc( op, v, x, dx, ic, id, j, ki, l );
      s2(j,ki,l) = dc2(i) * s2(j,ki,l) + dc1(i) * g5(j,i,l,ic);
      g5(j,i,l,ic) = s2(j,ki,l);
    end
    if id == 3 && bc(3), li = i1(3) + i - 1;
      s2(j,k,li) = dfnc( op, v, x, dx, ic, id, j, k, li );
      s2(j,k,li) = dc2(i) * s2(j,k,li) + dc1(i) * g3(j,k,i,ic);
      g3(j,k,i,ic) = s2(j,k,li);
    end
    if id == 3 && bc(6), li = i2(3) - i + 1;
      s2(j,k,li) = dfnc( op, v, x, dx, ic, id, j, k, li );
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
% W = lam*trace(G)*I + miu*(G + G^T)
s1 = lam .* sum( w1, 4 );
for i = 1:3
  w1(:,:,:,i) = 2 * miu .* w1(:,:,:,i) + s1;
  w2(:,:,:,i) =     miu .* w2(:,:,:,i);
end

% Moment source
if msrcradius, momentsrc, end

% Magnitudes
s1 = sum( u .* u, 4 );
s2 = sum( w1 .* w1, 4 ) + 2 * sum( w2 .* w2, 4 );
[ umax, umaxi ] = max( s1(:) );
[ wmax, wmaxi ] = max( s2(:) );
umax = sqrt( umax );
wmax = sqrt( wmax );
if umax > dx / 10
  fprintf( 'Warning: u !<< dx\n' )
end

