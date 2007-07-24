% Extract 4D slice from SORD output

function [ f, izone ] = read4d( varargin )

meta
currentstep
f = [];
izone = 0;
if ( isnumeric( varargin{1} ) )
  izone = varargin{1};
  field = out{izone}{2};
else
  field = varargin{1};
  for i = 1:length( out )
  if strcmp( field, out{i}{2} )
    izone = i;
    break
  end
  end
end
if ~izone, return, end
nc  = out{izone}{1};
dit = out{izone}{3};
i1 = [ out{izone}{4:7} ];
i2 = [ out{izone}{8:11} ];
n = [ nn i1(4) + dit * floor( ( it - i1(4) ) / dit ) ];
i2(4) = min( i2(4), n(4) );
i3 = i1;
i4 = i2;
if dit == 0
  dit = 1;
  i1(4) = 0;
  i2(4) = 0;
end

switch nargin
case 1
  if any( i3(1:3) ~= i4(1:3) )
    i3(4) = i4(4);
  end
case 2
  if ( length( varargin{2} ) == 1 )
    i3(4) = varargin{2};
    i4(4) = varargin{2};
  else
    ii = varargin{2};
    m1 = ii > 0;
    m2 = ii < 0;
    i3(m1) = ii(m1);
    i4(m1) = ii(m1);
    i3(m2) = ii(m2) + n(m2) + 1;
    i4(m2) = ii(m2) + n(m2) + 1;
  end
case 3
  i3 = varargin{2};
  i4 = varargin{3};
  shift = [ 0 0 0 0 ];
  if faultnormal
    shift( abs( faultnormal) ) = 1;
  end
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
otherwise, error
end

if any( i3 > i4 | i3 < i1 | i4 > i2 ) || mod( i3(4) - i1(4), dit ) ~= 0 
  disp( [ 'no data found for ' field ] )
  return
end

% Read data
di = [ 1 1 1 dit ];
i0 = ( i3 - i1 ) ./ di;
m = ( i2 - i1 ) ./ di + 1;
n = ( i4 - i3 ) ./ di + 1;
i = [ find( m~=1 ) find( m==1 ) ];
i0 = i0(i);
m = m(i);
n = n(i);
n = [ n nc ];
f = zeros( n );
skip = 4 * ( m(1) - n(1) );
block = sprintf( '%d*float32', n(1) );
for l = 1:nc
  file = field;
  if dirfmt, file = sprintf( [ dirfmt field ], izone ); end
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
n = ( i4 - i3 ) ./ di + 1;
if all( n(1:3) == 1 ), n = n(4); end
f = reshape( f, [ n nc ] );

