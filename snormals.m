%------------------------------------------------------------------------------%
% SNORMALS - surface normals

function nrm = snormals( x, j, k, l )
n  = [ length(j) length(k) length(l) ];
ax = find( n == 1 );
n  = size( x );
n(ax) = 1;
zero = 0 * x(1);
nrm = repmat( zero, n );
for a = 1:3
  b = mod( a,   3 ) + 1;
  c = mod( a+1, 3 ) + 1;
  switch ax
  case 1
    nrm(1,k,l,a) = 1 / 12 * ...
    ( x(j,k+1,l,b) .* ( x(j,k,l+1,c) + x(j,k+1,l+1,c)   ...
	              - x(j,k,l-1,c) - x(j,k+1,l-1,c) ) ...
    + x(j,k-1,l,b) .* ( x(j,k,l-1,c) + x(j,k-1,l-1,c)   ...
	              - x(j,k,l+1,c) - x(j,k-1,l+1,c) ) ...
    + x(j,k,l+1,b) .* ( x(j,k-1,l,c) + x(j,k-1,l+1,c)   ...
	              - x(j,k+1,l,c) - x(j,k+1,l+1,c) ) ...
    + x(j,k,l-1,b) .* ( x(j,k+1,l,c) + x(j,k+1,l-1,c)   ...
		      - x(j,k-1,l,c) - x(j,k-1,l-1,c) ) ...
    + x(j,k+1,l+1,b) .* ( x(j,k,l+1,c) - x(j,k+1,l,c) ) ...
    + x(j,k-1,l-1,b) .* ( x(j,k,l-1,c) - x(j,k-1,l,c) ) ...
    + x(j,k-1,l+1,b) .* ( x(j,k-1,l,c) - x(j,k,l+1,c) ) ...
    + x(j,k+1,l-1,b) .* ( x(j,k+1,l,c) - x(j,k,l-1,c) ) );
  case 2
    nrm(j,1,l,a) = 1 / 12 * ...
    ( x(j,k,l+1,b) .* ( x(j+1,k,l,c) + x(j+1,k,l+1,c)   ...
	              - x(j-1,k,l,c) - x(j-1,k,l+1,c) ) ...
    + x(j,k,l-1,b) .* ( x(j-1,k,l,c) + x(j-1,k,l-1,c)   ...
	              - x(j+1,k,l,c) - x(j+1,k,l-1,c) ) ...
    + x(j+1,k,l,b) .* ( x(j,k,l-1,c) + x(j+1,k,l-1,c)   ...
	              - x(j,k,l+1,c) - x(j+1,k,l+1,c) ) ...
    + x(j-1,k,l,b) .* ( x(j,k,l+1,c) + x(j-1,k,l+1,c)   ...
	              - x(j,k,l-1,c) - x(j-1,k,l-1,c) ) ...
    + x(j+1,k,l+1,b) .* ( x(j+1,k,l,c) - x(j,k,l+1,c) ) ...
    + x(j-1,k,l-1,b) .* ( x(j-1,k,l,c) - x(j,k,l-1,c) ) ...
    + x(j+1,k,l-1,b) .* ( x(j,k,l-1,c) - x(j+1,k,l,c) ) ...
    + x(j-1,k,l+1,b) .* ( x(j,k,l+1,c) - x(j-1,k,l,c) ) );
  case 3
    nrm(j,k,1,a) = 1 / 12 * ...
    ( x(j+1,k,l,b) .* ( x(j,k+1,l,c) + x(j+1,k+1,l,c)   ...
	              - x(j,k-1,l,c) - x(j+1,k-1,l,c) ) ...
    + x(j-1,k,l,b) .* ( x(j,k-1,l,c) + x(j-1,k-1,l,c)   ...
	              - x(j,k+1,l,c) - x(j-1,k+1,l,c) ) ...
    + x(j,k+1,l,b) .* ( x(j-1,k,l,c) + x(j-1,k+1,l,c)   ...
	              - x(j+1,k,l,c) - x(j+1,k+1,l,c) ) ...
    + x(j,k-1,l,b) .* ( x(j+1,k,l,c) + x(j+1,k-1,l,c)   ...
	              - x(j-1,k,l,c) - x(j-1,k-1,l,c) ) ...
    + x(j+1,k+1,l,b) .* ( x(j,k+1,l,c) - x(j+1,k,l,c) ) ...
    + x(j-1,k-1,l,b) .* ( x(j,k-1,l,c) - x(j-1,k,l,c) ) ...
    + x(j-1,k+1,l,b) .* ( x(j-1,k,l,c) - x(j,k+1,l,c) ) ...
    + x(j+1,k-1,l,b) .* ( x(j+1,k,l,c) - x(j,k-1,l,c) ) );
  otherwise error ax
  end
end

