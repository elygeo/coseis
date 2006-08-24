% Extract 4D slice from saved data
function [ msg, f ] = read4d( varargin )

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
meta
currentstep

% Slice
i = [ ihypo 1 ];
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
msg = '';
nout = length( out );
for iz = 1:nout
  nc    = out{iz}{1};
  field = out{iz}{2};
  dit   = out{iz}{3};
  i1    = [ out{iz}{4:6} ];
  i2    = [ out{iz}{7:9} ];
  test  = [ 
    strcmp( fieldin, field )
    all( i1s >= [ i1 1  ] )
    all( i2s <= [ i2 it ] )
    ( dit == 0 || dit == 1 || ( n(4) == 1 && mod( i1s(4), dit ) == 0 ) )
  ]';
  found = all( test );
  if found, break, end
end
if ~found
  msg = 'No saved data found for this region';
  msg = sprintf( 'No saved data for:   %s   %d %d %d %d   %d %d %d %d', fieldin, i1s, i2s );
  f = [];
  return
end

if nargout < 2, return, end

% Read data
file = sprintf( '%02d', iz );
cd( file )
if ic == 0
  ic = 1:nc;
end
m = i2 - i1 + 1;
n = [ n length( ic ) ];
f = zeros( n );
i0 = i1s - [ i1 1 ];
if all( m(1:3) == 1 )
  for i = 1:n(5)
    file = sprintf( '%s%1d', field, ic(i) );
    fid = fopen( file, 'r', endian );
    fseek( fid, 4*i0(4), 'bof' );
    f(1,1,1,:,i) = fread( fid, n(4), 'float32' );
    fclose( fid );
  end
else
  skip = 4 * ( m(1) - n(1) );
  block = sprintf( '%d*float32', n(1) );
  for i  = 1:n(5)
  for it = 1:n(4)
    if dit, file = sprintf( '%s%1d%06d', field, ic(i), it + i0(4) );
    else,   file = sprintf( '%s%1d', field, ic(i) );
    end
    fid = fopen( file, 'r', endian );
    for l = 1:n(3)
      seek = 4 * ( i0(1) + m(1) * ( i0(2) + m(2) * ( i0(3) + l - 1 ) ) );
      fseek( fid, seek, 'bof' );
      tmp = fread( fid, n(1)*n(2), block, skip );
      f(:,:,l,it,i) = reshape( tmp, n(1:2) );
    end
    fclose( fid );
  end
  end
end
cd '..'

