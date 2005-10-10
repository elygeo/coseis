% Extract 4D slice
% input: iz slice(5) vizfield

% Read metadata
run 'defaults'
run 'in'
run 'out/timestep'
run( sprintf( 'out/%02d/meta', iz ) )
msg = '';

% Time slice
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

% Component
ic = 1:nc
if sensor(5)
if find( sensor(5) == ic )
  ic

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
seek = 4 * i1(1) + ng(1) * ( i1(2) + ng(2) * i1(3) )
nl = i2 - i1 + 1;
i = min( find( ~i0 ) );
block = sprintf( '%d*float32', prod( nl(1:i) ) );
switch i0(2)
0) skip = 4 * ( ng(1) - nl(1) );
1) skip = 4 * ( ng(1) * ng(2) - nl(1) );
end
n = prod( nl );

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

