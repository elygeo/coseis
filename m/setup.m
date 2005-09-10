%------------------------------------------------------------------------------%
% SETUP

% Star-P
p = 1;

readcheckpoint = 0;
pass = 'v';
breakon = 'v';
gui = 1;
if get( 0, 'ScreenDepth' ) == 0; gui = 0; end

% Precision
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;

% Setup indices
nn = n(1:3);
nt = n(4);
itstep = nt;
it = 0;
nhalo = 1;
offset = nhalo * [ 1 1 1 ];
i = hypocenter == 0;
hypocenter(i) = ceil( nn(i) / 2 );
hypocenter = hypocenter + offset;
if nrmdim, nn(nrmdim) = nn(nrmdim) + 1; end
nm = nn * p + 2 * nhalo;
i1node = nhalo + [ 1 1 1 ];
i2node = nhalo + nn;
i1cell = nhalo + [ 1 1 1 ];
i2cell = nhalo + nn - 1;
i1nodepml = i1node + bc(1:3) * npml; % FIXME
i2nodepml = i2node - bc(4:6) * npml; % FIXME
i1cellpml = i1cell + bc(1:3) * npml; % FIXME
i2cellpml = i2cell - bc(4:6) * npml; % FIXME

% 3D arrays
x   = repmat( zero, [ nm 3 ] );
u   = repmat( zero, [ nm 3 ] );
v   = repmat( zero, [ nm 3 ] );
w1  = repmat( zero, [ nm 3 ] );
w2  = repmat( zero, [ nm 3 ] );
s1  = repmat( zero, nm );
s2  = repmat( zero, nm );
rho = repmat( zero, nm );
lam = repmat( zero, nm );
mu  = repmat( zero, nm );
y   = repmat( zero, nm );
n = [ nm 3 ];
n(1) = npml * bc(1); p1 = repmat( zero, n ); g1 = repmat( zero, n );
n(1) = npml * bc(4); p4 = repmat( zero, n ); g4 = repmat( zero, n );
n = [ nm 3 ];
n(2) = npml * bc(2); p2 = repmat( zero, n ); g2 = repmat( zero, n );
n(2) = npml * bc(5); p5 = repmat( zero, n ); g5 = repmat( zero, n );
n = [ nm 3 ];
n(3) = npml * bc(3); p3 = repmat( zero, n ); g3 = repmat( zero, n );
n(3) = npml * bc(6); p6 = repmat( zero, n ); g6 = repmat( zero, n );

% Fault arrays
if nrmdim
  nf = nm;
  nf(nrmdim) = 1;
else
  nf = [0 0 0];
end
uslip = repmat( zero, nf );
vslip = repmat( zero, nf );
trup  = repmat( zero, nf );
fs    = repmat( zero, nf );
fd    = repmat( zero, nf );
dc    = repmat( zero, nf );
co    = repmat( zero, nf );
area  = repmat( zero, nf );
f1    = repmat( zero, nf );
f2    = repmat( zero, nf );
r     = repmat( zero, nf );
tn    = repmat( zero, nf );
ts    = repmat( zero, nf );
nrm   = repmat( zero, [ nf 3 ] );
t0    = repmat( zero, [ nf 3 ] );
t1    = repmat( zero, [ nf 3 ] );
t2    = repmat( zero, [ nf 3 ] );
t3    = repmat( zero, [ nf 3 ] );

% Initial values
amax = 0; iamax = 1;
vmax = 0; ivmax = 1;
umax = 0; iumax = 1;
wmax = 0; iwmax = 1;
uslipmax = 0;
vslipmax = 0;
tnmax = 0;
tsmax = 0;

