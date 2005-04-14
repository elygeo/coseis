%------------------------------------------------------------------------------%
% STEPV

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

% Newton's Law, dV = F/m * dt
for i = 1:3
  w1(:,:,:,i) = w1(:,:,:,i) .* rho;
end

% Hourglass correction
% TODO: have I done this correctly along the fault?
w2 = u + gamma(2) .* v;
s2(:,:,:) = 0;
for i = 1:3
  iz = 1;
  %for iz = 1:size( operator, 1 )
    bc = [ operator{iz,2:7} ];
    i1 = opi1(iz,:);
    i2 = opi2(iz,:);
    i1 = i1 + npml * bc(1:3);
    i2 = i2 - npml * bc(4:6);
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    s2(j,k,l) = hgr( w2, 1, y, i, j, k, l );
    %switch operator{iz,1}
    %case 'g', s2(j,k,l) = hgr( w2, h, y, i, j, k, l );
    %case 'r', s2(j,k,l) = hgr( w2, x, y, i, j, k, l );
    %case 'h', s2(j,k,l) = hgr( w2, 1, y, i, j, k, l );
    %otherwise error operator
    %end
  %end
  w1(:,:,:,i) = w1(:,:,:,i) + s2;
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

