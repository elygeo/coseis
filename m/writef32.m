% Write binary data

function readf32( varargin )

f = varargin{1};
file = varargin{2};
[ c, m, endian ] = computer;
if nargin > 2, endian = varargin{3}; end

fid = fopen( file, 'w', endian );
if fid < 0
  disp( [ 'file not found: ' file ] )
  return
end
fwrite( fid, f, 'float32' );
fclose( fid );

