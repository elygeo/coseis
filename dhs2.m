%------------------------------------------------------------------------------%
% DHS2 - O(2) constant h staggered grid difference operator

function df = dhs2( f, i, a, j, k, l )
switch a
case 1, df = f(j+1,k,l,i) - f(j,k,l,i);
case 2, df = f(j,k+1,l,i) - f(j,k,l,i);
case 3, df = f(j,k,l+1,i) - f(j,k,l,i);
otherwise error a
end

