% Glyph vizualization

if ~flim, return, end
clear xga vga
minmag = glyphcut * flim;
n  = size( v );
ng = prod( n(1:3) );
ii = find( v(:,:,:,1) >= minmag );

if cellfocus
  j = 1:n(1)-1;
  k = 1:n(2)-1;
  l = 1:n(3)-1;
  x1 = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
else
  x1 = x;
end

for i = 1:3
  xga(:,i) = x1(ii+(i-1)*ng);
end
mga = s(ii);
for i = 1:n(4)-1
  vga(:,i) = v(ii+i*ng);
end

clear ii x1

if doglyph > 1
  reynoldsglyph
else
  wireglyph
end

