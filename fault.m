%------------------------------------------------------------------------------%
% FAULT

if initialize

disp( 'Initialize fault' )
nf = n;
nf(nrmdim) = 1;
halo1f = halo1;
ncoref = ncore;
halo1f(nrmdim) = 1;
ncoref(nrmdim) = 1;
fs    = repmat( 0, nf );
fd    = repmat( 0, nf );
dc    = repmat( 0, nf );
cohes = repmat( 0, nf );
s0    = repmat( 0, [ nf 6 ] );
t0nsd = repmat( 0, [ nf 3 ] );
for iz = 1:size( friction, 1 )
  zone = friction(iz,5:10);
  [ i1, i2 ] = zoneselect( zone, halo1f, ncoref, hypocenter, nrmdim );
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
  [ i1, i2 ] = zoneselect( zone, halo1f, ncoref, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  t0nsd(j,k,l,1) = traction(iz,1);
  t0nsd(j,k,l,2) = traction(iz,2);
  t0nsd(j,k,l,3) = traction(iz,3);
end
for iz = 1:size( stress, 1 )
  zone = stress(iz,7:12);
  [ i1, i2 ] = zoneselect( zone, halo1f, ncoref, hypocenter, nrmdim );
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
uslip = repmat( 0, nf );
vslip = repmat( 0, nf );
trup  = repmat( 0, nf );
r     = repmat( 0, [ nf 3 ] );
str   = repmat( 0, [ nf 3 ] );
dip   = repmat( 0, [ nf 3 ] );
t0    = repmat( 0, [ nf 3 ] );
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
  t0(j,k,l,i) = ...
    s0(j,k,l,c(1,i)) .* nrm(j,k,l,1) + ...
    s0(j,k,l,c(2,i)) .* nrm(j,k,l,2) + ...
    s0(j,k,l,c(3,i)) .* nrm(j,k,l,3) + ...
    t0nsd(j,k,l,nrmdim) .* nrm(j,k,l,i) + ...
    t0nsd(j,k,l,strdim) .* str(j,k,l,i) + ...
    t0nsd(j,k,l,dipdim) .* dip(j,k,l,i);
end
for i = 1:3
  r(j,k,l,i) = x(j1,k1,l1,i) - x(hypocenter(1),hypocenter(2),hypocenter(3),i);
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
tn0 = sum( t0(j,k,l,:) .* nrm(j,k,l,:) );
ts0 = norm( shiftdim( t0(j,k,l,:) - tn0 * nrm(j,k,l,:) ) );
tn0 = max( -tn0, 0 );
fs0 = fs(j,k,l);
fd0 = fd(j,k,l);
dc0 = dc(j,k,l);
strength = ( tn0 * fs0 - ts0 ) ./ ( ts0 - tn0 * fd0 );
dcr = 3 * h * tn0 * ( fs0 - fd0 ) / miu0;
rcritr = miu0 * tn0 * ( fs0 - fd0 ) * dc0 / ( ts0 - tn0 * fd0 ) ^ 2;
fprintf( 1, 'S: %g\n', strength )
fprintf( 1, 'dc: %g > %g\n', dc0, dcr )
fprintf( 1, 'rcrit: %g > %g\n', rcrit, rcritr )
return

end

%------------------------------------------------------------------------------%

%t0 = 5;
%tw = 1;
%t0(2,:,hypocenter(2)) = exp(-((it*dt-t0)/tw)^2);
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
tmp    = area .* ( rho(j1,k1,l1) + rho(j2,k2,l2) );
i      = tmp ~= 0;
tmp(i) = 1 ./ tmp(i);
t      = t0 + repmat( tmp, [ 1 1 1 3 ] ) .* ...
            (  v(j2,k2,l2,:) -  v(j1,k1,l1,:) ...
            + w1(j2,k2,l2,:) - w1(j1,k1,l1,:) );
tn     = sum( t .* nrm, 4 );
tn3    = repmat( tn, [ 1 1 1 3 ] ) .* nrm;
ts3    = t - tn3;
ts     = sum( ts3 .* ts3, 4 );
ts     = sqrt( ts );
if 0 % Fault opening
  t      = t + repmat( tmp, [ 1 1 1 3 ] ) .* ...
            (  u(j2,k2,l2,:) -  u(j1,k1,l1,:) ) / dt;
  tn     = sum( t .* nrm, 4 );
  i      = tn > cohes(i);
  tn(i)  = cohes(i);
  tn3    = repmat( tn, [ 1 1 1 3 ] ) .* nrm;
end
% Friction Law
cohes1 = cohes;
tn1    = -tn;
i      = tn1 < 0;
if( find( i ) )
  tn1(i) = 0;
  disp( 'fault opening!' )
  %cohes1(i) = 0;  this is in DFM, but taken out to allow locking
end
c      = repmat( 1, size( dc ) );
i      = uslip < dc;
c(i)   = uslip(i) ./ dc(i);
ff     = ( ( 1 - c ) .* fs + c .* fd ) .* tn1 + cohes1;
% Nucleation
if rcrit && vrup
  c    = 1;
  if nclramp
    c  = min( ( it * dt - r / vrup ) / ( nclramp * dt ), 1 );
  end
  ff2  = ( 1 - c ) .* ts + c .* ( fd .* tn1 + cohes1 );
  i    = r < min( rcrit, it * dt * vrup ) & ff2 < ff;
  ff(i) = ff2(i);
end
% Shear traction bounded by friction
c      = repmat( 1, size( ff ) );
i      = ts > ff;
c(i)   = ff(i) ./ ts(i);
t      = -t0 + tn3 + ts3 .* repmat( c, [ 1 1 1 3 ] );
for i = 1:3
  w1(j1,k1,l1,i) = w1(j1,k1,l1,i) + t(:,:,:,i) .* area .* rho(j1,k1,l1);
  w1(j2,k2,l2,i) = w1(j2,k2,l2,i) - t(:,:,:,i) .* area .* rho(j2,k2,l2);
end
vslip = v(j2,k2,l2,:) + w1(j2,k2,l2,1:3) - v(j1,k1,l1,:) - w1(j1,k1,l1,1:3);
vslip = sum( vslip .* vslip, 4 );
vslip = sqrt( vslip );
uslip  = uslip + dt * vslip;

