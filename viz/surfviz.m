% Surface viz
function handle = surfviz( x, f, ic, cellfocus )

handle = [];
n = size( x );
if sum( n > 1 ) < 3
  error
end

for i = 1, 3
  if i == find( n == 1 )
    i1 = [ 1 1 1 1 ];
    i2 = n;
    i2(i) = 1;
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    x1 = squeeze( x(j,k,l,1) );
    x2 = squeeze( x(j,k,l,2) );
    x3 = squeeze( x(j,k,l,3) );
    s1 = squeeze( f(j,k,l,ic) );
    if ~cellfocus
      s1(1:end-1,1:end-1) = .25 * ( ...
        s1(1:end-1,1:end-1) + s1(2:end,1:end-1) + ...
        s1(1:end-1,2:end)   + s1(2:end,2:end) ); 
    end
    handle(end+1) = surf( x1, x2, x3, double( s1 ) );
    hold on
  end
  if all( n - cellfocus > 1 )
    i1 = [ 1 1 1 1 ];
    i1(i) = n(i);
    i2 = n;
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    x1 = squeeze( x(j,k,l,1) );
    x2 = squeeze( x(j,k,l,2) );
    x3 = squeeze( x(j,k,l,3) );
    i1(i) = i1(i) - cellfocus;
    i2(i) = i2(i) - cellfocus;
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    s1 = squeeze( f(j,k,l,ic) );
    if ~cellfocus
      s1(1:end-1,1:end-1) = .25 * ( ...
        s1(1:end-1,1:end-1) + s1(2:end,1:end-1) + ...
        s1(1:end-1,2:end)   + s1(2:end,2:end) ); 
    end
    handle(end+1) = surf( x1, x2, x3, double( s1 ) );
    hold on
  end
end

if domesh, edgecolor = get( 1, 'DefaultTextColor' );
else       edgecolor = 'none';
end

if dosurf, facecolor = 'flat';
else       facecolor = 'none';
end

set( handle, ...
  'Tag', 'surf', ...
  'LineWidth', linewidth / 4, ...
  'EdgeColor', edgecolor, ...
  'FaceColor', facecolor, ...
  'FaceAlpha', 1, ...
  'FaceLighting', 'none' );

