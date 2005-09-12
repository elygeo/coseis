%------------------------------------------------------------------------------%
% SETUP

% Star-P
p = 1;

pass = 'v';
breakon = 'v';
gui = 1;
outdir = 'out/';
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
if i1nodepml <= i2nodepml, else error 'model too small for PML', end

