%------------------------------------------------------------------------------%
% Init

np = n(1:3);
nt = n(4);
clear n
if ~hypocenter, hypocenter = ceil( np / 2 ); end
if nrmdim, np(nrmdim) = np(nrmdim) + 1; end
nhalo = 1;
nm = np + 2 * nhalo;
hypocenter = hypocenter + nhalo;
i1pml = nhalo + 1  + bc(1:3) * npml;
i2pml = nhalo + np - bc(4:6) * npml;

readcheckpoint = 0;
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( nm ) );
fprintf( 'Base memory usage: %d Mb\n', mem )

if plotstyle; else gui = 0; end
if get( 0, 'ScreenDepth' ) == 0; gui = 0; end

it = 0;
itstep = nt;

umax = 0;
vmax = 0;
amax = 0;
wmax = 0;

initialize = 2;

tic

