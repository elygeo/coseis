%------------------------------------------------------------------------------%
% HGR - hourglass corrections

function hg = hgr( f, x, Y, i, j, k, l )
j = j(1)-1 : j(end);
k = k(1)-1 : k(end);
l = l(1)-1 : l(end);
if size( x ) == 1
  Y = x ^ 4 * Y;
else
  switch i
  case 1, Y(j,k,l) = Y(j,k,l) .* ( ( x(j,k+1,l,2) - x(j,k,l,2) ) .* ( x(j,k,l+1,3) - x(j,k,l,3) ) ) .^ 2;
  case 2, Y(j,k,l) = Y(j,k,l) .* ( ( x(j,k,l+1,3) - x(j,k,l,3) ) .* ( x(j+1,k,l,1) - x(j,k,l,1) ) ) .^ 2;
  case 3, Y(j,k,l) = Y(j,k,l) .* ( ( x(j+1,k,l,1) - x(j,k,l,1) ) .* ( x(j,k+1,l,2) - x(j,k,l,2) ) ) .^ 2;
  end
end
j(1) = [];
k(1) = [];
l(1) = [];
hg = ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k-1,l-1,i) - f(j-1,k,l,i) - f(j,k-1,l,i) - f(j,k,l-1,i) ) .* Y(j-1,k-1,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k-1,l-1,i) - f(j+1,k,l,i) - f(j,k-1,l,i) - f(j,k,l-1,i) ) .* Y(j,k-1,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k+1,l-1,i) - f(j-1,k,l,i) - f(j,k+1,l,i) - f(j,k,l-1,i) ) .* Y(j-1,k,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k-1,l+1,i) - f(j-1,k,l,i) - f(j,k-1,l,i) - f(j,k,l+1,i) ) .* Y(j-1,k-1,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j-1,k+1,l+1,i) - f(j-1,k,l,i) - f(j,k+1,l,i) - f(j,k,l+1,i) ) .* Y(j-1,k,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k-1,l+1,i) - f(j+1,k,l,i) - f(j,k-1,l,i) - f(j,k,l+1,i) ) .* Y(j,k-1,l) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k+1,l-1,i) - f(j+1,k,l,i) - f(j,k+1,l,i) - f(j,k,l-1,i) ) .* Y(j,k,l-1) ...
- ( f(j,k,l,i) + f(j,k,l,i) + f(j+1,k+1,l+1,i) - f(j+1,k,l,i) - f(j,k+1,l,i) - f(j,k,l+1,i) ) .* Y(j,k,l);

