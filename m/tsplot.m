% Timeseries viz

plot( tg, vg )
hold on
if haveanalytical
  plot( ta, va, ':' )
  hold on
end

n = length( labels ) - 1;
if n > 1
for i = 1 : n
  [ tmp, ii ] = max( abs( vg(:,i) ) );
  iii = max( 1, ii - 1 );
  xg1 = .5 * double( tg(ii) + tg(iii) );
  xg2 = .5 * double( vg(ii,i) + vg(iii,i) );
  if xg2 > 0
    text( xg1, xg2, labels(i+1), 'Hor', 'right', 'Ver', 'bottom' )
  else
    text( xg1, xg2, labels(i+1), 'Hor', 'right', 'Ver', 'top' )
  end
end
end

ylabel( labels(1) )
xlabel( 'Time' )

