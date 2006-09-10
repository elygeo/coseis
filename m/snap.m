function snap( varargin )

switch nargin
case 0, file = 'snap.png';
case 1, file = varargin{1};
otherwise, error
end

res = sprintf( '-r%d', 3 * get( 0, 'ScreenPixelsPerInch' ) );
set( gcf, 'PaperPositionMode', 'auto', 'Units', 'pixels' )
pos = get( gcf, 'Position' );
print( '-dtiff', res, 'tmp' )

img = imread( 'tmp.tif' );
delete tmp.tif
n = size( img );
img = imresize( img, pos([4 3]), 'bilinear' );
img([1 end],:,:) = 64;
img(:,[1 end],:) = 64;
imwrite( img, file );

