% Glyph vizualization

% Setup
if ~fscl, return, end
if volviz, i1glyph = i1volume; i2glyph = i2volume;
else,      i1glyph = i1slice;  i2glyph = i2slice;
end
minmag = glyphcut * fscl;
vfsave = vizfield;
mga = [];
vga = [];
xga = [];

% Loop over zones
for iz = 1:size( glyphs, 1 )

% Zone selectioin
[ i1z, i2z ] = zone( i1glyph(iz,:), i2glyph(iz,:), nn, nnoff, ihypo, ifn );
n = i2z - i1z + 1 - cellfocus;
ng = prod( n );

% Magnitude
vizfield = [ vfsave 'm' ];
i1s = [ i1z it ];
i2s = [ i2z - cellfocus it ];
ic = 1;
get4dsection
if msg, return, end
ii = find( gg >= minmag );
mg = gg(ii);

% Value
vizfield = vfsave;
i1s = [ i1z it ];
i2s = [ i2z - cellfocus it ];
ic = 0;
get4dsection
if msg, error( msg ), end
nc = size( gg, 2 );
clear vg
for i = 1:nc
  vg(:,i+1) = gg(ii+i*ng);
end

% Accumulate
switch nc
case 3
  mga = [ mga; mg ];
  vga = [ vga; vg ];
case 6
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  for iii = ii
    wg = vg(iii,:);
    [ vec, val ] = eig( wg(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    mga = [ mga; val' ];
    vga = [ vga; vec(:)' ];
  end
end

% Position
vizfield = 'x';
i1s = [ i1z 0 ];
i2s = [ i2z 0 ];
ic = 0;
get4dsection
if msg, error( msg ), end
xg = gg;

% Displacement distortion
if xscl > 0.
  vizfield = 'u';
  i1s = [ i1z it ];
  i2s = [ i2z it ];
  ic = 0;
  get4dsection
  if msg, error( msg ), end
  xg = xg + xscl * gg;
end

% Average at cell center
if cellfocus
  l = 1:n(1);
  k = 1:n(2);
  l = 1:n(3);
  gg = 0.125 * ( ...
    xg(j,k,l,:) + xg(j+1,k+1,l+1,:) + ...
    xg(j+1,k,l,:) + xg(j,k+1,l+1,:) + ...
    xg(j,k+1,l,:) + xg(j+1,k,l+1,:) + ...
    xg(j,k,l+1,:) + xg(j+1,k+1,l,:) );
end

% Accumulate
clear xg
for i = 0:2
  xg(:,i+1) = gg(ii+i*ng);
end
xga = [ xga; xg ];

% End loop
end

% Plot glyphs
if doglyph > 1
  reynoldsglyph
else
  wireglyph
end

