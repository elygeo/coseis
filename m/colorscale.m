% Scale bar
function [ h1, h2 ] = colorscale( varargin )

% size
str = '';
lim1 = '';
lim2 = '';
clim = caxis;
orientation = 'b';
x = get( gca, 'XLim' );
y = get( gca, 'YLim' );
x = x(1) + [ .25 .75 ] * ( x(2) - x(1) );
y = y(1) - [ .1  .05 ] * ( y(2) - y(1) );
if nargin >= 1, str = varargin{1}; end
if nargin >= 2, x = varargin{2}; end
if nargin >= 3, y = varargin{3}; end
if nargin >= 4, clim = varargin{4}; end
if nargin >= 5, orientation = varargin{5}; end
if nargin >= 6, lim1 = varargin{6}; end
if nargin >= 7, lim2 = varargin{7}; end
x = x(:)';
y = y(:)';

% color image
fg = get( gcf, 'DefaultTextColor' );
cmap = colormap;
folded = -clim(1) == clim(2) && all( all( cmap == cmap(end:-1:1,:) ) );
dc = ( clim(2) - clim(1) ) / ( length( cmap ) - 1 );
if folded, clim(1) = 0; end
hold on
if any( strcmp( orientation, { 'l' 'r' } ) )
  xx = x + [ 1 -1 ] * ( x(2) - x(1) ) / 3;
  yy = y + [ 1 -1 ] * .5 * ( y(2) - y(1) ) / ( length( cmap ) - 1 );
  cc = [ clim(1):dc:clim(2) ]';
else
  yy = y + [ 1 -1 ] * ( y(2) - y(1) ) / 3;
  xx = x + [ 1 -1 ] * .5 * ( x(2) - x(1) ) / ( length( cmap ) - 1 );
  cc = clim(1):dc:clim(2);
end
h1(1) = imagesc( sort( xx ), sort( yy ), cc );
h1(2) = plot( x([1 1 2 2 1]), y([1 2 2 1 1]), 'Color', fg );
set( h1, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 1, clear h1, end

% text
w = [ 1 .5 0; 0 .5 1 ];
h = .33 * [ -1 -1 -1; 1 1 1 ];
switch orientation
case 'b', x = x * w; y = y(1) - y * h; ver = 'top';    rot = 0;
case 't', x = x * w; y = y(2) + y * h; ver = 'bottom'; rot = 0;
case 'l', y = y * w; x = x(1) - x * h; ver = 'bottom'; rot = 90;
case 'r', y = y * w; x = x(2) + x * h; ver = 'top';    rot = 90;
otherwise, error
end
if ~length( lim1 ), lim1 = num2str(clim(1)); end
if ~length( lim2 ), lim2 = num2str(clim(2)); end
h2 = text( x, y, { lim1 str lim2 } )';
set( h2, 'Hor', 'center', 'Ver', ver, 'Rot', rot, 'Clipping', 'off', 'HitTest', 'off' )
if nargout < 2, clear h2, end

