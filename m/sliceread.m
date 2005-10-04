%------------------------------------------------------------------------------%
% Read 4D slice
% input: sensor(4) iz

% Read metadata
eval( 'defaults' )
eval( 'in' )
eval( 'out/timestep' )
eval( sprintf( 'out/%02d/meta', iz ) )

% Time slice
msg = '';
itg = dit:dit:it;
if sensor(4)
if find( sensor(4) == itg )
  itg = sensor(4)
else
  msg = 'no data';
  return
end
end
tg = dt * itg;

% Array slice
ng = i2 - i1 + 1;
i2 = sensor(1:3) - i1;
i1 = sensor(1:3) - i1;
i0 = ~sensor(1:3);
i1(i0) = 0;
i2(i0) = ng(i0) - 1;

% Check if file holds desired data
if any( i1 < 0 | i2 >= ng ) | vizfield ~= field
  msg = 'no data';
  return
end

% Offsets
nl = i2 - i1 + 1;
n = prod( nl );
i = min( find( ~i0 ) );
block = sprintf( '%d*float32', prod( nl(1:i) ) );
skip = 4 * Z
seek = 4 * i1(1) + ng(1) * ( i1(2) + ng(2) * i1(3) )

% Read data
vg = zeros( [ nl 1 nc ] );
for itg = itg
for i = 1:nc
  file = sprintf( 'out/%02d/%s%1d%06d', iz, field, i, it );
  fid = fopen( file, 'r', endian );
  fseek( fid, seek, 'bof' );
  vg(:,:,:,itg,i) = fread( fid, n, block, skip, endian );
  fclose( fid );
end
end

