% Surface viz
function h = surfviz( varargin )

h = [];
f = [];
x = varargin{1};
n = size( x );
if sum( n > 1 ) < 3, return, end
color = nargin > 1;
if color
  f = varargin{2};
  nf = size( f );
  cell = all( n(1:3)-1 == nf );
  if any( n ~= nf + cell ), error 'bad size in surfviz', end
end

i = [
  1 2 3  4 2 6
  1 5 3  4 5 6
  1 2 3  4 5 3
  1 2 6  4 5 6
  1 2 3  1 5 6
  4 2 3  4 5 6
];
ii = [ 1 1 1 n ];
ii = unique( ii(i), 'rows' );

for iz = 1:size( ii, 1 )
  i1 = ii(iz,1:3);
  i2 = ii(iz,4:6);
  n = i2 - i1 + 1;
  if sum( n > 1 ) ~= 2, continue, end
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  x1 = squeeze( x(j,k,l,1) );
  x2 = squeeze( x(j,k,l,2) );
  x3 = squeeze( x(j,k,l,3) );
  if color
    if cell
      i2 = i2 - 1;
      if i1(i) == 1
        i2(i) = i2(i) + 1;
      else
        i1(i) = i1(i) - 1;
      end
      facecolor = 'flat';
    else
      facecolor = 'interp';
    end
    edgecolor = 'none';
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    s = squeeze( f(j,k,l) );
    h(end+1) = surf( x1, x2, x3, s );
  else
    facecolor = get( 1, 'Color' );
    edgecolor = get( 1, 'DefaultTextColor' );
    h(end+1) = surf( x1, x2, x3 );
  end
  hold on
end

set( h, ...
  'LineWidth', .1, ...
  'EdgeColor', edgecolor, ...
  'FaceColor', facecolor, ...
  'FaceAlpha', 1, ...
  'FaceLighting', 'none' );

if nargout == 0, clear h, end

