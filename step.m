%------------------------------------------------------------------------------%
% STEP

while itstep

tic
itstep = itstep - 1;
it = it + 1;

% Moment source
if srcgeom, momentsrc, end

% Acceleration on the nodes
% regrid here possibly?
wt(1) = toc;
vv = vv + dt * ( viscosity(2) - viscosity(1) ) .* v;
ii = [ 1 6 5; 6 2 4; 5 4 3 ];

Y  = m(:,:,:,2) + 2 * m(:,:,:,3);
i  = Y ~= 0;
Y(i) = 1 ./ Y(i);
Y  = Y .* m(:,:,:,3) .* ( m(:,:,:,2) + m(:,:,:,3) );

for iz = 1:size( operator, 1 )
  i1 = opi1(iz,:);
  i2 = opi2(iz,:);
  j  = i1(1):i2(1);
  k  = i1(1):i2(2);
  l  = i1(1):i2(3);
  for i = 1:3
    switch operator{iz,1}
    case 'som'
      vv(j,k,l,i) = m(j,k,l,1) .* ...
        ( dcng( S, ii(i,1), x, 1, j, k, l ) ...
        + dcng( S, ii(i,2), x, 2, j, k, l ) ...
        + dcng( S, ii(i,3), x, 3, j, k, l ) ...
        + hgr( vv, h, Y, i, j, k, l ) );
    case 'rectangular'
      vv(j,k,l,i) = m(j,k,l,1) .* ...
        ( dcnr( S, ii(i,1), x, 1, j, k, l ) ...
        + dcnr( S, ii(i,2), x, 2, j, k, l ) ...
        + dcnr( S, ii(i,3), x, 3, j, k, l ) ...
        + hgr( vv, x, Y, i, j, k, l ) );
    case 'constant'
      vv(j,k,l,i) = m(j,k,l,1) .* ...
        ( dh( S, ii(i,1), 1, j-1, k-1, l-1 ) ...
        + dh( S, ii(i,2), 2, j-1, k-1, l-1 ) ...
        + dh( S, ii(i,3), 3, j-1, k-1, l-1 ) ...
        + hgr( vv, 1, Y, i, j, k, l ) );
    case 'staggered'
      i1 = opi1(iz,:) + 1;
      if staggerbc1, i2 = opi2(iz,:) - 2; i2(i) = i2(i) + 1; d = eye( 3 );
      else,          i2 = opi2(iz,:) - 1; i2(i) = i2(i) - 1; d = 1 - eye( 3 );
      end
      j  = i1(1):i2(1);
      k  = i1(1):i2(2);
      l  = i1(1):i2(3);
      vv(j,k,l,i) = m(j,k,l,1) .* ...
        ( dhs4( S, ii(i,1), 1, j-d(i,1), k,        l        ) ...
        + dhs4( S, ii(i,2), 2, j,        k-d(i,2), l        ) ...
        + dhs4( S, ii(i,3), 3, j,        k,        l-d(i,3) ) );
    end
  end
end
clear Y

% Fault calculations
wt(2) = toc;
if nrmdim, fault, end

% Update v, u, x
wt(3) = toc;
v = v + vv;
for iz = 1:size( locknodes, 1 )
  i  = locknodes(iz,1:3) == 1;
  i1 = locknodes(iz,4:2:8);
  i2 = locknodes(iz,5:2:9);
  j  = i1(1):i2(1);
  k  = i1(2):i2(2);
  l  = i1(3):i2(3);
  v(j,k,l,i) = 0;
end
u = u + dt * v;
%x = x + dt * x;

% Stress in the cells
wt(4) = toc;
vv = u + dt * viscosity(1) .* v;
for iz = 1:size( operator, 1 )
  i1 = opi1(iz,:);
  i2 = opi2(iz,:) - 1;
  j  = i1(1):i2(1);
  k  = i1(2):i2(2);
  l  = i1(3):i2(3);
  for a = 1:3
    b = mod( a,   3 ) + 1;
    c = mod( a+1, 3 ) + 1;
    switch operator{iz,1}
    case 'som'
      S(j,k,l,a) = ...
        dncg( vv, a, x, a, j, k, l );
      S(j,k,l,a+3) = m(j,k,l,3) .* ( ...
        dncg( vv, b, x, c, j, k, l ) + ...
        dncg( vv, c, x, b, j, k, l ) );
    case 'rectang'
      S(j,k,l,a) = ...
        dncr( vv, a, x, a, j, k, l );
      S(j,k,l,a+3) = m(j,k,l,3) .* ( ...
        dncr( vv, b, x, c, j, k, l ) + ...
        dncr( vv, c, x, b, j, k, l ) );
    case 'constant'
      S(j,k,l,a) = ...
        dh( vv, a, a, j, k, l );
      S(j,k,l,a+3) = m(j,k,l,3) .* ( ...
        dh( vv, b, c, j, k, l ) + ...
        dh( vv, c, b, j, k, l ) );
    case 'staggered'
      i1 = opi(iz,:) + 1;
      if staggerbc1, i2 = opi2(iz,:) - 1; i2(a) = i2(a) - 1; d = eye( 3 );
      else           i2 = opi2(iz,:) - 2; i2(a) = i2(a) + 1; d = zeros( 3 );
      end
      j  = i1(1):i2(1);
      k  = i1(1):i2(2);
      l  = i1(1):i2(3);
      S(j,k,l,a+3) = m(j,k,l,3) .* ( ...
        dhs4( vv, b, c, j-d(1,c), k-d(2,c), l-d(3,c) ) + ...
        dhs4( vv, c, b, j-d(1,b), k-d(2,b), l-d(3,b) ) );
      if staggerbc1, i2 = opi2(iz,:) - 2; d = zeros( 3 );
      else           i2 = opi2(iz,:) - 1; d = eye( 3 );
      end
      j  = i1(1):i2(1);
      k  = i1(1):i2(2);
      l  = i1(1):i2(3);
      S(j,k,l,a) = ...
        dhs4( vv, a, a, j-d(1,a), k-d(2,a), l-d(3,a) );
    end
  end
end
tmp = m(j,k,l,2) .* sum( S(j,k,l,1:3), 4 );
for i = 1:3
  S(j,k,l,i) = tmp + 2 * m(j,k,l,3) .* S(j,k,l,i);
end

% Data processing, viz, output
wt(5) = toc;
tmp = S .* S; tmp(:,:,:,4:6) = 2 * tmp(:,:,:,4:6);
tmp = sum( tmp, 4 );    Smax = sqrt( max( tmp(:) ) );
tmp = sum( u .* u, 4 ); umax = sqrt( max( tmp(:) ) );
tmp = sum( v .* v, 4 ); vmax = sqrt( max( tmp(:) ) );
if umax > h / 10
  disp( 'Warning: u !<< h' )
end
if truptol
  i = hypocenter;
  i(nrmdim) = 1;
  j1 = i1(1):i2(1);
  k1 = i1(2):i2(2);
  l1 = i1(3):i2(3);
  j = i(1);
  k = i(2);
  l = i(3);
  i = slipv > truptol;
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

disp( 'stopped' )

