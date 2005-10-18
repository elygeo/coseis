% Glyph vizualization

if ~fscl, return, end
clear xga vga
minmag = glyphcut * fscl;
n  = size( f );
ng = prod( n(1:3) );
ii = find( f(:,:,:,1) >= minmag );

if cellfocus
  j = 1:n(1)-1;
  k = 1:n(2)-1;
  l = 1:n(3)-1;
  xg = 0.125 * ( ...
    x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
    x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
    x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
    x(j,k,l+1,:) + x(j+1,k+1,l,:) );
else
  xg = x;
end

for i = 0:2
  xga(:,i) = xg(ii+i*ng);
end
mga = f(ii);
for i = 1:n(4)-1
  vga(:,i) = f(ii+i*ng);
end

clear ii xg

if doglyph > 1
  reynoldsglyph
else
  wireglyph
end

