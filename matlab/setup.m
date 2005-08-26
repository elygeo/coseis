%------------------------------------------------------------------------------%
% Setup

nt = n(4);
it = 0;
itstep = nt;
readcheckpoint = 0;

np = n(1:3);
if ~hypocenter, hypocenter = ceil( np / 2 ); end
if nrmdim, np(nrmdim) = np(nrmdim) + 1; end
nhalo = 1;
nm = np + 2 * nhalo;
hypocenter = hypocenter + nhalo;
i1pml = nhalo + 1  + bc(1:3) * npml;
i2pml = nhalo + np - bc(4:6) * npml;

one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( nm ) );
fprintf( 'Base memory usage: %d Mb\n', mem )

if plotstyle; else gui = 0; end
if get( 0, 'ScreenDepth' ) == 0; gui = 0; end

tic
format short e
format compact

