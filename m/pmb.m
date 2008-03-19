function h2 = pmb( varargin )

h1 = varargin{1};
x = xlim;
dx = ( x(2) - x(1) ) / 400;
dy = dx;
dim = -3;
if nargin > 1, dx  = varargin{2}; end
if nargin > 2, dy  = varargin{3}; end
if nargin > 3, dim = varargin{4}; end

l = mod( abs( dim ) + 2, 3 ) + 1;
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
