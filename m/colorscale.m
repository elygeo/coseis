% Scale bar
function [ h1, h2 ] = colorscale( varargin )

% size
str = '';
orientation = 'b';
x = get( gca, 'XLim' );
y = get( gca, 'YLim' );
x = x(1) + [ .25 .75 ] * ( x(2) - x(1) );
y = y(1) - [ .1  .08 ] * ( y(2) - y(1) );
if nargin >= 1, x = varargin{1}; end
if nargin >= 2, y = varargin{2}; end
if nargin >= 3, str = varargin{3}; end
if nargin >= 4, orientation = varargin{4}; end
x = x(:)';
y = y(:)';

% color image
fg = get( gcf, 'DefaultTextColor' );
cmap = colormap;
clim = caxis;
folded = -clim(1) == clim(2) && all( cmap(1,:) == cmap(end,:) );
dc = ( clim(2) - clim(1) ) / ( length( cmap ) - 1 );
if folded, clim(1) = 0; end
hold on
if strcmp( orientation, { 'l' 'r' } )
  dx = ( x(2) - x(1) ) / 3;
  dy = .5 * ( y(2) - y(1) ) / ( length( cmap ) - 1 );
else
  dx = .5 * ( x(2) - x(1) ) / ( length( cmap ) - 1 );
  dy = ( y(2) - y(1) ) / 3;
end
h1(1) = imagesc( x + dx * [ 1 -1 ], y + dy * [ 1 -1 ], clim(1):dc:clim(2) );
h1(2) = plot( x([1 1 2 2 1]), y([1 2 2 1 1]), 'Color', fg );
set( h1, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 1, clear h1, end

% text
w = [ 1 .5 0; 0 .5 1 ];
h = .33 * [ -1 -1 -1; 1 1 1 ];
switch orientation
case 'b', x = x * w; y = y(1) - y * h; ver = 'top';    hor = 'center';
case 't', x = x * w; y = y(2) + y * h; ver = 'bottom'; hor = 'center';
case 'l', y = y * w; x = x(1) - x * h; ver = 'middle'; hor = 'right';
case 'r', y = y * w; x = x(2) + x * h; ver = 'middle'; hor = 'left';
end
h2 = text( x, y, { num2str(clim(1)) str num2str(clim(2)) } );
set( h2, 'Hor', hor, 'Ver', ver, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 2, clear h2, end

