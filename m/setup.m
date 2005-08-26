%------------------------------------------------------------------------------%
% Setup

nt = n(4);
it = 0;
itstep = nt;
readcheckpoint = 0;

nhalo = 1;
offset = nhalo * [ 1 1 1 ];
np = n(1:3);
i = hypocenter == 0;
hypocenter(i) = ceil( np(i) / 2 );
hypocenter = hypocenter + offset;
if nrmdim, np(nrmdim) = np(nrmdim) + 1; end
nm = np + 2 * nhalo;
i1pml = nhalo + 1  + bc(1:3) * npml;
i2pml = nhalo + np - bc(4:6) * npml;

nl = np;
i1node = nhalo + 1;
i2node = nhalo + nl;
i1cell = nhalo + 1;
i2cell = nhalo + nl - 1;
i1nodepml = i1node + bc(1:3) * npml;
i2nodepml = i2node - bc(4:6) * npml;
i1cellpml = i1cell + bc(1:3) * npml;
i2cellpml = i2cell - bc(4:6) * npml;

one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( nm ) );
fprintf( 'Base memory usage: %d Mb\n', mem )

if plotstyle; else gui = 0; end
if get( 0, 'ScreenDepth' ) == 0; gui = 0; end

% Allocate arrays - single or double precision arrays depending on 'zero'.
n = [ nm 3 ];
x   = repmat( zero, n );
u   = repmat( zero, n );
v   = repmat( zero, n );
w1  = repmat( zero, n );
w2  = repmat( zero, n );
rho = repmat( zero, nm );
miu = repmat( zero, nm );
lam = repmat( zero, nm );
yc  = repmat( zero, nm );
yn  = repmat( zero, nm );
n = [ nm 3 ];
n(1) = npml * bc(1); p1 = repmat( zero, n ); g1 = repmat( zero, n );
n(1) = npml * bc(4); p4 = repmat( zero, n ); g4 = repmat( zero, n );
n = [ nm 3 ];
n(2) = npml * bc(2); p2 = repmat( zero, n ); g2 = repmat( zero, n )
n(2) = npml * bc(5); p5 = repmat( zero, n ); g5 = repmat( zero, n )
n = [ nm 3 ];
n(3) = npml * bc(3); p3 = repmat( zero, n ); g3 = repmat( zero, n )
n(3) = npml * bc(6); p6 = repmat( zero, n ); g6 = repmat( zero, n )
clear n

tic
format short e
format compact

