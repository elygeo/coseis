%------------------------------------------------------------------------------%
% ARRAYS

nm3 = [ nm 3 ];

i1 = [ 0 0 0 ];
i2 = [ 0 0 0 ];
i = bc(1:3) == 1; i1(i) = npml;
i = bc(4:6) == 1; i2(i) = npml;
nj1 = nm3; nj1(1) = i1(1);
nj2 = nm3; nj2(1) = i2(1);
nk1 = nm3; nk1(2) = i1(2);
nk2 = nm3; nk2(2) = i2(2);
nl1 = nm3; nl1(3) = i1(3);
nl2 = nm3; nl2(3) = i2(3);

if nrmdim
  nf = nm;
  nf(nrmdim) = 1;
else
  nf = [ 0 0 0 ];
end
nf3 = [ nf 3 ];

% 3D static variables
mr   = repmat( zero, nm );  % mass ratio
lm   = repmat( zero, nm );  % Lame parameter
mu   = repmat( zero, nm );  % Lame parameter
y    = repmat( zero, nm );  % hourglass constant
x    = repmat( zero, nm3 ); % node locations

% 3D simulation state
v    = repmat( zero, nm3 ); % velocity
u    = repmat( zero, nm3 ); % displacement

% 3D temporary stotage
w1   = repmat( zero, nm3 ); % stress, acceleration
w2   = repmat( zero, nm3 ); % stress
s1   = repmat( zero, nm );
s2   = repmat( zero, nm );

% PML state
p1   = repmat( zero, nj1 ); % PML momentum
p2   = repmat( zero, nk1 ); % PML momentum
p3   = repmat( zero, nl1 ); % PML momentum
p4   = repmat( zero, nj2 ); % PML momentum
p5   = repmat( zero, nk2 ); % PML momentum
p6   = repmat( zero, nl2 ); % PML momentum
g1   = repmat( zero, nj1 ); % PML gradient
g2   = repmat( zero, nk1 ); % PML gradient
g3   = repmat( zero, nl1 ); % PML gradient
g4   = repmat( zero, nj2 ); % PML gradient
g5   = repmat( zero, nk2 ); % PML gradient
g6   = repmat( zero, nl2 ); % PML gradient

% Fault static variables
fs   = repmat( zero, nf );  % coef of static friction
fd   = repmat( zero, nf );  % coef of dynamic friction
dc   = repmat( zero, nf );  % slip weakening distance
co   = repmat( zero, nf );  % cohesion
area = repmat( zero, nf );  % fault element area
r    = repmat( zero, nf );  % radius to hypocenter
nrm  = repmat( zero, nf3 ); % fault normal vectors
t0   = repmat( zero, nf3 ); % initial traction

% Fault simulation state
vs   = repmat( zero, nf );  % slip velocity
us   = repmat( zero, nf );  % slip
trup = repmat( zero, nf );  % rupture time

% Fault temporary storage
t1   = repmat( zero, nf3 ); % stress input, normal traction
t2   = repmat( zero, nf3 ); % stress input, shear traction
t3   = repmat( zero, nf3 ); % traction input, total traction
tn   = repmat( zero, nf );  % normal traction
ts   = repmat( zero, nf );  % shear traction
f1   = repmat( zero, nf );  % friction
f2   = repmat( zero, nf );  % friction

% Initial values
amax  = 0;
vmax  = 0;
umax  = 0;
wmax  = 0;
vsmax = 0;
usmax = 0;
tnmax = 0;
tsmax = 0;

