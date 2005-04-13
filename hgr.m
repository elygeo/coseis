%------------------------------------------------------------------------------%
% HGR - hourglass corrections

function hg = hgr( f, x, y, i, j, k, l )
j = j(1)-1 : j(end);
k = k(1)-1 : k(end);
l = l(1)-1 : l(end);
if size( x ) == 1
  c = x ^ 4;
else
  c = 1;
  switch i
  case 1, y(j,k,l) = y(j,k,l) .* ( ( x(j,k+1,l,2) - x(j,k,l,2) ) .* ( x(j,k,l+1,3) - x(j,k,l,3) ) ) .^ 2;
  case 2, y(j,k,l) = y(j,k,l) .* ( ( x(j,k,l+1,3) - x(j,k,l,3) ) .* ( x(j+1,k,l,1) - x(j,k,l,1) ) ) .^ 2;
  case 3, y(j,k,l) = y(j,k,l) .* ( ( x(j+1,k,l,1) - x(j,k,l,1) ) .* ( x(j,k+1,l,2) - x(j,k,l,2) ) ) .^ 2;
  end
end
j(1) = [];
k(1) = [];
l(1) = [];
hg = c * ( ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k-1,l-1,i) - f(j-1,k,l,i) - f(j,k-1,l,i) - f(j,k,l-1,i) ) .* y(j-1,k-1,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k-1,l-1,i) - f(j+1,k,l,i) - f(j,k-1,l,i) - f(j,k,l-1,i) ) .* y(j,k-1,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k+1,l-1,i) - f(j-1,k,l,i) - f(j,k+1,l,i) - f(j,k,l-1,i) ) .* y(j-1,k,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k-1,l+1,i) - f(j-1,k,l,i) - f(j,k-1,l,i) - f(j,k,l+1,i) ) .* y(j-1,k-1,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k+1,l+1,i) - f(j-1,k,l,i) - f(j,k+1,l,i) - f(j,k,l+1,i) ) .* y(j-1,k,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k-1,l+1,i) - f(j+1,k,l,i) - f(j,k-1,l,i) - f(j,k,l+1,i) ) .* y(j,k-1,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k+1,l-1,i) - f(j+1,k,l,i) - f(j,k+1,l,i) - f(j,k,l-1,i) ) .* y(j,k,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k+1,l+1,i) - f(j+1,k,l,i) - f(j,k+1,l,i) - f(j,k,l+1,i) ) .* y(j,k,l) );

