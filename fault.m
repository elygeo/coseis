%------------------------------------------------------------------------------%
% FAULT

if initialize

disp( 'Initialize fault' )
nf = n;
nf(nrmdim) = 1;
fcore = core;
fcore(2*nrmdim-1:2*nrmdim) = 1;
fs    = repmat( 0, nf );
fd    = repmat( 0, nf );
Dc    = repmat( 0, nf );
cohes = repmat( 0, nf );
S0    = repmat( 0, [ nf 6 ] );
T0nsd = repmat( 0, [ nf 3 ] );
for iz = 1:size( friction, 1 )
  [ i1, i2 ] = zoneselect( friction(iz,:), 4, fcore, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  fs(j,k,l)    = friction(iz,1);
  fd(j,k,l)    = friction(iz,2);
  Dc(j,k,l)    = friction(iz,3);
  cohes(j,k,l) = friction(iz,4);
end
for iz = 1:size( traction, 1 )
  [ i1, i2 ] = zoneselect( traction(iz,:), 3, fcore, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  T0nsd(j,k,l,1) = traction(iz,1);
  T0nsd(j,k,l,2) = traction(iz,2);
  T0nsd(j,k,l,3) = traction(iz,3);
end
for iz = 1:size( stress, 1 )
  [ i1, i2 ] = zoneselect( stress(iz,:), 6, fcore, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  S0(j,k,l,1) = stress(iz,1);
  S0(j,k,l,2) = stress(iz,2);
  S0(j,k,l,3) = stress(iz,3);
  S0(j,k,l,4) = stress(iz,4);
  S0(j,k,l,5) = stress(iz,5);
  S0(j,k,l,6) = stress(iz,6);
end
slip  = repmat( 0, nf );
trup  = repmat( 0, nf );
r     = repmat( 0, [ nf 3 ] );
str   = repmat( 0, [ nf 3 ] );
dip   = repmat( 0, [ nf 3 ] );
T0    = repmat( 0, [ nf 3 ] );
i1 = [ 2 2 2 ];
i2 = n - 1;
i1(nrmdim) = 1;
i2(nrmdim) = 1;
j  = i1(1):i2(1);
k  = i1(2):i2(2);
l  = i1(3):i2(3);
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
if strcmp( operator, 'constant' ), area = area ./ h ^ 2; end
for i = 1:3
  nrm(j,k,l,i) = nrm(j,k,l,i) .* tmp;
end
dipdim = downdim;
strdim = 6 - dipdim - nrmdim;
if nrmdim == dipdim
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
  T0(j,k,l,i) = ...
    S0(j,k,l,c(1,i)) .* nrm(j,k,l,1) + ...
    S0(j,k,l,c(2,i)) .* nrm(j,k,l,2) + ...
    S0(j,k,l,c(3,i)) .* nrm(j,k,l,3) + ...
    T0nsd(j,k,l,nrmdim) .* nrm(j,k,l,i) + ...
    T0nsd(j,k,l,strdim) .* str(j,k,l,i) + ...
    T0nsd(j,k,l,dipdim) .* dip(j,k,l,i);
end
for i = 1:3
  r(j,k,l,i) = x(j1,k1,l1,i) ...
    - x(hypocenter(1),hypocenter(2),hypocenter(3),i);
end
r  = sum( r .* r, 4 );
r  = sqrt( r );
if n(1) == 4, r = repmat( r(j,:,:), [ 4 1 1 ] ); end % 2D cases
if n(2) == 4, r = repmat( r(:,k,:), [ 1 4 1 ] ); end % 2D cases
if n(3) == 4, r = repmat( r(:,:,l), [ 1 1 4 ] ); end % 2D cases
i  = hypocenter;
i(nrmdim) = 1;
j  = i(1);
k  = i(2);
l  = i(3);
Tn0 = sum( T0(j,k,l,:) .* nrm(j,k,l,:) );
Ts0 = norm( shiftdim( T0(j,k,l,:) - Tn0 * nrm(j,k,l,:) ) );
Tn0 = max( -Tn0, 0 );
fs0 = fs(j,k,l);
fd0 = fd(j,k,l);
Dc0 = Dc(j,k,l);
strength = ( Tn0 * fs0 - Ts0 ) ./ ( Ts0 - Tn0 * fd0 );
DcR = 3 * h * Tn0 * ( fs0 - fd0 ) / miu0;
rcritR = miu0 * Tn0 * ( fs0 - fd0 ) * Dc0 / ( Ts0 - Tn0 * fd0 ) ^ 2;
fprintf( 1, 'S: %g\n', strength )
fprintf( 1, 'Dc: %g > %g\n', Dc0, DcR )
fprintf( 1, 'rcrit: %g > %g\n', rcrit, rcritR )
clear tmp fnc fac fan
return

end

%------------------------------------------------------------------------------%

%t0 = 5;
%tw = 1;
%T0(2,:,hypocenter(2)) = exp(-((it*dt-t0)/tw)^2);
i1     = [ 1 1 1 ];
i2     = n;
i1(nrmdim) = hypocenter(nrmdim);
i2(nrmdim) = hypocenter(nrmdim);
j1     = i1(1):i2(1);
k1     = i1(2):i2(2);
l1     = i1(3):i2(3);
i1(nrmdim) = hypocenter(nrmdim) + 1;
i2(nrmdim) = hypocenter(nrmdim) + 1;
j2     = i1(1):i2(1);
k2     = i1(2):i2(2);
l2     = i1(3):i2(3);
% Zero slip condition
tmp    = area .* ( mr(j1,k1,l1) + mr(j2,k2,l2) );
i      = tmp ~= 0;
tmp(i) = 1 ./ tmp(i);
T      = T0 + repmat( tmp, [ 1 1 1 3 ] ) .* ...
            (  v(j2,k2,l2,:) -  v(j1,k1,l1,:) ...
            + vv(j2,k2,l2,:) - vv(j1,k1,l1,:) );
Tn     = sum( T .* nrm, 4 );
Tn3    = repmat( Tn, [ 1 1 1 3 ] ) .* nrm;
Ts3    = T - Tn3;
Ts     = sum( Ts3 .* Ts3, 4 );
Ts     = sqrt( Ts );
if 0 % Fault opening
  T      = T + repmat( tmp, [ 1 1 1 3 ] ) .* ...
            (  u(j2,k2,l2,:) -  u(j1,k1,l1,:) ) / dt;
  Tn     = sum( T .* nrm, 4 );
  i      = Tn > cohes(i);
  Tn(i)  = cohes(i);
  Tn3    = repmat( Tn, [ 1 1 1 3 ] ) .* nrm;
end
% Friction Law
cohes1 = cohes;
Tn1    = -Tn;
i      = Tn1 < 0;
if( find( i ) )
  Tn1(i) = 0;
  disp( 'fault opening!' )
  %cohes1(i) = 0;  this is in DFM, but taken out to allow locking
end
c      = repmat( 1, size( Dc ) );
i      = slip < Dc;
c(i)   = slip(i) ./ Dc(i);
F      = ( ( 1 - c ) .* fs + c .* fd ) .* Tn1 + cohes1;
% Nucleation
if rcrit && vrup
  c    = 1;
  if nclramp
    c  = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 );
  end
  F2   = ( 1 - c ) .* Ts + c .* ( fd .* Tn1 + cohes1 );
  i    = r < min( rcrit, it * dt * vrup ) & F2 < F;
  F(i) = F2(i);
end
% Shear traction bounded by friction
c      = repmat( 1, size( F ) );
i      = Ts > F;
c(i)   = F(i) ./ Ts(i);
T      = -T0 + Tn3 + Ts3 .* repmat( c, [ 1 1 1 3 ] );
for i = 1:3
  vv(j1,k1,l1,i) = vv(j1,k1,l1,i) + T(:,:,:,i) .* area .* mr(j1,k1,l1);
  vv(j2,k2,l2,i) = vv(j2,k2,l2,i) - T(:,:,:,i) .* area .* mr(j2,k2,l2);
end
%vv(j2,k2,l2,:) = -vv(j1,k1,l1,:);
slipv = v(j2,k2,l2,:) + vv(j2,k2,l2,:) - v(j1,k1,l1,:) - vv(j1,k1,l1,:);
slipv = sum( slipv .* slipv, 4 );
slipv = sqrt( slipv );
slip  = slip + dt * slipv;
%clear tmp Tv Ti Tn Tn1 Tn3 Ts Ts3 cohes1 c F F2

