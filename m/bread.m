%------------------------------------------------------------------------------%
% BREAD

function s1 = bread( dir, var )

endian = textread( [ dir '/endian' ], '%c', 1 );
fid = fopen( [ dir '/' var ], 'r', endian );
s1 = fread( fid, inf, 'float32' );
fclose( fid );

