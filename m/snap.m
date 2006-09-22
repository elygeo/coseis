% Window snapshot
function img = snap( varargin )
r1 = 3;
r2 = 3;
if nargin > 0, r1 = varargin{1}; r2 = r1; end
if nargin > 1, r2 = varargin{2}; end

set( gcf, 'PaperPositionMode', 'auto', 'Units', 'pixels' )
pos = get( gcf, 'Position' );
n =  r1 / r2 * pos([4 3]) );

res = sprintf( '-r%d', r1 * get( 0, 'ScreenPixelsPerInch' ) );
print( '-dtiff', res, 'tmp' )
img = imread( 'tmp.tif' );
delete tmp.tif

if r2 ~= r1
  img2 = zeros( n );
  for j = 1:r2
  for k = 1:r2
    img2 = img2 + img(j:r2:end,k:r2:end);
  end
  end
  img = 1 / r2 / r2 * img2;
end

if nargout == 0
  imwrite( img, 'snap.png' );
  clear img
end

