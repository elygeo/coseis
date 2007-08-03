% Window snapshot

function img1 = snap( varargin )
file = 'snap.png'; if nargin > 0, file = varargin{1}; end
dpi = 100;         if nargin > 1, dpi  = varargin{2}; end
aa = 3;            if nargin > 2, aa   = varargin{3}; end

if dpi < 10, error( 'snap is changed' ), end

res = sprintf( '-r%d', dpi * aa );
print( '-dtiff', res, 'tmp' )
img1 = single( imread( 'tmp.tif' ) );
delete tmp.tif
n1 = size( img1 );
n2 = floor( n1 ./ aa );

if any( aa > 1 )
  img2 = repmat( single(0), [ n2(1:2) 3 ] );
  o = round( .5 * ( n1 - aa * n2 ) );
  for j = 1:aa
  for k = 1:aa
    img2 = img2 + img1(o(1)+j:aa:n1(1),o(2)+k:aa:n1(2),:);
  end
  end
  img1 = img2 ./ ( aa * aa );
  clear img2
end

if file
  imwrite( uint8( img1 ), file )
end

if nargout == 0
  clear img1
end

