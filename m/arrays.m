%------------------------------------------------------------------------------%
% ARRAYS

% 3D vectors
w1   = repmat( zero, [ nm 3 ] ); % temporary storage
w2   = w1;                       % temporary storage
x    = w1;                       % node locations
v    = w1;                       % **velocity
u    = w1;                       % **displacement

% 3D scalars
s1   = repmat( zero, nm );       % temporary storage
s2   = s1;                       % temporary storage
mr   = s1;                       % mass ratio
lam  = s1;                       % Lame parameter
mu   = s1;                       % Lame parameter
y    = s1;                       % hourglass constant

if ifn
  nf = nm;
  nf(ifn) = 1;
else
  nf = [ 0 0 0 ];
end

% Fault vetors
t1   = repmat( zero, [ nf 3 ] ); % temporary storage
t2   = t1;                       % temporary storage
t3   = t1;                       % temporary storage
nrm  = t1;                       % fault normal vector
t0   = t1;                       % initial traction

% Fault scalars
f1   = repmat( zero, nf );       % temporary storage
f2   = f1;                       % temporary storage
tn   = f1;                       % temporary storage
ts   = f1;                       % temporary storage
mus  = f1;                       % coef of static friction
mud  = f1;                       % coef of dynamic friction
dc   = f1;                       % slip weakening distance
co   = f1;                       % cohesion
area = f1;                       % fault element area
r    = f1;                       % radius to hypocenter
vs   = f1;                       % **slip velocity
us   = f1;                       % **slip
trup = f1;                       % **rupture time

i1 = [ 0 0 0 ];
i2 = [ 0 0 0 ];
i = bc1 == 1; i1(i) = npml;
i = bc2 == 1; i2(i) = npml;
nj1 = [ nm 3 ]; nj1(1) = i1(1);
nj2 = [ nm 3 ]; nj2(1) = i2(1);
nk1 = [ nm 3 ]; nk1(2) = i1(2);
nk2 = [ nm 3 ]; nk2(2) = i2(2);
nl1 = [ nm 3 ]; nl1(3) = i1(3);
nl2 = [ nm 3 ]; nl2(3) = i2(3);

% PML state
p1  = repmat( zero, nj1 );       % **j1 pml momentum
p2  = repmat( zero, nk1 );       % **k1 pml momentum
p3  = repmat( zero, nl1 );       % **l1 pml momentum
p4  = repmat( zero, nj2 );       % **j2 pml momentum
p5  = repmat( zero, nk2 );       % **k2 pml momentum
p6  = repmat( zero, nl2 );       % **l2 pml momentum
g1  = repmat( zero, nj1 );       % **j1 pml gradient
g2  = repmat( zero, nk1 );       % **k1 pml gradient
g3  = repmat( zero, nl1 );       % **l1 pml gradient
g4  = repmat( zero, nj2 );       % **j2 pml gradient
g5  = repmat( zero, nk2 );       % **k2 pml gradient
g6  = repmat( zero, nl2 );       % **l2 pml gradient

% Initial values
t = 0.;
amax  = 0.;
vmax  = 0.;
umax  = 0.;
wmax  = 0.;
vsmax = 0.;
usmax = 0.;
tnmax = 0.;
tsmax = 0.;

