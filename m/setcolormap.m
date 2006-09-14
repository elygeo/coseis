function setcolormap( varargin )

type = 'signed';
scheme = 'dark';
colorexp = .5;
if nargin > 0, type = varargin{1}; end
if nargin > 1, scheme = varargin{2}; end
if nargin > 2, colorexp = varargin{3}; end

switch type
case 'signed'
  switch scheme
  case 'dark'
    cmap = [
      0 0 0 1 1
      1 0 0 0 1
      1 1 0 0 0 ]';
  case 'light'
    cmap = [
      0 2 4 4 4
      4 2 4 2 4
      4 4 4 2 0 ]' / 4;
  case 'bw'
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
  switch scheme
  case 'dark'
    cmap = [
      0 0 0 1 4 4 4
      0 0 4 4 4 0 0
      0 4 4 1 0 0 4 ]' / 4;
  case 'light'
    cmap = [
      4 2 0 2 4 4 4
      4 2 4 4 4 2 0
      4 4 4 2 0 2 4 ]' / 4;
  case 'bw'
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

colormap( interp1( x1, cmap, x2 ) );

