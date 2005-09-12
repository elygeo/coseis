%------------------------------------------------------------------------------%
% TSVIZ

if ~exist( 'w1', 'var' )
  if dark, foreground = [ 1 1 1 ]; background = [ 0 0 0 ]; linewidth = 1;
  else     foreground = [ 0 0 0 ]; background = [ 1 1 1 ]; linewidth = 1;
  end
end

timeseries

if msg, return, end

figure( ...
  'Color', background, ...
  'KeyPressFcn', 'delete(gcbf)', ...
  'DefaultAxesColorOrder', foreground, ...
  'DefaultAxesColor', background, ...
  'DefaultAxesXColor', foreground, ...
  'DefaultAxesYColor', foreground, ...
  'DefaultAxesZColor', foreground, ...
  'DefaultLineColor', foreground, ...
  'DefaultLineLinewidth', linewidth, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextColor', foreground )

if explosion & strcmp( field, 'v' )
  plot( time, vk, ':' )
  hold on
end

plot( time, vg )
hold on

for i = 1 : length( tstitles ) - 1
  [ tmp, ii ] = max( abs( vg(:,i) ) );
  iii = max( 1, ii - 1 );
  xg1 = .5 * double( time(ii) + time(iii) );
  xg2 = .5 * double( vg(ii,i) + vg(iii,i) );
  if xg2 > 0
    text( xg1, xg2, tstitles(i), 'Hor', 'right', 'Ver', 'bottom' )
  else
    text( xg1, xg2, tstitles(i), 'Hor', 'right', 'Ver', 'top' )
  end
end

ylabel( field )
xlabel( 'Time' )
title( num2str( xhair ) )
set( 0, 'CurrentFigure', 1 )

