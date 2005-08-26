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
hypocenter(i) = ceil( np(i) / 2 )
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

tic
format short e
format compact

