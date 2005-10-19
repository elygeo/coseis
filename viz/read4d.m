% Extract 4D slice from saved data
function [ f, msg ] = read4d( fieldin, i1s, i2s, ic )

% Array slice
cwd = pwd;
cd 'out'
meta
timestep

% Look for file with desired data
n = i2s - i1s + 1;
found = 0;
fieldin
i1s
i2s
for iz = 1:nout
  file = sprintf( '%02d', iz );
  cd( file )
  meta
i1
i2
field
  found = strcmp( fieldin, field ) && ...
          all( i1s >= [ i1 0  ] ) && ...
          all( i2s <= [ i2 it ] ) && ...
          ( dit == 1 || ( n(4) == 1 && find( i1s(4) == dit:dit:it ) ) );
  if found, break, end
  cd ..
end
if found
  msg = '';
else
  msg = 'No saved data found for this region';
  f = 0;
  cd( cwd )
  return
end

% Read data
if ic == 0
  ic = 1:nc;
end
m = i2 - i1 + 1;
n = [ n length( ic ) ];
if prod(n) > 1e8, error 'too big', end
f = zeros( n );
i0 = i1s - [ i1 0 ];
skip = 4 * ( m(1) - n(1) );
block = sprintf( '%d*float32', n(1) );
for i  = 1:n(5)
for it = 1:n(4)
  file = sprintf( '%s%1d%06d', field, ic(i), it + i0(4) - 1 );
  fid = fopen( file, 'r', endian );
  for l = 1:n(3)
    seek = 4 * ( i0(1) + m(1) * ( i0(2) + m(2) * ( i0(3) + l - 1 ) ) );
    fseek( fid, seek, 'bof' );
    tmp = fread( fid, n(1)*n(2), block, skip, endian );
    f(:,:,l,it,i) = reshape( tmp, n(1:2) );
  end
  fclose( fid );
end
end
cd( cwd )

