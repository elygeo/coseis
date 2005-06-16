%------------------------------------------------------------------------------%
% DNH - node-to-cell constant h difference operator

function df = dnh( f, i, h, a, j, k, l )
switch a
case 1
df = 0.25 * h * h * ...
( f(j,  k,l,i) + f(j,  k-1,l,i) + f(j,  k,l-1,i) + f(j,  k-1,l-1,i) ...
- f(j-1,k,l,i) - f(j-1,k-1,l,i) - f(j-1,k,l-1,i) - f(j-1,k-1,l-1,i) );
case 2
df = 0.25 * h * h * ...
( f(j,k,  l,i) + f(j-1,k,  l,i) + f(j,k,  l-1,i) + f(j-1,k,  l-1,i) ...
- f(j,k-1,l,i) - f(j-1,k-1,l,i) - f(j,k-1,l-1,i) - f(j-1,k-1,l-1,i) );
case 3
df = 0.25 * h * h * ...
( f(j,k,l  ,i) + f(j-1,k,l  ,i) + f(j,k-1,l  ,i) + f(j-1,k-1,l  ,i) ...
- f(j,k,l-1,i) - f(j-1,k,l-1,i) - f(j,k-1,l-1,i) - f(j-1,k-1,l-1,i) );
otherwise error a
end

