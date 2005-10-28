function snap( file )

print -dtiff -r72 'tmp'
img = imread( 'tmp.tif' );
img = imresize( img, m, 'bilinear' );
imwrite( img, [ file '.png' ], 'png' );
figure
imshow( img )

