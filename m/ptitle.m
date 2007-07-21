% Add title inside the axes
function h = ptitle( varargin )
str = varargin{1};
side = 'l';
fact = .02;
if nargin > 1, side = varargin{2}; end
if nargin > 2, fact = varargin{3}; end
pos = get( gca, 'Position' ) .* get( gcf, 'Position' );
x = xlim;
y = ylim;
dx = fact * ( x(2) - x(1) );
dy = fact * ( y(2) - y(1) ) * pos(3) / pos(4);
x = x + [ dx -dx ];
y = y + [ dy -dy ];
if strcmp( get( gca, 'XDir' ), 'reverse' ), x = x([2 1]); end
if strcmp( get( gca, 'YDir' ), 'reverse' ), y = y([2 1]); end
switch side
case 'l', h = text( x(1), y(2), str, 'Hor', 'left' );
case 'r', h = text( x(2), y(2), str, 'Hor', 'right' );
case 'c', h = text( .5*sum(x), y(2), str, 'Hor', 'center' );
end
set( h, 'Ver', 'top', 'Clipping', 'off', 'HitTest', 'off' )
if nargout == 0, clear h, end
axis manual

