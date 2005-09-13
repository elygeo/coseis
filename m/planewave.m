%------------------------------------------------------------------------------%
% PLANEWAVE

FIXME
domp = 8 * dt;
time = ( 1 : it ) * dt;  % time indexing goes wi vi wi+1 vi+1 ...
switch srctimefcn
case 'delta',  psrct = zeros( size( time ) ); psrct(1) = 1 / dt;
case 'sine',   psrct = sin( 2 * pi * time / domp ) * pi / domp;
case 'brune',  psrct = time .* exp( -time / domp ) / domp ^ 2;
case 'sbrune', psrct = time .^ 2 .* exp( -time / domp ) / 2 / domp ^ 3;
otherwise error 'srctimefcn'
end
for i = 1:3
  switch iplanewave
  case 1, v(i0(1),:,:,i) = psrct(it) * displacement(i);
  case 2, v(:,i0(2),:,i) = psrct(it) * displacement(i);
  case 3, v(:,:,i0(3),i) = psrct(it) * displacement(i);
  end
end

