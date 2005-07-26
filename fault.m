%------------------------------------------------------------------------------%
% FAULT

if initialize

fprintf( 'Initialize fault\n' )
nf = nm;
nf(nrmdim) = 1;
fs     = repmat( 0, nf );
fd     = repmat( 0, nf );
dc     = repmat( 0, nf );
cohes  = repmat( 1e9, nf );
s0     = repmat( 0, [ nf 6 ] );
tt0nsd = repmat( 0, [ nf 3 ] );
uslip  = repmat( 0, nf );
vslip  = repmat( 0, nf );
trup   = repmat( 0, nf );
r      = repmat( 0, [ nf 3 ] );
str    = repmat( 0, [ nf 3 ] );
dip    = repmat( 0, [ nf 3 ] );
tt0    = repmat( 0, [ nf 3 ] );
for iz = 1:size( friction, 1 )
  zone = friction(iz,5:10);
  [ i1, i2 ] = zoneselect( zone, halo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  fs(j,k,l)    = friction(iz,1);
  fd(j,k,l)    = friction(iz,2);
  dc(j,k,l)    = friction(iz,3);
  cohes(j,k,l) = friction(iz,4);
end
for iz = 1:size( traction, 1 )
  zone = traction(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, halo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  tt0nsd(j,k,l,1) = traction(iz,1);
  tt0nsd(j,k,l,2) = traction(iz,2);
  tt0nsd(j,k,l,3) = traction(iz,3);
end
for iz = 1:size( stress, 1 )
  zone = stress(iz,7:12);
  [ i1, i2 ] = zoneselect( zone, halo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  s0(j,k,l,1) = stress(iz,1);
  s0(j,k,l,2) = stress(iz,2);
  s0(j,k,l,3) = stress(iz,3);
  s0(j,k,l,4) = stress(iz,4);
  s0(j,k,l,5) = stress(iz,5);
  s0(j,k,l,6) = stress(iz,6);
end
i1 = halo + [ 1 1 1 ];
i2 = halo + np;
i1(nrmdim) = 1;
i2(nrmdim) = 1;
j = i1(1):i2(1);
k = i1(2):i2(2);
l = i1(3):i2(3);
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1):i2(1);
k1 = i1(2):i2(2);
l1 = i1(3):i2(3);
nrm = snormals( x, j1, k1, l1 );
area = sum( nrm .* nrm, 4 );
area = sqrt( area );
tmp = area(j,k,l);
i = tmp ~= 0;
tmp(i) = 1 ./ tmp(i);
for i = 1:3
  nrm(j,k,l,i) = nrm(j,k,l,i) .* tmp;
end
if nrmdim ~= downdim
  dipdim = downdim;
  strdim = 6 - dipdim - nrmdim;
else
  strdim = mod( nrmdim, 3 ) + 1;
  dipdim = 6 - strdim - nrmdim;
end
down = [ 0 0 0 ];
down(downdim) = 1;
c = [ 0 1 -1; -1 0 1; 1 -1 0 ];
handed = c(nrmdim,strdim);
str(:,:,:,1) = down(2) .* nrm(:,:,:,3) - down(3) .* nrm(:,:,:,2);
str(:,:,:,2) = down(3) .* nrm(:,:,:,1) - down(1) .* nrm(:,:,:,3);
str(:,:,:,3) = down(1) .* nrm(:,:,:,2) - down(2) .* nrm(:,:,:,1);
tmp = sum( str(j,k,l,:) .* str(j,k,l,:), 4 );
tmp = sqrt( tmp );
i = tmp ~= 0;
tmp(i) = handed ./ tmp(i);
for i = 1:3
  str(j,k,l,i) = str(j,k,l,i) .* tmp;
end
dip(:,:,:,1) = nrm(2) .* str(:,:,:,3) - nrm(3) .* str(:,:,:,2);
dip(:,:,:,2) = nrm(3) .* str(:,:,:,1) - nrm(1) .* str(:,:,:,3);
dip(:,:,:,3) = nrm(1) .* str(:,:,:,2) - nrm(2) .* str(:,:,:,1);
tmp = sum( dip(j,k,l,:) .* dip(j,k,l,:), 4 );
tmp = sqrt( tmp );
i = tmp ~= 0;
tmp(i) = handed ./ tmp(i);
for i = 1:3
  dip(j,k,l,i) = dip(j,k,l,i) .* tmp;
end
c = [ 1 6 5; 6 2 4; 5 4 3 ];
for i = 1:3
  tt0(j,k,l,i) = ...
    s0(j,k,l,c(1,i)) .* nrm(j,k,l,1) + ...
    s0(j,k,l,c(2,i)) .* nrm(j,k,l,2) + ...
    s0(j,k,l,c(3,i)) .* nrm(j,k,l,3) + ...
    tt0nsd(j,k,l,nrmdim) .* nrm(j,k,l,i) + ...
    tt0nsd(j,k,l,strdim) .* str(j,k,l,i) + ...
    tt0nsd(j,k,l,dipdim) .* dip(j,k,l,i);
end
for i = 1:3
  r(j,k,l,i) = x(j1,k1,l1,i) - x(hypocenter(1),hypocenter(2),hypocenter(3),i);
end
r  = sum( r .* r, 4 );
r  = sqrt( r );
if nm(1) == 4, r = repmat( r(j,:,:), [ 4 1 1 ] ); end % 2D cases
if nm(2) == 4, r = repmat( r(:,k,:), [ 1 4 1 ] ); end % 2D cases
if nm(3) == 4, r = repmat( r(:,:,l), [ 1 1 4 ] ); end % 2D cases
i = hypocenter;
i(nrmdim) = 1;
j = i(1);
k = i(2);
l = i(3);
tn0 = sum( tt0(j,k,l,:) .* nrm(j,k,l,:) );
ts0 = norm( shiftdim( tt0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) );
tn0 = max( -tn0, 0 );
fs0 = fs(j,k,l);
fd0 = fd(j,k,l);
dc0 = dc(j,k,l);
strength = ( tn0 * fs0 - ts0 ) ./ ( ts0 - tn0 * fd0 );
dcr = 3 * dx * tn0 * ( fs0 - fd0 ) / miu0;
rcritr = miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2;
fprintf( 1, 'S: %g\n', strength )
fprintf( 1, 'dc: %g > %g\n', dc0, dcr )
fprintf( 1, 'rcrit: %g > %g\n', rcrit, rcritr )
return

end

%------------------------------------------------------------------------------%

%tt0 = 5;
%tw = 1;
%tt0(2,:,hypocenter(2)) = exp(-((it*dt-tt0)/tw)^2);
i1 = [ 1 1 1 ];
i2 = nm;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1):i2(1);
k1 = i1(2):i2(2);
l1 = i1(3):i2(3);
i1(nrmdim) = hypocenter(nrmdim) + 1;
i2(nrmdim) = hypocenter(nrmdim) + 1;
j2 = i1(1):i2(1);
k2 = i1(2):i2(2);
l2 = i1(3):i2(3);
% Zero slip velocity condition
tmp = area .* ( rho(j1,k1,l1) + rho(j2,k2,l2) );
i = tmp ~= 0;
tmp(i) = 1 ./ tmp(i);
for i = 1:3
  tt(:,:,:,i) = tt0(:,:,:,i) + ...
    tmp .* ( v(j2,k2,l2,i) - v(j1,k1,l1,i) + w1(j2,k2,l2,i) - w1(j1,k1,l1,i) );
end
tn = sum( tt .* nrm, 4 );
for i = 1:3
  tn3(:,:,:,i) = tn .* nrm(:,:,:,i);
end
ts3 = tt - tn3;
ts = sum( ts3 .* ts3, 4 );
ts = sqrt( ts );
if 0 % Fault opening
  for i = 1:3
    tt(:,:,:,i) = tt(:,:,:,i) + tmp .* ( u(j2,k2,l2,i) - u(j1,k1,l1,i) ) / dt;
  end
  tn = sum( tt .* nrm, 4 );
  i = tn > cohes(i);
  tn(i) = cohes(i);
  for i = 1:3
    tn3(:,:,:,i) = tn .* nrm(:,:,:,i);
  end
end
% Friction Law
cohes1 = cohes;
tn1 = -tn;
i = tn1 < 0;
tn1(i) = 0;
c = repmat( 1, size( dc ) );
i = uslip < dc;
c(i) = uslip(i) ./ dc(i);
ff = ( ( 1 - c ) .* fs + c .* fd ) .* tn1 + cohes1;
% Nucleation
if rcrit && vrup
  c = 1;
  if nclramp, c = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 ); end
  ff2 = ( 1 - c ) .* ts + c .* ( fd .* tn1 + cohes1 );
  i = r < min( rcrit, it * dt * vrup ) & ff2 < ff;
  ff(i) = ff2(i);
end
% Shear traction bounded by friction
c = repmat( 1, size( ff ) );
i = ts > ff;
if find( ff <= 0 ), fprintf( 'fault opening!\n' ), end
c(i) = ff(i) ./ ts(i);
for i = 1:3
  tt(:,:,:,i) = -tt0(:,:,:,i) + tn3(:,:,:,i) + c .* ts3(:,:,:,i);
  w1(j1,k1,l1,i) = w1(j1,k1,l1,i) + tt(:,:,:,i) .* area .* rho(j1,k1,l1);
  w1(j2,k2,l2,i) = w1(j2,k2,l2,i) - tt(:,:,:,i) .* area .* rho(j2,k2,l2);
end
vslip = v(j2,k2,l2,:) + w1(j2,k2,l2,:) - v(j1,k1,l1,:) - w1(j1,k1,l1,:);
vslip = sum( vslip .* vslip, 4 );
vslip = sqrt( vslip );

if truptol
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
    trup( i & ( ~ trup ) ) = ( it + .5 ) * dt;
    tarrest = ( it + 1.5 ) * dt;
    if i(j,k,l), tarresthypo = tarrest; end
  end
end

