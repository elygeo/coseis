%------------------------------------------------------------------------------%
% FAULT

if ~nrmdim; return; end

if initialize

fprintf( 'Initialize fault\n' )
nf = nm;
nf(nrmdim) = 1;
fs     = repmat( 0, nf );
fd     = repmat( 0, nf );
dc     = repmat( 0, nf );
cohes  = repmat( 1e9, nf );
w0     = repmat( 0, [ nf 6 ] );
tt0nsd = repmat( 0, [ nf 3 ] );
uslip  = repmat( 0, nf );
vslip  = repmat( 0, nf );
trup   = repmat( 0, nf );
r      = repmat( 0, [ nf 3 ] );
str    = repmat( 0, [ nf 3 ] );
dip    = repmat( 0, [ nf 3 ] );
tt0    = repmat( 0, [ nf 3 ] );
nrm    = repmat( 0, [ nf 3 ] );
str    = repmat( 0, [ nf 3 ] );
dip    = repmat( 0, [ nf 3 ] );
for iz = 1:size( friction, 1 )
  zone = friction(iz,5:10);
  [ i1, i2 ] = zoneselect( zone, nhalo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  fs(j1:j2,k1:k2,l1:l2)    = friction(iz,1);
  fd(j1:j2,k1:k2,l1:l2)    = friction(iz,2);
  dc(j1:j2,k1:k2,l1:l2)    = friction(iz,3);
  cohes(j1:j2,k1:k2,l1:l2) = friction(iz,4);
end
for iz = 1:size( traction, 1 )
  zone = traction(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, nhalo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  tt0nsd(j1:j2,k1:k2,l1:l2,1) = traction(iz,1);
  tt0nsd(j1:j2,k1:k2,l1:l2,2) = traction(iz,2);
  tt0nsd(j1:j2,k1:k2,l1:l2,3) = traction(iz,3);
end
for iz = 1:size( stress, 1 )
  zone = stress(iz,7:12);
  [ i1, i2 ] = zoneselect( zone, nhalo, np, hypocenter, nrmdim );
  i1 = max( i1, i1pml );
  i2 = min( i2, i2pml );
  i1(nrmdim) = 1;
  i2(nrmdim) = 1;
  j1 = i1(1); j2 = i2(1);
  k1 = i1(2); k2 = i2(2);
  l1 = i1(3); l2 = i2(3);
  w0(j1:j2,k1:k2,l1:l2,1) = stress(iz,1);
  w0(j1:j2,k1:k2,l1:l2,2) = stress(iz,2);
  w0(j1:j2,k1:k2,l1:l2,3) = stress(iz,3);
  w0(j1:j2,k1:k2,l1:l2,4) = stress(iz,4);
  w0(j1:j2,k1:k2,l1:l2,5) = stress(iz,5);
  w0(j1:j2,k1:k2,l1:l2,6) = stress(iz,6);
end
i1 = nhalo + [ 1 1 1 ];
i2 = nhalo + np;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
nrm(:,:,:,:) = snormals( x, i1, i2 );
area = sum( nrm .* nrm, 4 );
area = sqrt( area );
tmp = area;
tmp(tmp~=0) = 1 ./ tmp(tmp~=0);
for i = 1:3
  nrm(:,:,:,i) = nrm(:,:,:,i) .* tmp;
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
handed = mod( strdim - nrmdim + 1, 3 ) - 1;
str(:,:,:,1) = down(2) .* nrm(:,:,:,3) - down(3) .* nrm(:,:,:,2);
str(:,:,:,2) = down(3) .* nrm(:,:,:,1) - down(1) .* nrm(:,:,:,3);
str(:,:,:,3) = down(1) .* nrm(:,:,:,2) - down(2) .* nrm(:,:,:,1);
tmp = sum( str .* str, 4 );
tmp = sqrt( tmp );
tmp(tmp~=0) = handed ./ tmp(tmp~=0);
for i = 1:3
  str(:,:,:,i) = str(:,:,:,i) .* tmp;
end
dip(:,:,:,1) = nrm(:,:,:,2) .* str(:,:,:,3) - nrm(:,:,:,3) .* str(:,:,:,2);
dip(:,:,:,2) = nrm(:,:,:,3) .* str(:,:,:,1) - nrm(:,:,:,1) .* str(:,:,:,3);
dip(:,:,:,3) = nrm(:,:,:,1) .* str(:,:,:,2) - nrm(:,:,:,2) .* str(:,:,:,1);
tmp = sum( dip .* dip, 4 );
tmp = sqrt( tmp );
tmp(tmp~=0) = handed ./ tmp(tmp~=0);
for i = 1:3
  dip(:,:,:,i) = dip(:,:,:,i) .* tmp;
end
c = [ 1 6 5; 6 2 4; 5 4 3 ];
for i = 1:3
  tt0(:,:,:,i) = ...
    w0(:,:,:,c(1,i)) .* nrm(:,:,:,1) + ...
    w0(:,:,:,c(2,i)) .* nrm(:,:,:,2) + ...
    w0(:,:,:,c(3,i)) .* nrm(:,:,:,3) + ...
    tt0nsd(:,:,:,nrmdim) .* nrm(:,:,:,i) + ...
    tt0nsd(:,:,:,strdim) .* str(:,:,:,i) + ...
    tt0nsd(:,:,:,dipdim) .* dip(:,:,:,i);
end
for i = 1:3
  r(:,:,:,i) = x(j1,k1,l1,i) - hypoloc(i);
end
r = sum( r .* r, 4 );
r = sqrt( r );
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
strength = ( tn0 * fs0 - ts0 ) / ( ts0 - tn0 * fd0 );
dcr = 3 * dx * tn0 * ( fs0 - fd0 ) / miu0;
rcritr = miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2;
fprintf( 1, 'S: %g\n', strength )
fprintf( 1, 'dc: %g > %g\n', dc0, dcr )
fprintf( 1, 'rcrit: %g > %g\n', rcrit, rcritr )
uslipmax = 0;
vslipmax = 0;
tnmax = 0;
tsmax = 0;
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
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
i1(nrmdim) = hypocenter(nrmdim) + 1;
i2(nrmdim) = hypocenter(nrmdim) + 1;
j3 = i1(1); j4 = i2(1);
k3 = i1(2); k4 = i2(2);
l3 = i1(3); l4 = i2(3);
% Zero slip velocity condition
tmp = area .* ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) );
tmp(tmp~=0) = 1 ./ tmp(tmp~=0);
for i = 1:3
  tt(:,:,:,i) = tt0(:,:,:,i) + tmp .* ...
    ( v(j3:j4,k3:k4,l3:l4,i) + w1(j3:j4,k3:k4,l3:l4,i) ...
    - v(j1:j2,k1:k2,l1:l2,i) - w1(j1:j2,k1:k2,l1:l2,i) );
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
    tt(:,:,:,i) = tt(:,:,:,i) + tmp .* ...
    ( u(j3:j4,k3:k4,l3:l4,i) - u(j1:j2,k1:k2,l1:l2,i) ) / dt;
  end
  tn = sum( tt .* nrm, 4 );
  tn(tn>cohes) = cohes(tn>cohes);
  for i = 1:3
    tn3(:,:,:,i) = tn .* nrm(:,:,:,i);
  end
