function snap( varargin )

switch nargin
case 0, file = 'snap.png';
case 1, file = varargin{1};
otherwise, error
end

print -dtiff -r480 'tmp'

exit

print -dtiff -r240 'tmp'
img = imread( 'tmp.tif' );
n = [ 480 640 ];
img = imresize( img, n, 'bilinear' );
img([1 end],:,:) = 64;
img(:,[1 end],:) = 64;
imwrite( img, file );

