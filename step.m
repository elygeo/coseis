%------------------------------------------------------------------------------%% STEP

if itstep < 1, itstep = 1; end

while itstep

tic
itstep = itstep - 1;
it = it + 1;

% Moment source
if msrcradius, momentsrc, end

% Restoring force, F = divS
wt(1) = toc;
c = [ 1 6 5; 6 2 4; 5 4 3 ];
s1(:) = 0;
for iii = 1:3
  for ii = [ iii:3 1:iii-1 ];
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
        end
      else
        i = 6 - iii - ii;
        switch operator{iz,1}
        case 'g', s1(j,k,l) = dcng( w2, i, x, ii, j, k, l );
        case 'r', s1(j,k,l) = dcnr( w2, i, x, ii, j, k, l );
        case 'h', s1(j,k,l) = dh(   w2, i,    ii, j-1, k-1, l-1 );
        end
      end
    end
    for i = 1:npml
      switch ii
      case 1
        if bc(1) == 1
          ji = j(i);
          f1(i,k,l,iii) = dampn1(i) * s1(ji,k,l) + dampn2(i) * f1(i,k,l,iii);
          s1(ji,k,l) = f1(i,k,l,iii);
        end
        if bc(4) == 1
          ji = j(end-i+1);
          f4(i,k,l,iii) = dampn1(i) * s1(ji,k,l) + dampn2(i) * f4(i,k,l,iii);
          s1(ji,k,l) = f4(i,k,l,iii);
        end
      case 2
        if bc(2) == 1
          ki = k(i);
          f2(j,i,l,iii) = dampn1(i) * s1(j,ki,l) + dampn2(i) * f2(j,i,l,iii);
          s1(j,ki,l) = f2(j,i,l,iii);
        end
        if bc(5) == 1
          ki = k(end-i+1);
          f5(j,i,l,iii) = dampn1(i) * s1(j,ki,l) + dampn2(i) * f5(j,i,l,iii);
          s1(j,ki,l) = f5(j,i,l,iii);
        end
      case 3
        if bc(3) == 1
          li = l(i);
          f3(j,k,i,iii) = dampn1(i) * s1(j,k,li) + dampn2(i) * f3(j,k,i,iii);
          s1(j,k,li) = f3(j,k,i,iii);
        end
        if bc(6) == 1
          li = l(end-i+1);
          f6(j,k,i,iii) = dampn1(i) * s1(j,k,li) + dampn2(i) * f6(j,k,i,iii);
          s1(j,k,li) = f6(j,k,i,iii);
        end
      end
    end
    if iii == ii,
      w1(:,:,:,iii) = s1;
    else
      w1(:,:,:,iii) = w1(:,:,:,iii) + s1;
    end
  end
end

% Hourglass correction
w2 = u + gamma(2) .* v;
s2(:,:,:) = 0;
for i = 1:3
  for iz = 1:size( operator, 1 )
    bc = [ operator{iz,2:7} ];
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    i1 = i1 + npml * bc(1:3);
    i2 = i2 - npml * bc(4:6);
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    switch operator{iz,1}
    case 'g', s2(j,k,l) = hgr( w2, h, y, i, j, k, l );
    case 'r', s2(j,k,l) = hgr( w2, x, y, i, j, k, l );
    case 'h', s2(j,k,l) = hgr( w2, 1, y, i, j, k, l );
    end
  end
  w1(:,:,:,i) = w1(:,:,:,i) + s2;
end

% Newton's Law, dV = F/m * dt
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) .* rho;
end

% Fault calculations
wt(2) = toc;
if nrmdim, fault, end

% Velocity, V = V + dV
wt(3) = toc;
v = v + w1;
for iz = 1:size( locknodes, 1 )
  i1 = locki(1,:,iz);
  i2 = locki(2,:,iz);
  i = locknodes(iz,1:3) == 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  v(j,k,l,i) = 0;
end

% Displacement
u = u + dt * v;
%x = x + dt * x;

