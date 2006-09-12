function snapb( varargin )

border = 256 * varargin{1};
switch nargin
case 1, file = 'snap.png';
case 2, file = varargin{2};
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
img([1 end],:,:) = border;
img(:,[1 end],:) = border;
imwrite( img, file );

