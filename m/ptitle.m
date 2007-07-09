% Add title inside the axes
function h = ptitle( varargin )
str = varargin{1};
side = 'l';
fact = .02;
if nargin > 1, side = varargin{2}; end
if nargin > 2, fact = varargin{3}; end
pos = get( gca, 'Position' );
x = xlim;
y = ylim;
dx = fact * ( x(2) - x(1) );
dy = fact * ( y(2) - y(1) ) * pos(3) / pos(4);
switch side
case 'l', h = text( x(1) + dx, y(2) - dy, str, 'Hor', 'left' );
case 'r', h = text( x(2) - dx, y(2) - dy, str, 'Hor', 'right' );
end
set( h, 'Ver', 'top', 'Clipping', 'off', 'HitTest', 'off' )
if nargout == 0, clear h, end
axis manual