% Modified strain, E = gradU + dt*beta*gradV
wt(4) = toc;
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
      l = i1(3):i2(3)-1;
      k = i1(2):i2(2)-1;
      j = i1(1):i2(1)-1;
      switch operator{iz,1}
      case 'g', s2(j,k,l) = dncg( s1, 1, x, ii, j, k, l );
      case 'r', s2(j,k,l) = dncr( s1, 1, x, ii, j, k, l );
      case 'h', s2(j,k,l) = dh(   s1, 1,    ii, j, k, l );
      end
    end
    for i = 1:npml-1
      switch ii
      case 1
        if bc(1) == 1
          ji = j(i);
          e1(i,k,l,iii) = dampc1(i) * s2(ji,k,l) + dampc2(i) * e1(i,k,l,iii);
          s2(ji,k,l) = e1(i,k,l,iii);
        end
        if bc(4) == 1
          ji = j(end-i+1);
          e4(i,k,l,iii) = dampc1(i) * s2(ji,k,l) + dampc2(i) * e4(i,k,l,iii);
          s2(ji,k,l) = e4(i,k,l,iii);
        end
      case 2
        if bc(2) == 1
          ki = k(i);
          e2(j,i,l,iii) = dampc1(i) * s2(j,ki,l) + dampc2(i) * e2(j,i,l,iii);
          s2(j,ki,l) = e2(j,i,l,iii);
        end
        if bc(5) == 1
          ki = k(end-i+1);
          e5(j,i,l,iii) = dampc1(i) * s2(j,ki,l) + dampc2(i) * e5(j,i,l,iii);
          s2(j,ki,l) = e5(j,i,l,iii);
        end
      case 3
        if bc(3) == 1
          li = l(i);
          e3(j,k,i,iii) = dampc1(i) * s2(j,k,li) + dampc2(i) * e3(j,k,i,iii);
          s2(j,k,li) = e3(j,k,i,iii);
        end
        if bc(6) == 1
          li = l(end-i+1);
          e6(j,k,i,iii) = dampc1(i) * s2(j,k,li) + dampc2(i) * e6(j,k,i,iii);
          s2(j,k,li) = e6(j,k,i,iii);
        end
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

% Hook's Law, linear stress/strain relation, S = c:E
s1 = lam .* sum( w1, 4 );
for i = 1:3
  w1(:,:,:,i) = 2 * miu .* w1(:,:,:,i) + s1;
  w2(:,:,:,i) = miu .* w2(:,:,:,i);
end

% Data processing, viz, output
wt(5) = toc;
s1 = sum( u .* u, 4 ); umax = sqrt( max( s1(:) ) );
s1 = sum( v .* v, 4 ); vmax = sqrt( max( s1(:) ) );
s2 = sum( w1 .* w1, 4 ) + 2 * sum( w2 .* w2, 4 );
wmax = sqrt( max( s2(:) ) );
if umax > h / 10
  disp( 'Warning: u !<< h' )
end
if nrmdim & truptol
  i = hypocenter;
  i(nrmdim) = 1;
  l1 = i1(3):i2(3);
  k1 = i1(2):i2(2);
  j1 = i1(1):i2(1);
  l = i(3);
  k = i(2);
  j = i(1);
  i = vslip > truptol;
  if find( i )
    trup( i & ( ~ trup ) ) = it * dt;
    tarrest = ( it + 1 ) * dt;
    if i(j,k,l)
      tarresthypo = tarrest;
    end
  end
end
if plotstyle, viz, end
if length( out ), output, end
if exist( './pause', 'file' )
  disp( 'pause file found' )
  delete pause
  save
  itstep = 0;
end

% Timing
wt(6) = toc;
dwt = wt(2:end) - wt(1:end-1);
timing = [ it  dwt(2) dwt(1) + dwt(3) dwt(4:5) wt(end) ];
fprintf( 1, '%5d   %.2e %.2e %.2e %.2e %.2e\n', timing );

end

disp( 'paused' )

