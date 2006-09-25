% Scale bar
function h = colorscale( varargin )

% arguments
units = '';
x = get( gca, 'XLim' );
y = get( gca, 'YLim' );
x = x(1) + [ .2 .8 ] * ( x(2) - x(1) );
y = y(1) - [ .2 .1 ] * ( y(2) - y(1) );
if nargin >= 1, units = varargin{1}; end
if nargin >= 2, x = varargin{2}; end
if nargin >= 3, y = varargin{3}; end
dx = x(2) - x(1);
dy = y(2) - y(1);

% color image
cmap = colormap;
clim = caxis;
folded = -clim(1) == clim(2) && all( cmap(1,:) == cmap(end,:) );
dc = ( clim(2) - clim(1) ) / ( length( cmap ) - 1 );
if folded, clim(1) = 0; end
imagesc( x, y(1) + [ 1 2 ] / 3 * dy, clim(1):dc:clim(2), 'Clipping', 'off' )

% text
h(1) = text( x(1) - .05 * dx, y(1) + .5 * dy, num2str(clim(1)), 'Hor', 'right' );
h(2) = text( x(2) + .05 * dx, y(1) + .5 * dy, [ num2str(clim(2)) units ], 'Hor', 'left' );
set( h, 'Ver', 'middle', 'Clipping', 'off' )
if nargout == 0, clear h, end

% box
plot( x([1 1 2 2 1]), y([1 2 2 1 1]), 'Clipping', 'off' )

