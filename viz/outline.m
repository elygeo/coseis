% Outline viz

function h = outline( i1, i2, ifn, ihypo, rmax, grid, dx )

x1 = rmax * ( [ .15 0 0 0 0 ] );
x2 = rmax * ( [ 0 0 .15 0 0 ] );
x3 = rmax * ( [ 0 0 0 0 .15 ] );
h = plot3( x1, x2, x3 );
hold on

x1 = rmax * [ .17 0 0 ];
x2 = rmax * [ 0 .17 0 ];
x3 = rmax * [ 0 0 .17 ];
h(2:4) = text( x1, x2, x3, ['xyz']', 'Ver', 'middle' );
set( h, 'HandleVisibility', 'off' )

izones = [ i1(1:3) i2(1:3) ];
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
for iz = 1:size( izones, 1 )
  i = izones(iz,:);
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
  if strcmp( grid, 'constant' ) && 0
    x1 = [ x1; [ i1(1) - 1; i2(1) - 1 ] * dx; NaN ];
    x2 = [ x2; [ i1(2) - 1; i2(2) - 1 ] * dx; NaN ];
    x3 = [ x3; [ i1(3) - 1; i2(3) - 1 ] * dx; NaN ];
  else
    [ x msg ] = read4d( 'x', [ i1 1 ], [ i2 1 ] );
    if msg, continue, end
    x1 = [ x1; shiftdim( x(:,:,:,1,1) ); NaN ];
    x2 = [ x2; shiftdim( x(:,:,:,1,2) ); NaN ];
    x3 = [ x3; shiftdim( x(:,:,:,1,3) ); NaN ];
  end
end

if length( x1 )
  h(5) = plot3( x1, x2, x3 );
  set( h, 'HandleVisibility', 'off' )
end

