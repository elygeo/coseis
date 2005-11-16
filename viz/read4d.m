% Extract 4D slice from saved data
%function [ f, msg ] = read4d( fieldin, i1s, i2s, ic )
function [ f, msg ] = read4d( varargin )

% Aguments
if ~any( nargin == [ 1 3 4 ] ), error, end
fieldin = varargin{1};
i1s =  [ 1 1 1 1 ];
i2s = -[ 1 1 1 1 ];
ic = 0;
if nargin > 1
  i1s = varargin{2};
  i2s = varargin{3};
end
if nargin > 3
  ic = varargin{4};
end

% Metadata
rehash
defaults
in
currentstep
meta

% Slice
i = [ ihypo 0 ];
n = [ nn it ];
shift = [ 0 0 0 0 ];
if faultnormal, shift( abs( faultnormal) ) = 1; end
m0 = i1s == 0 & i2s == 0;
m1 = i1s == 0 & i2s ~= 0;
m2 = i1s ~= 0 & i2s == 0;
m3 = i1s < 0;
m4 = i2s < 0;
i1s(m0) = i(m0);
i2s(m0) = i(m0) + shift(m0);
i1s(m1) = i(m1) + shift(m1);
i2s(m2) = i(m2);
i1s(m3) = i1s(m3) + n(m3) + 1;
i2s(m4) = i2s(m4) + n(m4) + 1;

% Look for file with desired data
n = i2s - i1s + 1;
found = 0;
for iz = 1:nout
  file = sprintf( '%02d', iz );
  cd( file )
  meta
  found = strcmp( fieldin, field ) && ...
          all( i1s >= [ i1 0  ] ) && ...
          all( i2s <= [ i2 it ] ) && ...
          ( dit == 1 || ( n(4) == 1 && any( i1s(4) == 0:dit:it ) ) );
  if found, break, end
  cd '..'
end
if found
  msg = '';
else
  msg = 'No saved data found for this region';
  f = [];
  return
end

% Read data
if ic == 0
  ic = 1:nc;
end
m = i2 - i1 + 1;
n = [ n length( ic ) ];
f = zeros( n );
i0 = i1s - [ i1 0 ];
skip = 4 * ( m(1) - n(1) );
block = sprintf( '%d*float32', n(1) );
for i  = 1:n(5)
for it = 1:n(4)
  file = sprintf( '%s%1d%06d', field, ic(i), it + i0(4) - 1 );
  fid = fopen( file, 'r', endian );
  for l = 1:n(3)
    seek = 4 * ( i0(1) + m(1) * ( i0(2) + m(2) * ( i0(3) + l - 1 ) ) );
    fseek( fid, seek, 'bof' );
    tmp = fread( fid, n(1)*n(2), block, skip, endian );
    f(:,:,l,it,i) = reshape( tmp, n(1:2) );
  end
  fclose( fid );
end
end
cd '..'

