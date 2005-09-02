%------------------------------------------------------------------------------%
% FAULT

if ~nrmdim; return; end

if init

init = 0;
fprintf( 'Initialize fault\n' )

% Orientations
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

% Allocate arrays
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

% Friction model
for iz = 1:size( friction, 1 )
  [ i1, i2 ] = zone( ifric(iz,:), nn, offset, hypocenter, nrmdim );
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

% Pretraction
for iz = 1:size( traction, 1 )
  [ i1, i2 ] = zone( itrac(iz,:), nn, offset, hypocenter, nrmdim );
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

% Prestress
for iz = 1:size( stress, 1 )
  [ i1, i2 ] = zone( istress(iz,:), nn, offset, hypocenter, nrmdim );
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

% Normal vectors
i1 = i1node;
i2 = i2node;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
nrm(:,:,:,:) = snormals( x, i1, i2 );
area = sqrt( sum( nrm .* nrm, 4 ) );
tmp = area;
ii = tmp ~= 0.;
tmp(ii) = 1 ./ tmp(ii);
for i = 1:3
  nrm(:,:,:,i) = nrm(:,:,:,i) .* tmp;
end

% Stike vectors
str(:,:,:,1) = down(2) .* nrm(:,:,:,3) - down(3) .* nrm(:,:,:,2);
str(:,:,:,2) = down(3) .* nrm(:,:,:,1) - down(1) .* nrm(:,:,:,3);
str(:,:,:,3) = down(1) .* nrm(:,:,:,2) - down(2) .* nrm(:,:,:,1);
tmp = sqrt( sum( str .* str, 4 ) );
ii = tmp ~= 0.;
tmp(ii) = handed ./ tmp(ii);
for i = 1:3
  str(:,:,:,i) = str(:,:,:,i) .* tmp;
end

% Dip vectors
dip(:,:,:,1) = nrm(:,:,:,2) .* str(:,:,:,3) - nrm(:,:,:,3) .* str(:,:,:,2);
dip(:,:,:,2) = nrm(:,:,:,3) .* str(:,:,:,1) - nrm(:,:,:,1) .* str(:,:,:,3);
dip(:,:,:,3) = nrm(:,:,:,1) .* str(:,:,:,2) - nrm(:,:,:,2) .* str(:,:,:,1);
tmp = sqrt( sum( dip .* dip, 4 ) );
ii = tmp ~= 0.;
tmp(ii) = handed ./ tmp(ii);
for i = 1:3
  dip(:,:,:,i) = dip(:,:,:,i) .* tmp;
end

% Total pretraction
for i = 1:3
  j = mod( i , 3 ) + 1;
  k = mod( i + 1, 3 ) + 1;
  tt0(:,:,:,i) = ...
    w0(:,:,:,i) .* nrm(:,:,:,i) + ...
    w0(:,:,:,j+3) .* nrm(:,:,:,k) + ...
    w0(:,:,:,k+3) .* nrm(:,:,:,j) + ...
    tt0nsd(:,:,:,nrmdim) .* nrm(:,:,:,i) + ...
    tt0nsd(:,:,:,strdim) .* str(:,:,:,i) + ...
    tt0nsd(:,:,:,dipdim) .* dip(:,:,:,i);
end

% Hypocentral radius
i1 = [ 1 1 1 ];
i2 = nm;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
for i = 1:3
  r(:,:,:,i) = x(j1:j2,k1:k2,l1:l2,i) - xhypo(i);
end
r = sqrt( sum( r .* r, 4 ) );

% Output some useful info
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

% Zero slip velocity boundary condition
tmp = dt * area .* ( rho(j1:j2,k1:k2,l1:l2) + rho(j3:j4,k3:k4,l3:l4) );
ii = tmp ~= 0.;
tmp(ii) = 1 ./ tmp(ii);
for i = 1:3
  tt(:,:,:,i) = tt0(:,:,:,i) + tmp .* ...
    ( v(j3:j4,k3:k4,l3:l4,i) + dt * w1(j3:j4,k3:k4,l3:l4,i) ...
    - v(j1:j2,k1:k2,l1:l2,i) - dt * w1(j1:j2,k1:k2,l1:l2,i) );
end

% Decompose traction to normal and sear components
tn = sum( tt .* nrm, 4 );
for i = 1:3
  tn3(:,:,:,i) = tn .* nrm(:,:,:,i);
end
ts3 = tt - tn3;
ts = sqrt( sum( ts3 .* ts3, 4 ) );

% Friction Law
cohes1 = cohes;
tn1 = -tn;
ii = tn1 < 0.;
tn1(ii) = 0.;
c = repmat( 1, size( dc ) );
i = uslip < dc;
c(i) = uslip(i) ./ dc(i);
ff = ( ( 1 - c ) .* fs + c .* fd ) .* tn1 + cohes1;

% Nucleation
if rcrit && vrup
  c = 1.;
  if nclramp, c = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1. ); end
  ff2 = ( 1. - c ) .* ts + c .* ( fd .* tn1 + cohes1 );
  i = r < min( rcrit, it * dt * vrup ) & ff2 < ff;
  ff(i) = ff2(i);
end

% Shear traction bounded by friction
c = repmat( 1, size( ff ) );
i = ts > ff;
c(i) = ff(i) ./ ts(i);
if find( ff <= 0 ), fprintf( 'fault opening!\n' ), end

% Update acceleration
for i = 1:3
  tt(:,:,:,i) = tn3(:,:,:,i) + c .* ts3(:,:,:,i) - tt0(:,:,:,i);
  w1(j1:j2,k1:k2,l1:l2,i) = ...
  w1(j1:j2,k1:k2,l1:l2,i) + tt(:,:,:,i) .* area .* rho(j1:j2,k1:k2,l1:l2);
  w1(j3:j4,k3:k4,l3:l4,i) = ...
  w1(j3:j4,k3:k4,l3:l4,i) + tt(:,:,:,i) .* area .* rho(j3:j4,k3:k4,l3:l4);
end

% Vslip
tt = v(j3:j4,k3:k4,l3:l4,:) + dt * w1(j3:j4,k3:k4,l3:l4,:) ...
   - v(j1:j2,k1:k2,l1:l2,:) - dt * w1(j1:j2,k1:k2,l1:l2,:);
vslip = sqrt( sum( tt .* tt, 4 ) );

vslipmax = max( abs( vslip(:) ) );
tnmax = max( abs( tn(:) ) );
tsmax = max( abs( ts(:) ) );

% Rupture time
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

