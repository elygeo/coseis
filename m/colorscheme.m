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

%Y = 0.3R + 0.6G + 0.1B
switch scheme
case 'hot'; cmap = [ 8 0 0; 8 0 0; 8 8 0 ] / 8; fg = [ 1 1 1 ];
case 'kw2'; cmap = [ 0 0 0; 1 1 1 ]; fg = [ 1 1 1 ]; centered = 1;
case 'kw1'; cmap = [ 0 0 0; 1 1 1 ]; fg = [ 1 1 1 ];
case 'wk2'; cmap = [ 1 1 1; 0 0 0 ]; centered = 1;
case 'wk1'; cmap = [ 1 1 1; 0 0 0 ];
case 'wk0'
  cmap = [
    8 8:-1:1
    8 8:-1:1
    8 8:-1:1 ]' / 8;
case 'w00'
  cmap = [
    8 8 0 0 0 0 8 8 8 8 8
    8 8 4 6 8 8 8 6 4 0 0
    8 8 8 8 8 0 0 0 0 0 0 ]' / 8;
case 'w0'
  cmap = [
    8 0 0 0 0 8 8 8 8
    8 4 6 8 8 8 6 4 0
    8 8 8 8 0 0 0 0 0 ]' / 8;
case 'b0'
  cmap = [
    0 0 0 0 8 8 8 8
    4 6 8 8 8 6 4 0
    8 8 8 0 0 0 0 0 ]' / 8;
case 'b00'
  cmap = [
    0 0 0 0 0 8 8 8 8
    4 4 6 8 8 8 6 4 0
    8 8 8 8 0 0 0 0 0 ]' / 8;
case 'g00'
  cmap = [
    7 7 0 0 0 0 8 8 8 8
    7 7 4 6 8 8 8 6 4 0
    7 7 8 8 8 0 0 0 0 0 ]' / 8;
case 'g0'
  cmap = [
    7 0 0 0 0 8 8 8 8
    7 4 6 8 8 8 6 4 0
    7 8 8 8 0 0 0 0 0 ]' / 8;
case 'w1'
  cmap = [
    0 0 0 0 0 8 8 8 8
    0 4 6 8 8 8 6 4 0
    8 8 8 8 0 0 0 0 0 ]' / 8;
case 'w2'
  centered = 1;
  cmap = [
    0 0 8 8 8
    8 0 8 0 8
    8 8 8 0 0 ]' / 8;
case 'w3'
  cmap = [
    8 8 8 8 7 6 4 2
    8 8 7 6 4 1 0 0
    8 8 4 1 0 0 0 0 ]' / 8;
case 'w4'
  centered = 1;
  cmap = [
    4 7 8 7 0 0 0
    0 1 6 7 5 1 0
    0 0 0 7 8 7 4 ]' / 8;
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
case { 'earth' 'kearth' }
  fg = [ 1 1 1 ];
  centered = 1;
  cmap = [
    00 00 00 10 10 15 15 25 25 25
    10 10 10 20 20 25 30 25 25 25
    38 38 38 40 40 25 20 17 17 17 ]' / 80;
case { 'wearth' }
  fg = [ 0 0 0 ];
  centered = 1;
  cmap = [
    00 00 00 10 10 15 15 25 25 25
    10 10 10 20 20 25 30 25 25 25
    38 38 38 40 40 25 20 17 17 17 ]' / 80;
case 'lg0'
  cmap = [
    7 3 0 2 8 8
    7 4 8 8 8 2
    7 8 8 2 0 2 ]' / 8;
case 'lg2'
  centered = 1;
  cmap = [
    0 0 7.5 8 6
    0 6 7.5 6 0
    6 6 7.5 0 0 ]' / 8;
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
  'DefaultAxesColor', bg, ...
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

