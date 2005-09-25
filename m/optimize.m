%------------------------------------------------------------------------------%
% Optimize

FIXME

% grid gradient
i1 = i1cell;
i2 = i2cell;
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
s1(:) = 0.;
s2(:) = 0.;
for i = 1:3
  j = mod( i , 3 ) + 1;
  k = mod( i + 1, 3 ) + 1;
  s1(j1:j2,k1:k2,l1:l2) = dfnc( 'h', x, x, 1., i, i, i1, i2 );
  w1(:,:,:,i) = abs( s1 );
  s1(j1:j2,k1:k2,l1:l2) = dfnc( 'h', x, x, 1., i, j, i1, i2 );
  s2(j1:j2,k1:k2,l1:l2) = dfnc( 'h', x, x, 1., i, k, i1, i2 );
  w2(:,:,:,i) = abs( s1 ) + abs( s2 );
end

% for equal grid:
% dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
% dx/dx = dy/dy = dz/dz
tol = 10. * eps( dx );
missfit = ...
  sum( w2 ) + ...
  sum( abs( w1(:,:,:,1) - w1(:,:,:,2) ) ) ...
  sum( abs( w1(:,:,:,1) - w1(:,:,:,3) ) )

ioper(1,:) = [ 1 1 1   -1 -1 -1 ];
if misfit < tol
  oper = 'h';
  return
end

% rectangular grid. find minimal region where:
% dx/dy = dx/dz = dy/dz = dy/dx = dz/dx = dz/dy = 0
s1 = sum( w2, 4 );
j1 = i1(1); j2 = i2(1);
k1 = i1(2); k2 = i2(2);
l1 = i1(3); l2 = i2(3);
for i = j1:j2,    i1(1) = i; if find( s1(i,:,:) ) > tol ) break, end, end
for i = j2:-1:j1, i2(1) = i; if find( s1(i,:,:) ) > tol ) break, end, end
for i = k1:k2,    i1(2) = i; if find( s1(:,i,:) ) > tol ) break, end, end
for i = k2:-1:k1, i2(2) = i; if find( s1(:,i,:) ) > tol ) break, end, end
for i = l1:l2,    i1(3) = i; if find( s1(:,:,i) ) > tol ) break, end, end
for i = l2:-1:l1, i2(3) = i; if find( s1(:,:,i) ) > tol ) break, end, end

% asign operators
if prod( i2 - i1 + 1 ) > .9 * prod( i2cell - i2cell + 1 )
  oper = 'g';
else if i2 >= i1
  noper = 2;
  oper = 'rg';
  ioper(2,:) = [ i1 i2 + 1 ];
end

