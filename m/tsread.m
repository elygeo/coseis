%------------------------------------------------------------------------------%
% TSREAD - read timeseries
% input: vizfield xhair iz
% output: tg vg

% Get metadata
meta = sprintf( 'out/%02d/meta', iz );
eval( meta )

% File offset
n = i2 - i1 + 1;
i = ixhair - i1;
skip = 4 * sum( i .* cumprod( [ 1 n(1:2) ] ) );

% Check if file holds desired data
msg = '';
if any( i < 0 | i >= n ) | dit > 1 | vizfield ~= field
  msg='Timeseries data not available for this location';
  return
end

% Read time series
clear vg tg
for itg = 1:itout
file = sprintf( 'out/stats/%06d', iz );
tg(itg) = textread( file, '%n', 1 )';
for i = 1:nc
  file = sprintf( 'out/%02d/%s%1d%06d', iz, field, i, itg );
  fid = fopen( file, 'r', endian );
  fseek( fid, skip, -1 );
  vg(itg,i) = fread( fid, 1, 'float32' );
  fclose( fid );
end
end

if itout == 1, return, end

% Add zero time sample
vg = [ zeros(1,nc); vg ];

% Time sequence
switch field
case 'v', tg = [ 0; tg ];
otherwise tg = .5 * [ -tg(1); tg(1); tg(1:end-1) + tg(2:end) ];
end

