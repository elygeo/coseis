% Surface viz
function h = surfviz( x, f, ic, cellfocus, domesh, dosurf )

h = [];
n = size( x );
if sum( n > 1 ) < 3, return, end

i = [ 1 1 1 n ];
ii = [
  1 2 3  4 2 6
  1 5 3  4 5 6
  1 2 3  4 5 3
  1 2 6  4 5 6
  1 2 3  1 5 6
  4 2 3  4 5 6
];
ii = unique( i(ii), 'rows' );

for iz = 1:size( ii, 1 )
  i1 = ii(iz,1:3);
  i2 = ii(iz,4:6);
  n = i2 - i1 + 1;
  if sum( n > 1 ) ~= 2, continue, end
  i = find( n == 1 );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  x1 = squeeze( x(j,k,l,1) );
  x2 = squeeze( x(j,k,l,2) );
  x3 = squeeze( x(j,k,l,3) );
  if cellfocus && i1(i) == n(i)
    i1(i) = i1(i) - 1;
    i2(i) = i2(i) - 1;
  end
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  s = squeeze( f(j,k,l,ic) );
  if ~cellfocus
    s(1:end-1,1:end-1) = .25 * ( ...
      s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
      s(1:end-1,2:end)   + s(2:end,2:end) ); 
  end
  h(end+1) = surf( x1, x2, x3, s );
  hold on
end

if domesh, edgecolor = get( 1, 'DefaultTextColor' );
else       edgecolor = 'none';
end

if dosurf, facecolor = 'flat';
else       facecolor = 'none';
end

set( h, ...
  'Tag', 'surf', ...
  'LineWidth', .25, ...
  'EdgeColor', edgecolor, ...
  'FaceColor', facecolor, ...
  'FaceAlpha', 1, ...
  'FaceLighting', 'none' );

