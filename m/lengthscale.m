% Scale bar
function [ h1, h2 ] = lengthscale( varargin )

% arguments
str = '';
xx = get( gca, 'XLim' );
yy = get( gca, 'YLim' );
x = xx(1) + [ .25 .75 ] * ( xx(2) - xx(1) );
y = yy(1) - [ .1  .08 ] * ( yy(2) - yy(1) );
if nargin >= 1, str = varargin{1}; end
if nargin >= 2, x = varargin{2}; end
if nargin >= 3, y = varargin{3}; end

% lines
hold on
fg = get( gcf, 'DefaultTextColor' );
bg = get( gcf, 'Color' );
x_ = .5 * sum( x );
y_ = .5 * sum( y );
vert = abs( x(2) - x(1) ) / abs( xx(2) - xx(1) ) ...
     < abs( y(2) - y(1) ) / abs( yy(2) - yy(1) );
if vert
  dx = abs( y(2) - y(1) );
  h1 = plot( [ x_   x_   nan x(1) x(2) nan x(1) x(2) ], ...
             [ y(1) y(2) nan y(1) y(1) nan y(2) y(2) ] );
else
  dx = abs( x(2) - x(1) );
  h1 = plot( [ x(1) x(2) nan x(1) x(1) nan x(2) x(2) ], ...
             [ y_   y_   nan y(1) y(2) nan y(1) y(2) ] );
end
set( h1, 'Clipping', 'off', 'HitTest', 'off', 'Color', fg )
if nargout < 1, clear h1, end

% text
h2 = text( x_, y_, [ num2str( dx ) str ], 'Hor', 'center', 'Ver', 'middle' );
set( h2, 'BackgroundColor', bg, 'Clipping', 'off', 'HitTest', 'off' )
if vert, set( h2, 'Rot', 90 ), end
if nargout < 2, clear h2, end
if nargout < 1, clear h1, end

