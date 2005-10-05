%------------------------------------------------------------------------------%
% Read 5D subsection
% input: iz i1s i2s vizfield

% Array slice
eval( sprintf( 'out/%02d/meta', iz ) )
i1g = [ i1 1 1 ];
i2g = [ i2 nt nc ];
i1s = i1s - i1g + 1;
i2s = i2s - i1g + 1;
ng = i2g - i1g + 1;
n  = i2s - i1s + 1;

% Check if file holds desired data
if any( i1s < 1 | i2s > ng ) | vizfield ~= field | ( n(4) > 1 & dit > 1 )
  msg = 'No data available for this location';
  return
else
  msg = '';
end

% Read data
vg = zeros( n );
block = sprintf( '%d*float32', n(1) );
skip = 4 * ( ng(1) - n(1) );
for i   = i1s(5):i2s(5)
for itg = i1s(4):i2s(4)
  file = sprintf( 'out/%02d/%s%1d%06d', iz, field, i, itg );
  fid = fopen( file, 'r', endian );
  for l = i1s(3):i2s(3)
    seek = 4 * ( i1s(1) - 1 + ng(1) * ( i1s(2) - 1 + ng(2) * ( l - 1 ) ) );
    fseek( fid, seek, 'bof' );
    vg(:,:,l,itg,i) = fread( fid, n(1)*n(2), block, skip, endian );
  end
  fclose( fid );
end
end

