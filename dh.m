%------------------------------------------------------------------------------%
% DH - constant h difference operator

function df = dh( f, i, a, j, k, l )
switch a
case 1
df = 0.25 * ...
( f(j+1,k,l,i) + f(j+1,k+1,l,i) + f(j+1,k,l+1,i) + f(j+1,k+1,l+1,i) ...
- f(j,  k,l,i) - f(j,  k+1,l,i) - f(j,  k,l+1,i) - f(j,  k+1,l+1,i) );
case 2
df = 0.25 * ...
( f(j,k+1,l,i) + f(j+1,k+1,l,i) + f(j,k+1,l+1,i) + f(j+1,k+1,l+1,i) ...
- f(j,k,  l,i) - f(j+1,k,  l,i) - f(j,k,  l+1,i) - f(j+1,k,  l+1,i) );
case 3
df = 0.25 * ...
( f(j,k,l+1,i) + f(j+1,k,l+1,i) + f(j,k+1,l+1,i) + f(j+1,k+1,l+1,i) ...
- f(j,k,l  ,i) - f(j+1,k,l  ,i) - f(j,k+1,l  ,i) - f(j+1,k+1,l  ,i) );
otherwise error a
end

