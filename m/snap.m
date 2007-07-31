% Window snapshot

function img1 = snap( varargin )
file = 'snap.png'; if nargin > 0, file = varargin{1}; end
r1 = 3;            if nargin > 1, r1   = varargin{2}; end
r2 = r1;           if nargin > 2, r2   = varargin{3}; end

res = sprintf( '-r%d', r1 * 72 );
print( '-dtiff', res, 'tmp' )
img1 = single( imread( 'tmp.tif' ) );
delete tmp.tif
n1 = size( img1 );
n2 = floor( n1 ./ r2 );

if any( n2 ~= n1 )
  img2 = repmat( single(0), [ n2(1:2) 3 ] );
  o = round( .5 * ( n1 - r2 * n2 ) );
  for j = 1:r2
  for k = 1:r2
    img2 = img2 + img1(o(1)+j:r2:n1(1),k:o(2)+r2:n1(2),:);
  end
  end
  img1 = img2 ./ ( r2 * r2 );
  clear img2
end

if file
  imwrite( uint8( img1 ), file )
end

if nargout == 0
  clear img1
end

