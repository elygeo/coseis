% Colorscheme
function clim = colorscheme( varargin )

scheme = 'k0';
colorexp = 1;
folded = 'no';
if nargin >= 1, scheme   = varargin{1}; end
if nargin >= 2, colorexp = varargin{2}; end
if nargin >= 3, folded   = varargin{3}; end
fg = [ 0 0 0 ];
centered = 0;

switch scheme
case 'k0'
  fg = [ 1 1 1 ];
  cmap = [
    0 0 0 8 8
    0 0 8 8 0
    0 8 8 0 0 ]' / 8;
case 'k1'
  fg = [ 1 1 1 ];
  cmap = [
    4 0 0 8 8
    0 0 8 8 0
    4 8 8 0 0 ]' / 8;
case 'k2'
  fg = [ 1 1 1 ];
  centered = 1;
  cmap = [
    0 0 0 8 8
    8 0 0 0 8
    8 8 0 0 0 ]' / 8;
case 'w0'
  cmap = [
    8 1 0 3 4 8 8
    8 3 5 8 8 8 3
    8 8 8 8 4 3 3 ]' / 8;
case 'w1'
  cmap = [
    1 0 3 4 8 8
    3 5 8 8 8 3
    8 8 8 4 3 3 ]' / 8;
case 'w2'
  centered = 1;
  cmap = [
    4 3 8 8 8
    8 3 8 2 8
    8 8 8 2 3 ]' / 8;
case 'w3'
  centered = 1;
  cmap = [
    8 8 8
    8 7 2
    8 1 2 ]' / 8;
case 'melt'
  cmap = [
    1 4 8 8
    3 1 1 8
    6 4 1 2 ]' / 8;
case 'wmelt'
  cmap = [
    3 6 8 8
    3 3 3 8
    8 6 3 3 ]' / 8;
case 'wtrup'
  cmap = [
    8 8 4 3 3 6
    3 8 8 8 5 3 
    3 3 4 8 8 6 ]' / 8;
  cmap = repmat( cmap, 3, 1 );
case 'wk0'; cmap = [ 1 1 1; 0 0 0 ];
case 'wk2'; cmap = [ 1 1 1; 0 0 0 ]; centered = 1;
otherwise, error( 'colormap scheme' )
end

if strcmp( folded, 'folded' )
  cmap = cmap([end:-1:2 1:end],:);
  centered = 1;
end

if centered
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .001 : 1;
else
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = 0 : .0005 : 1;
end
x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
colormap( max( 0, min( 1, interp1( x1, cmap, x2 ) ) ) );
bg = 1 - fg;
set( gcf, ...
  'InvertHardcopy', 'off', ...
  'DefaultTextInterpreter', 'tex', ...
  'DefaultAxesFontName', 'Helvetica', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultAxesFontSize', 9, ...
  'DefaultTextFontSize', 9, ...
  'DefaultAxesLinewidth', .5, ...
  'DefaultLineLinewidth', .5, ...
  'DefaultAxesColor', 'none', ...
  'Color', bg, ...
  'DefaultTextColor', fg, ...
  'DefaultLineColor', fg, ...
  'DefaultAxesXColor', fg, ...
  'DefaultAxesYColor', fg, ...
  'DefaultAxesZColor', fg, ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultSurfaceEdgeColor', fg, ...
  'DefaultLineMarkerEdgeColor', fg, ...
  'DefaultLineMarkerFaceColor', fg )

