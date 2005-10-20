% Outline viz

function handle = outlineviz( nn, rmax )

i = [ 1 1 1 nn ];
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
ii = unique( i(ii), 'rows' );
x1 = [];
x2 = [];
x3 = [];

for iz = 1:size( ii, 1 )
  i1 = ii(iz,1:3);
  i2 = ii(iz,4:6);
  n = i2 - i1 + 1;
  if sum( n > 1 ) ~= 1, continue, end
  [ x, msg ] = read4d( 'x', [ i1 0 ], [ i2 0 ], 0 );
  x1 = [ x1; shiftdim( x(:,:,:,1,1) ); NaN ];
  x2 = [ x2; shiftdim( x(:,:,:,1,2) ); NaN ];
  x3 = [ x3; shiftdim( x(:,:,:,1,3) ); NaN ];
end

handle = plot3( x1, x2, x3 );
hold on

x1 = x1(1) + rmax * ( [ .15 0 0 0 0 ] - .02 );
x2 = x2(1) + rmax * ( [ 0 0 .15 0 0 ] - .02 );
x3 = x3(1) + rmax * ( [ 0 0 0 0 .15 ] - .02 );
handle(2) = plot3( x1, x2, x3 );

x1 = x1([1 3 5]) + rmax * [ .02 0 0 ];
x2 = x2([1 3 5]) + rmax * [ 0 .02 0 ];
x3 = x3([1 3 5]) + rmax * [ 0 0 .02 ];
handle(3:5) = text( x1, x2, x3, ['xyz']', 'Ver', 'middle' );

set( handle, 'Tag', 'outline', 'HandleVisibility', 'off' )

