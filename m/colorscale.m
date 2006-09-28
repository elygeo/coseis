% Scale bar
function [ h1, h2 ] = colorscale( varargin )

% arguments
str1 = '';
str2 = '';
x = get( gca, 'XLim' );
y = get( gca, 'YLim' );
x = x(1) + [ .25 .75 ] * ( x(2) - x(1) );
y = y(1) - [ .1  .08 ] * ( y(2) - y(1) );
if nargin >= 1, str1 = varargin{1}; end
if nargin >= 2, str2 = varargin{2}; end
if nargin >= 3, x = varargin{3}; end
if nargin >= 4, y = varargin{4}; end

% color image
fg = get( gcf, 'DefaultTextColor' );
cmap = colormap;
clim = caxis;
folded = -clim(1) == clim(2) && all( cmap(1,:) == cmap(end,:) );
dc = ( clim(2) - clim(1) ) / ( length( cmap ) - 1 );
if folded, clim(1) = 0; end
hold on
dx = .5 * ( x(2) - x(1) ) / ( length( cmap ) - 1 );
dy = ( y(2) - y(1) ) / 3;
h1(1) = imagesc( x + dx * [ 1 -1 ], y(1) + dy * [ 1 2 ], clim(1):dc:clim(2) );
h1(2) = plot( x([1 1 2 2 1]), y([1 2 2 1 1]), 'Color', fg );
set( h1, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 1, clear h1, end

% text
dx = x(2) - x(1);
dy = y(2) - y(1);
h2(1) = text( x(1) - .02 * dx, y(1) + .5 * dy, [ str1 num2str(clim(1)) ], 'Hor', 'right' );
h2(2) = text( x(2) + .02 * dx, y(1) + .5 * dy, [ num2str(clim(2)) str2 ], 'Hor', 'left' );
set( h2, 'Ver', 'middle', 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 2, clear h2, end

