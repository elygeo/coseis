% Line viz

function handle = lineviz( x )

n = size( x );
i = [ 1 1 1 n ];
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

for i = 1:size( ii, 1 )
  i1 = ii(i,1:3);
  i2 = ii(i,4:6);
  n = i2 - i1 + 1;
  if sum( n > 1 ) ~= 1, continue, end
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  x1 = [ x1; shiftdim( x(j,k,l,1) ); NaN ];
  x2 = [ x2; shiftdim( x(j,k,l,2) ); NaN ];
  x3 = [ x3; shiftdim( x(j,k,l,3) ); NaN ];
end

handle = plot3( x1, x2, x3 );
hold on

