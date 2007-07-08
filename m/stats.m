% Plot SORD statistics

function stats( varargin )
meta
currentstep
tlim = [ 0 it*dt ];
if nargin > 0, tlim = varargin{1}; end

f = readf32( 'prof/step' );
if ~isempty( f )
  figure(1); clf
  pos = get( gcf, 'Pos' );
  set( gcf, ...
    'InvertHardcopy', 'off', ...
    'Color', 'w', ...
    'PaperPositionMode', 'auto', ...
    'Pos', [ pos(1:2) 640 640 ] )
  axes( 'Pos', [ .1 .1 .84 .84 ] )
  plot( f, '.k' );
  hold on
  f = readf32( 'prof/comp' ); plot( f, '.b' )
  f = readf32( 'prof/comm' ); plot( f, '.g' )
  f = readf32( 'prof/out'  ); plot( f, '.r' )
  xlim( [ 0 length(f) ] )
  title( 'Timing Profile' )
  xlabel( 'Step' )
  ylabel( 'Run Time (s)' )
  legend( { 'Total' 'Computation' 'Communication' 'Output' }, 'Location', 'NorthWest' )
  legend boxoff
  printpdf( 'prof' )
end

figure(2); clf
pos = get( gcf, 'Pos' );
set( gcf, ...
  'InvertHardcopy', 'off', ...
  'Color', 'w', ...
  'PaperPositionMode', 'auto', ...
  'Pos', [ pos(1:2) 640 640 ] )
axes( 'Pos', [ .1 .68 .84 .26 ] )
f = readf32( 'stats/umax' );
t = ( 1:length(f) ) * dt * itstats;
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Displacement' )
ylabel( 'u (m)' )
set( gca, 'XTickLabel', [] )
axes( 'Pos', [ .1 .39 .84 .26 ] )
f = readf32( 'stats/vmax' );
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Velocity', 'r' )
ylabel( 'u'' (m/s)' )
set( gca, 'XTickLabel', [] )
axes( 'Pos', [ .1 .1 .84 .26 ] )
f = readf32( 'stats/amax' );
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Acceleration', 'r' )
xlabel( 'Time (s)' )
ylabel( 'u'''' (m/s^2)' )
printpdf( 'disp' )

if faultnormal

figure(3); clf
pos = get( gcf, 'Pos' );
set( gcf, ...
  'InvertHardcopy', 'off', ...
  'Color', 'w', ...
  'PaperPositionMode', 'auto', ...
  'Pos', [ pos(1:2) 640 640 ] )
axes( 'Pos', [ .1 .68 .84 .26 ] )
f = readf32( 'stats/sumax' );
t = ( 1:length(f) ) * dt * itstats;
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Slip' )
ylabel( 's (m)' )
set( gca, 'XTickLabel', [] )
axes( 'Pos', [ .1 .39 .84 .26 ] )
f = readf32( 'stats/svmax' );
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Slip Rate', 'r' )
ylabel( 's'' (m/s)' )
set( gca, 'XTickLabel', [] )
axes( 'Pos', [ .1 .1 .84 .26 ] )
f = readf32( 'stats/samax' );
plot( t, f, 'k' )
xlim( tlim )
ptitle( 'Max Slip Acceleration', 'r' )
xlabel( 'Time (s)' )
ylabel( 's'''' (m/s^2)' )
printpdf( 'slip' )

figure(4); clf
pos = get( gcf, 'Pos' );
set( gcf, ...
  'InvertHardcopy', 'off', ...
  'Color', 'w', ...
  'PaperPositionMode', 'auto', ...
  'Pos', [ pos(1:2) 640 640 ] )
axes( 'Pos', [ .1 .1 .84 .84 ] )
plot( tlim, [ 0 0 ], 'k--', 'HandleVisibility', 'off' ), hold on
f = readf32( 'stats/tsmax' ); plot( t, 1e-6 * f, 'k' )
f = readf32( 'stats/tnmax' ); plot( t, 1e-6 * f, 'r' )
f = readf32( 'stats/tnmin' ); plot( t, 1e-6 * f, 'b' )
xlim( tlim )
xlabel( 'Time (s)' )
ylabel( 'Stress (MPa)' )
legend( { 'Max |\tau_s|' 'Max \sigma_n' 'Min \sigma_n' }, 'Location', 'NorthWest' )
legend boxoff
printpdf( 'stress' )

figure(5); clf
pos = get( gcf, 'Pos' );
set( gcf, ...
  'InvertHardcopy', 'off', ...
  'Color', 'w', ...
  'PaperPositionMode', 'auto', ...
  'Pos', [ pos(1:2) 640 320 ] )
axes( 'Pos', [ .1 .2 .84 .68 ] )
f = diff( readf32( 'stats/moment' ) ) / dt;
t = ( 1:length(f) ) * dt * itstats;
plot( t, 1e-18 * f, 'k' ); hold on
plot( t(1), 1e-18 * f(1), 'k--' )
xlim( tlim )
y = ylim;
ylim( [ 0 y(2) ] )
xlabel( 'Time (s)' )
ylabel( 'Moment Rate (EN m/s)' )
legend( { 'Moment Rate' 'Dissipated Power' } )
legend boxoff
box off
axes( 'Pos', [ .1 .2 .84 .68 ] )
f = diff( readf32( 'stats/efric' ) ) / dt;
plot( t, 1e-15 * f, 'k--' )
xlim( tlim )
y = ylim;
ylim( [ 0 y(2) ] )
ylabel( 'Power (PW)' )
set( gca, 'XAxisLoc', 'top', 'YAxisLoc', 'right', 'XTickLabel', [], 'Color', 'none' )
box off
printpdf( 'energy' )

end