end
% Friction Law
cohes1 = cohes;
tn1 = -tn;
tn1(tn1<0) = 0;
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
  w1(j1:j2,k1:k2,l1:l2,i) = ...
  w1(j1:j2,k1:k2,l1:l2,i) + tt(:,:,:,i) .* area .* rho(j1:j2,k1:k2,l1:l2);
  w1(j3:j4,k3:k4,l3:l4,i) = ...
  w1(j3:j4,k3:k4,l3:l4,i) + tt(:,:,:,i) .* area .* rho(j3:j4,k3:k4,l3:l4);
end
tt = v(j3:j4,k3:k4,l3:l4,:) + w1(j3:j4,k3:k4,l3:l4,:) ...
   - v(j1:j2,k1:k2,l1:l2,:) - w1(j1:j2,k1:k2,l1:l2,:);
vslip = sum( tt .* tt, 4 );
vslip = sqrt( vslip );

uslip = uslip + dt * vslip;
uslipmax = max( abs( uslip(:) ) );
vslipmax = max( abs( vslip(:) ) );
tnmax = max( abs( tn(:) ) );
tsmax = max( abs( ts(:) ) );

if truptol
  i1 = hypocenter;
  i1(nrmdim) = 1;
  l = i1(3);
  k = i1(2);
  j = i1(1);
  i = vslip > truptol;
  if find( i )
    trup( i & ( ~ trup ) ) = ( it + .5 ) * dt;
    tarrest = ( it + 1.5 ) * dt;
    if i(j,k,l), tarresthypo = tarrest; end
  end
end

