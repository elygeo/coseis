% Scale bar
function [ h1, h2 ] = lengthscale( varargin )

% arguments
str = '';
x = get( gca, 'XLim' );
y = get( gca, 'YLim' );
x = x(1) + [ .25 .75 ] * ( x(2) - x(1) );
y = y(1) - [ .1  .08 ] * ( y(2) - y(1) );
if nargin >= 1, x = varargin{1}; end
if nargin >= 2, y = varargin{2}; end
if nargin >= 3, str = varargin{3}; end

% lines
hold on
fg = get( gcf, 'DefaultTextColor' );
bg = get( gcf, 'Color' );
x_ = .5 * sum( x );
y_ = .5 * sum( y );
h1 = plot( [ x(1) x(2) nan x(1) x(1) nan x(2) x(2) ], ...
           [ y_   y_   nan y(1) y(2) nan y(1) y(2) ] );
set( h1, 'Clipping', 'off', 'HitTest', 'off', 'Color', fg )
if nargout < 1, clear h1, end

% text
h2 = text( x_, y_, [ num2str(x(2)-x(1)) str ], 'Hor', 'center', 'Ver', 'middle' );
set( h2, 'BackgroundColor', bg, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 2, clear h2, end

