% Read binary data

function f = readf32( varargin )

n = inf;
file = varargin{1};
if nargin > 1, n = varargin{2}; end

meta
fid = fopen( file, 'r', endian );
f = fread( fid, n, 'float32' );
fclose( fid );

