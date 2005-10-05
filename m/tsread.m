%------------------------------------------------------------------------------%
% Read time series
% input: vizfield sensor iz
% output: tg vg

% Read metadata
eval( sprintf( 'out/%02d/meta', iz ) )

% File offset
n = i2 - i1 + 1;
i = sensor - i1;
seek = 4 * ( i(1) + n(1) * ( i(2) + n(2) * i(3) ) );

% Check if file holds desired data
msg = '';
if any( i < 0 | i >= n ) | dit > 1 | vizfield ~= field
  msg = 'Timeseries data not available for this location';
  return
end

% Read time series
clear vg tg
for itg = 1:itout
for i = 1:nc
  file = sprintf( 'out/%02d/%s%1d%06d', iz, field, i, itg );
  fid = fopen( file, 'r', endian );
  fseek( fid, seek, 'bof' );
  vg(itg,i) = fread( fid, 1, 'float32' );
  fclose( fid );
end
end

if itout == 1, return, end

tg = dt * ( 0:itout );

