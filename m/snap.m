% Window snapshot

function img1 = snap( varargin )
file = 'snap.png';
dpi = get( 0, 'ScreenPixelsPerInch' );
aa = 3;           
if nargin > 0, file = varargin{1}; end
if nargin > 1, dpi  = varargin{2}; end
if nargin > 2, aa   = varargin{3}; end

if dpi < 10, error( 'snap is changed' ), end

res = sprintf( '-r%d', dpi * aa );
print( '-dtiff', res, 'tmp' )
img1 = single( imread( 'tmp.tif' ) );
delete tmp.tif

if aa > 1
  n1 = size( img1 );
  n2 = floor( n1 ./ aa );
  img2 = repmat( single(0), [ n2(1:2) 3 ] );
  o = round( .5 * ( n1 - aa * n2 ) );
  n = aa * ( n2 ) - 1;
  for j = 1:aa
  for k = 1:aa
    img2 = img2 + img1(o(1)+j:aa:n(1)+j,o(2)+k:aa:n(2)+k,:);
  end
  end
  img1 = img2 ./ ( aa * aa );
  clear img2
end

if length( file ) >= 4 && strcmp( file(end-3:end), '.png' )
  imwrite( uint8( img1 ), file, ...
    'XResolution', dpi / 0.0254, ...
    'YResolution', dpi / 0.0254, ...
    'ResolutionUnit', 'meter' )
elseif file
  imwrite( uint8( img1 ), file )
end

if nargout == 0
  clear img1
end

