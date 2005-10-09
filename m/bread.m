function s1 = bread( filename, endian )

endian = textread( 'data/endian', '%c', 1 );
fid = fopen( [ 'data/' filename ], 'r', endian );
s1 = fread( fid, inf, 'float32' );
fclose( fid );

