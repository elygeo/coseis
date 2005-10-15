% Extract 4D slice from saved data
% input: vizfield i1s i2s ic outdir     nn it nout
% ouput: gg msg

% Array slice
gg = 0;
msg = '';
n = [ nn it ];
i = i1s < 0; i1s(i) = i1s(i) + n(i) + 1;
i = i2s < 0; i2s(i) = i2s(i) + n(i) + 1;

% Look for file with desired data
n = i2s - i1s + 1;
if all( n ~= 1 ), error 'trying to read 5 dimensions', end
if prod(n) > 1e8, error 'too big', end
if ~exist( 'outdir', 'var' ) , outdir = 'out'; end
cwd = pwd;
cd( outdir )
meta
found = 0;
for iz = 1:nout
  cd( sprintf( '%02d', iz ) )
  meta
  i1g = [ i1 0 ];
  i2g = [ i2 it ];
  found = strcmp( vizfield, field ) && ...
          all( i1s >= i1g ) && ...
          all( i2s <= i2g ) && ...
          ( dit == 1 || ( n(4) == 1 && find( i1s(4) == dit:dit:it ) ) );
  if found, break, end
  cd ..
end
if ~found
  cd( cwd )
  msg = 'No data available for this location';
  return
end

% Read data
gg = zeros( n );
ng = i2g - i1g + 1;
i0 = i1s - i1g;
block = sprintf( '%d*float32', n(1) );
skip = 4 * ( ng(1) - n(1) );
if ic == 0, ic = 1:nc; end
for i = 1:length( ic )
for itg = 1:n(4)
  file = sprintf( '%s%1d%06d', field, ic(i), itg + i0(4) - 1 );
  fid = fopen( file, 'r', endian );
  for l = 1:n(3)
    seek = 4 * ( i0(1) + ng(1) * ( i0(2) + ng(2) * ( i0(3) + l - 1 ) ) );
    fseek( fid, seek, 'bof' );
    gg(:,:,l,itg,i) = fread( fid, n(1)*n(2), block, skip, endian );
  end
  fclose( fid );
end
end
cd( cwd )

