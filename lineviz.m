%------------------------------------------------------------------------------%
% LINEVIZ

if ~length( lines ), return, end
i = [
  1 2 3  4 2 3
  1 5 3  4 5 3
  1 2 6  4 2 6
  1 5 6  4 5 6
  1 2 3  1 5 3
  1 2 6  1 5 6
  4 2 3  4 5 3
  4 2 6  4 5 6
  1 2 3  1 2 6
  4 2 3  4 2 6
  1 5 3  1 5 6
  4 5 3  4 5 6
];
tmp = [];
for iz = 1:size( lines, 1 )
  zone = lines(iz,:);
  tmp = [ tmp; zone( i ) ];
end
lines = unique( tmp,  'rows' );
xga = [];
for iz = 1:size( lines, 1 )
  zone = lines(iz,:);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  ng = i2 - i1 + 1;
  if sum( ng > 1 ) == 1
    xg = squeeze( x(j,k,l,:) + xscl * u(j,k,l,:) );
    xga = [ xga; xg; NaN NaN NaN ];
  end
end
hlines = plot3( xga(:,1), xga(:,2), xga(:,3) );
hold on

