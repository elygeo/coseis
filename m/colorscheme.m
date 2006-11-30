% Colorscheme
function clim = colorscheme( varargin )

scheme   = 0;
type     = 'folded';
colorexp = 1;

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
if abs( scheme ) > 2, type = 'signed'; end

set( gcf, ...
  'InvertHardcopy', 'off', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextInterpreter', 'tex', ...
  'DefaultLineLinewidth', 1, ...
  'Color', bg, ...
  'DefaultAxesFontName', 'Helvetica', ...
  'DefaultAxesFontSize', 14, ...
  'DefaultAxesColor', 'none', ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultAxesXColor', fg, ...
  'DefaultAxesYColor', fg, ...
  'DefaultAxesZColor', fg, ...
  'DefaultSurfaceEdgeColor', fg, ...
  'DefaultLineColor', fg, ...
  'DefaultLineMarkerEdgeColor', fg, ...
  'DefaultLineMarkerFaceColor', 'none', ...
  'DefaultTextColor', fg )

switch type
case 'signed'
  clim = [ 0 1 ];
  switch abs( scheme )
  case 0
    cmap = [
      0 0 0 8 8
      8 0 0 0 8
      8 8 0 0 0 ]' / 8;
  case 1
    cmap = [
      0 2 8 8 8
      8 2 8 2 8
      8 8 8 2 0 ]' / 8;
  case 2
    cmap = [
      0 1 0
      0 1 0
      0 1 0 ]';
  case 3
    cmap = 1 - [
      8 8 8 2 0 0
      0 0 8 8 8 0
      8 0 0 2 8 8 ]' / 8;
    cmap = repmat( cmap, 3, 1 );
  case 4
    cmap = [
      8 8 8 2 2 2
      2 2 8 8 8 2 
      8 2 2 2 8 8 ]' / 8;
    cmap = repmat( cmap, 3, 1 );
  otherwise, error( 'colormap scheme' )
  end
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .001 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
case 'folded'
  clim = [ -1 1 ];
  switch abs( scheme )
  case 0
    cmap = [
      0 0 0 2 8 8 8
      0 0 8 8 8 0 0
      0 8 8 2 0 0 8 ]' / 8;
  case 1
    cmap = [
      8 2 2 2 8 8 8
      8 2 8 8 8 2 2
      8 8 8 2 2 2 8 ]' / 8;
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

colormap( max( 0, min( 1, interp1( x1, cmap, x2 ) ) ) );

if nargout == 0, clear clim, end

