%------------------------------------------------------------------------------%
% DHS4 - O(4) constant h staggered grid difference operator

function df = dhs4( f, i, a, j, k, l )
c1 = 9/8;
c2 = 1/24;
switch a
case 1, df = c1 * ( f(j+1,k,l,i) - f(j,  k,l,i) ) ...
           + c2 * ( f(j+2,k,l,i) - f(j-1,k,l,i) );
case 2, df = c1 * ( f(j,k+1,l,i) - f(j,k,  l,i) ) ...
           + c2 * ( f(j,k+2,l,i) - f(j,k-1,l,i) );
case 3, df = c1 * ( f(j,k,l+1,i) - f(j,k,l  ,i) ) ...
           + c2 * ( f(j,k,l+2,i) - f(j,k,l-1,i) );
otherwise error a
end

