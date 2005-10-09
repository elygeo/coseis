% Locked nodes

for iz = 1:size( ilock, 1 )
  i1 = max( i1lock(iz,), i2node );
  i2 = min( i2lock(iz,), i2node );
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  i = ilock(iz,:) == 1;
  w1(j,k,l,i) = 0.;
end

