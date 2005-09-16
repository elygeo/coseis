%------------------------------------------------------------------------------%
% TSREAD - read timeseries
% TODO check varname

clear vg tg
msg = '';

endian = textread( [ outdir 'endian' ], '%c', 1 );
hdr = textread( [ outdir sprintf( '%02d/hdr', iz ) ], '%n', 11 )';
nc = hdr(1);
i1 = hdr(2:4);
i2 = hdr(5:7);
interval = hdr(8);
ntg = hdr(9);
n = i2 - i1 + 1;
i = ixhair - noff - i1;
gnoff = 4 * sum( i .* cumprod( [ 1 n(1:2) ] ) );

if any( i < 0 | i >= n ) | interval ~= 1
  msg='no timeseries for this location'
  return
end

for itg = 1:ntg
tg(itg) = textread( [ outdir sprintf( 'stats/%06d', iz ) ], '%n', 1 )';
for i = 1:nc
  file = sprintf( [ outdir '%02d/%s%1d%06d' ], iz, field, i, itg );
  fid = fopen( file, 'r', endian );
  fseek( fid, gnoff, -1 );
  vg(itg,i) = fread( fid, 1, 'float32' );
  fclose( fid );
end
end

if ntg == 1, return, end

vg = [ zeros(1,ncomp); vg ];

switch field
case 'v', tg = [ 0; tg ];
otherwise tg = .5 * [ -tg(1); tg(1); tg(1:end-1) + tg(2:end) ];
end

