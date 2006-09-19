% Window snapshot
function img = snap( varargin )
r1 = 3;
r2 = 1;
if nargin > 0, r1 = varargin{1}; r2 = 0; end
if nargin > 1, r2 = varargin{2}; end

res = sprintf( '-r%d', r1 * get( 0, 'ScreenPixelsPerInch' ) );
set( gcf, 'PaperPositionMode', 'auto', 'Units', 'pixels' )
pos = get( gcf, 'Position' );
print( '-dtiff', res, 'tmp' )
img = imread( 'tmp.tif' );
delete tmp.tif

if r2
  img = imresize( img, r2 * pos([4 3]), 'bilinear' );
end

if nargout == 0
  imwrite( img, 'snap.png' );
  clear img
end

