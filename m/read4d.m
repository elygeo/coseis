% Extract 4D slice from saved data

function [ f, i3, i4 ] = read4d( varargin )

meta
f = [];
i3 = [];
i4 = [];
iz = varargin{1};
if ( ischar( iz ) )
  field = iz;
  for iz = 1:length( out )
    found = strcmp( field, out{iz}{2} );
    if found, break, end
  end
  if ~found, return, end
end
n = [ nn nt ];
nc    = out{iz}{1};
field = out{iz}{2};
dit   = out{iz}{3};
i1 = [ out{iz}{4:7}  ];
i2 = [ out{iz}{8:11} ];

switch nargin
case 1
  i3 = i1;
  i4 = i2;
  if any( i3(1:3) ~= i4(1:3) ), i3(4) = i4(4); end
case 2
  i3 = varargin{2};
  i4 = varargin{2};
  i = i3 == 0;
  i3(i) = i1(i);
  i4(i) = i2(i);
case 3
  i3 = varargin{2};
  i4 = varargin{3};
  shift = [ 0 0 0 0 ];
  if faultnormal, shift( abs( faultnormal) ) = 1; end
  m0 = i3(1:3) == 0 & i4(1:3) == 0;
  m1 = i3(1:3) == 0 & i4(1:3) ~= 0;
  m2 = i3(1:3) ~= 0 & i4(1:3) == 0;
  m3 = i3 < 0;
  m4 = i4 < 0;
  i3(m0) = ihypo(m0);
  i4(m0) = ihypo(m0);
  i3(m1) = ihypo(m1) + shift(m1);
  i4(m2) = ihypo(m2);
  i3(m3) = i3(m3) + n(m3) + 1;
  i4(m4) = i4(m4) + n(m4) + 1;
  if any( i3 < i1 || i4 > i2 ), error, end
otherwise, error
end

% Read data
i0 = ( i3 - i1 ) ./ [ 1 1 1 dit ];
m = i2 - i1 + 1;
n = i4 - i3 + 1;
i = [ find( m~=1 ) find( m==1 ) ];
i0 = i0(i);
m = m(i);
n = n(i);
n = [ n nc ];
f = zeros( n );
skip = 4 * ( m(1) - n(1) );
block = sprintf( '%d*float32', n(1) );
for l = 1:nc
  if dirfmt, file = sprintf( [ dirfmt field ], iz ); end
  if nc > 1, file = sprintf( [ file '%1d' ], l ); end
  fid = fopen( file, 'r', endian );
  if ( fid == -1 ), error( [ 'Error opening file: ' file ] ), end
  for k = 1:n(4)
  for j = 1:n(3)
    seek = 4 * ( i0(1) + m(1) * ( i0(2) + m(2) * ( i0(3) + j-1 + m(3) * ( i0(4) + k-1 ) ) ) );
    fseek( fid, seek, 'bof' );
    tmp = fread( fid, n(1)*n(2), block, skip );
    f(:,:,j,k,l) = reshape( tmp, n(1:2) );
  end
  end
  fclose( fid );
end
f = squeeze( f );

