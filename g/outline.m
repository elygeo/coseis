% Outline viz

function h = outline( nn, ifn, ihypo, rmax )

izones = [ 1 1 1 nn ];
if ifn
  izones = [ izones; izones ];
  izones(2,[0 3]+ifn) = ihypo(ifn);
end

ii = [
  1 2 3  4 2 3
  1 5 3  4 5 3
  1 2 6  4 2 6
  1 5 6  4 5 6
  1 2 3  1 5 3
  1 2 6  1 5 6
  4 2 3  4 5 3
  4 2 6  4 5 6
  1 2 3  1 2 6
  4 2 3  4 2 6
  1 5 3  1 5 6
  4 5 3  4 5 6
];

ilines = [];
for iz = 1:size( izone, 1 )
  i = izone(iz,:);
  ilines = [ ilines; i(ii) ];
end
ilines = unique( ilines, 'rows' );

x1 = [];
x2 = [];
x3 = [];

for iz = 1:size( ilines, 1 )
  i1 = ilines(iz,1:3);
  i2 = ilines(iz,4:6);
  n = i2 - i1 + 1;
  if sum( n > 1 ) ~= 1, continue, end
  [ x, msg ] = read4d( 'x', [ i1 0 ], [ i2 0 ], 0 );
  x1 = [ x1; shiftdim( x(:,:,:,1,1) ); NaN ];
  x2 = [ x2; shiftdim( x(:,:,:,1,2) ); NaN ];
  x3 = [ x3; shiftdim( x(:,:,:,1,3) ); NaN ];
end

h = plot3( x1, x2, x3 );
hold on

x1 = x1(1) + rmax * ( [ .15 0 0 0 0 ] - .02 );
x2 = x2(1) + rmax * ( [ 0 0 .15 0 0 ] - .02 );
x3 = x3(1) + rmax * ( [ 0 0 0 0 .15 ] - .02 );
h(2) = plot3( x1, x2, x3 );

x1 = x1([1 3 5]) + rmax * [ .02 0 0 ];
x2 = x2([1 3 5]) + rmax * [ 0 .02 0 ];
x3 = x3([1 3 5]) + rmax * [ 0 0 .02 ];
h(3:5) = text( x1, x2, x3, ['xyz']', 'Ver', 'middle' );

set( h, 'HandleVisibility', 'off' )

