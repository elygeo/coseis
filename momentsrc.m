%------------------------------------------------------------------------------%
% MOMENTSRC

if initialize
  l = 1:n(3)-1;
  k = 1:n(2)-1;
  j = 1:n(1)-1;
  w1(j,k,l,:) = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
  l = hypocenter(3);
  k = hypocenter(2);
  j = hypocenter(1);
  for i = 1:3
    if msrcnodealign
      w1(:,:,:,i) = w1(:,:,:,i) - x(j,k,l,i);
    else
      w1(:,:,:,i) = w1(:,:,:,i) - w1(j,k,l,i);
    end
  end
  s1 = sum( w1 .* w1, 4 );
  msrci = find( s1 < msrcradius ^ 2 );
  msrcx = msrcradius - sqrt( s1( msrci ) );
  msrcx = msrcx / sum( msrcx );
  msrct = [];
  return
end

domp = 8 * dt;
time = ( .5 : it-.5 ) * dt;  % time indexing goes wi vi wi+1 vi+1 ...
switch msrctimefcn
case 'delta',  msrct = 0 * time; msrct(1) = 1;
case 'brune',  msrct = time .* exp( -time / domp ) ./ h ^ 3 ./ domp ^ 2;
case 'sbrune', msrct = time .^ 2 .* exp( -time / domp ) / h ^ 3 / domp ^ 2;
case 'sine',   msrct = sin( 2 * pi * time / domp );
end
o = prod( n );
for i = 0:2
  w1(msrci+o*i) = w1(msrci+o*i) + msrct(it) * msrcx * moment(i+1);
  w2(msrci+o*i) = w2(msrci+o*i) + msrct(it) * msrcx * moment(i+4);
end

