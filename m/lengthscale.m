% Scale bar
function [ h1, h2 ] = lengthscale( varargin )

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

% lines
hold on
fg = get( gcf, 'DefaultTextColor' );
x_ = .5 * sum( x );
y_ = .5 * sum( y );
h1 = plot( [ x(1) x(2) nan x(1) x(1) nan x_   x_   nan x(2) x(2) ], ...
           [ y_   y_   nan y(1) y(2) nan y(1) y(2) nan y(1) y(2) ] );
set( h1, 'Clipping', 'off', 'HitTest', 'off', 'Color', fg )
if nargout < 1, clear h1, end

% text
dx = x(2) - x(1);
dy = y(2) - y(1);
h2(1) = text( x(1) - .02 * dx, y(1) + .5 * dy, [ str1 '0' ], 'Hor', 'right' );
h2(2) = text( x(2) + .02 * dx, y(1) + .5 * dy, [ num2str(dx) str2 ], 'Hor', 'left' );
set( h2, 'Ver', 'middle', 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 2, clear h2, end

