% Colorscheme
function colorscheme( varargin )

scheme   = 0;
type     = 'folded';
colorexp = .5;
if nargin >= 1, scheme   = varargin{1}; end
if nargin >= 2, type     = varargin{2}; end
if nargin >= 3, colorexp = varargin{3}; end

if scheme <= 0
  bg = 'k';
  fg = [ 1 1 1 ];
else
  bg = 'w';
  fg = [ 0 0 0 ];
end
set( gcf, ...
  'InvertHardCopy', 'off', ...
  'Color', bg, ...
  'DefaultAxesColor', bg, ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultAxesXColor', fg, ...
  'DefaultAxesYColor', fg ...
  'DefaultAxesZColor', fg, ...
  'DefaultLineColor', fg, ...
  'DefaultTextColor', fg )

switch type
case 'signed'
  switch abs( scheme )
  case 0
    cmap = [
      0 0 0 1 1
      1 0 0 0 1
      1 1 0 0 0 ]';
  case 1
    cmap = [
      0 2 4 4 4
      4 2 4 2 4
      4 4 4 2 0 ]' / 4;
  case 2
    cmap = [
      0 1 0
      0 1 0
      0 1 0 ]';
  otherwise, error( 'colormap scheme' )
  end
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
case 'folded'
  switch abs( scheme )
  case 0
    cmap = [
      0 0 0 1 4 4 4
      0 0 4 4 4 0 0
      0 4 4 1 0 0 4 ]' / 4;
  case 1
    cmap = [
      4 2 0 2 4 4 4
      4 2 4 4 4 2 0
      4 4 4 2 0 2 4 ]' / 4;
  case 2
    cmap = [
      1 0
      1 0
      1 0 ]';
  otherwise, error( 'colormap scheme' )
  end
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
otherwise, error( 'colormap type' )
end
if scheme < 0, cmap = 1 - cmap; end
colormap( interp1( x1, cmap, x2 ) );

