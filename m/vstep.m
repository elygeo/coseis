%------------------------------------------------------------------------------%
% VSTEP

% Restoring force
% P' + DP = [del]S, F = 1.P'             PML region
% F = divS                               non PML region (D=0)
s2(:) = 0.;
for ic = 1:3
for id = [ ic:3 1:ic-1 ];
  ix = 6 - ic - id;
  for iz = 1:size( operator, 1 )
    [ i1, i2 ] = zone( ioper(iz,:), nn, offset, i0, inrm );
    op = operator(iz);
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    if ic == id
      s2(j,k,l) = dfcn( op, w1, x, dx, ic, id, j, k, l );
    else
      s2(j,k,l) = dfcn( op, w2, x, dx, ix, id, j, k, l );
    end
  end
  i1 = i1node;
  i2 = i2node;
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

% Hourglass correction
s1(:) = 0.;
s2(:) = 0.;
w2 = u + dt * viscosity(2) * v;
for ic = 1:3
for iq = 1:4
  i1 = i1cell;
  i2 = i2cell;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s1(j,k,l) = hgnc( w2, ic, iq, j, k, l );
  s1 = y .* s1;
  i1 = i1node;
  i2 = i2node;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  s2(j,k,l) = hgcn( s1, 1, iq, j, k, l );
  w1(:,:,:,ic) = w1(:,:,:,ic) - s2;
end
end

% Newton's Law, A = F / m
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) .* mr;
end

% Fault calculations
fault

% Locked nodes
for iz = 1:size( locknodes, 1 )
  [ i1, i2 ] = zone( ilock(iz,:), nn, offset, i0, inrm );
  i = locknodes(iz,:) == 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  w1(j,k,l,i) = 0;
end

% Update velocity
v = v + dt * w1;

% Magnitudes
s1 = sqrt( sum( w1 .* w1, 4 ) );
s2 = sqrt( sum( v .* v, 4 ) );
[ amax, iamax ] = max( s1(:) );
[ vmax, ivmax ] = max( s2(:) );
[ vsmax, ivsmax ] = max( abs( vs(:) ) );

