% Window snapshot

function img1 = snap( varargin )
r1 = 3;
if nargin > 0, r1 = varargin{1}; end
r2 = r1;
if nargin > 1, r2 = varargin{2}; end

ppi = get( 0, 'ScreenPixelsPerInch' );
pos = get( gcf, 'Position' );
set( gcf, 'PaperPositionMode', 'auto', 'Units', 'pixels' )
res = sprintf( '-r%d', r1 * ppi );
print( '-dtiff', res, 'tmp' )
img1 = imread( 'tmp.tif' );
delete tmp.tif
n0 = [ size( img1, 1 ) size( img1, 2 ) ];
n2 = floor( r1 / r2 * pos([4 3]) );
n1 = r2 * n2;
if any( n0 < n1 )
  n0
  n1
  error 'bad image size'
end

if any( n2 ~= n0 )
  img2 = repmat( single(0), [ n2 3 ] );
  o1 = round( .5 * ( n0(1) - n1(1) ) );
  o2 = round( .5 * ( n0(2) - n1(2) ) );
  for j = 1:r2
  for k = 1:r2
    img2 = img2 + single( img1(o1+j:r2:o1+n1(1),o2+k:r2:o2+n1(2),:) );
  end
  end
  img1 = uint8( 1 / ( r2 * r2 ) * img2 );
  clear img2
end

if nargout == 0
  imwrite( img1, 'snap.png' );
  clear img1
end

