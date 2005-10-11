% Setup

% Star-P
p = 1;

init = 1;
pass = 'v';
breakon = 'v';
gui = 1;
sordrunning = 1;
outdir = 'out/';
if get( 0, 'ScreenDepth' ) == 0; gui = 0; end
rand( 'state', 0 )

% Precision
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;

itstep = nt;
it = 0;
nhalo = 1;

% Hypocenter
n = nn
if ifn, n(ifn) = n(ifn) - 1; end
i = ihypo == 0;
ihypo(i) = floor( ( n(i) + 1 ) / 2 );

% PML region
i1pml = [ 0 0 0 ];
i2pml = nn + 1;
i = bc1 == 1; i1pml(i) = i1pml(i) + npml;
i = bc2 == 1; i2pml(i) = i2pml(i) - npml;
if any( i1pml <= i2pml ), error 'model too small for PML', end

% Map global indices to local memory indices
nnoff = nhalo * [ 1 1 1 ];
ihypo = ihypo + nnoff;
i1pml = i1pml + nnoff;
i2pml = i2pml + nnoff;

% Size of arrays
nm = nn * p + 2 * nhalo;

% Node region
i1node = nhalo + [ 1 1 1 ];
i2node = nhalo + nn;

% Cell region
i1cell = nhalo + [ 1 1 1 ];
i2cell = nhalo + nn - 1;

