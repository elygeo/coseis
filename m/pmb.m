function h2 = pmb( varargin )

dim = -3;
h1 = varargin{1};
dx = varargin{2};
dy = varargin{3};
if nargin > 3, dim = varargin{4}; end

l = abs( dim );
j = mod( l, 3 ) + 1;
k = mod( l + 1, 3 ) + 1;

n = 16;
ii = 0;
for h = h1
  haxes = get( h, 'Parent' );
  for i = 1:n
    pos = get( h, 'Position' );
    phi = (i-1)/n*2*pi;
    pos(j) = pos(j) + dx * cos( phi );
    pos(k) = pos(k) + dy * sin( phi );
    pos(l) = pos(l) + sign( dim );
    ii = ii + 1;
    h2(ii) = copyobj( h, haxes );
    set( h2(ii), 'Position', pos );
  end
end
if nargout < 1, clear h2, end
