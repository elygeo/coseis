% Timeseries viz

if ~length( vt ), return, end

plot( tt, vt )
hold on

if length( tta )
  plot( tta, vta, ':' )
  hold on
end

n = length( labels ) - 1;

for i = 1 : n
  [ tmp, ii ] = max( abs( vt(:,i) ) );
  iii = max( 1, ii - 1 );
  x1 = .5 * double( tt(ii) + tt(iii) );
  x2 = .5 * double( vt(ii,i) + vt(iii,i) );
  if x2 > 0
    text( x1, x2, labels(i+1), 'Hor', 'right', 'Ver', 'bottom' )
  else
    text( x1, x2, labels(i+1), 'Hor', 'right', 'Ver', 'top' )
  end
end

ylabel( labels(1) )
xlabel( 'Time' )

