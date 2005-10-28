function snap( file )

print -dtiff -r240 'tmp'
img = imread( 'tmp.tif' );
n = [ 480 640 ];
img = imresize( img, n, 'bilinear' );
imwrite( img, file );
figure
imshow( img )

