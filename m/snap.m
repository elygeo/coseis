% Window snapshot
function img1 = snap( varargin )
r1 = 3;
r2 = 3;
if nargin > 0, r1 = varargin{1}; r2 = r1; end
if nargin > 1, r2 = varargin{2}; end

set( gcf, 'PaperPositionMode', 'auto', 'Units', 'pixels' )
res = sprintf( '-r%d', r1 * get( 0, 'ScreenPixelsPerInch' ) );
print( '-dtiff', res, 'tmp' )
img1 = imread( 'tmp.tif' );
delete tmp.tif

pos = get( gcf, 'Position' );
r1 * pos([4 3])
size( img1 )

n1 = min( [ r1 * pos([4 3]) 3 ], size( img1 ) );
n2 = [ r1 / r2 * pos([4 3]) 3 ];

if r2 ~= 1
  %img1 = imresize( img1, n2(1:2), 'bilinear' );
  img2 = repmat( single(1), n2 );
  for j = 1:r2
  for k = 1:r2
    img2 = img2 + single( img1(j:r2:n1(1),k:r2:n1(2),:) );
  end
  end
  img1 = uint8( 1 / r2 / r2 * img2 );
  clear img2
end

if nargout == 0
  imwrite( img1, 'snap.png' );
  clear img1
end

