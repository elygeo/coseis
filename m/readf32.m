% Read binary data

function f = readf32( varargin )

f = [];
n = inf;
file = varargin{1};
if nargin > 1, n = varargin{2}; end

meta
fid = fopen( file, 'r', endian );
if fid < 0
  disp( [ 'file not found: ' file ] )
  return
end
f = fread( fid, n, 'float32' );
fclose( fid );

