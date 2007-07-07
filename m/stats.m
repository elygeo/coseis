% SORD stats

clear all
tlim = [ 0 60 ];

format compact
meta
currentstep
set( 0, 'ScreenPixelsPerInch', 100 )

figure(5)
clf
subplot(2,1,1)
f = diff( readf32( 'stats/moment' ) ) / dt;
t = ( 1:length(f) ) * dt * itstats;
plot( tlim, [ 0 0 ], 'k--', 'HandleVisibility', 'off' )
hold on
plot( t, 1e-18 * f, 'k' )
xlim( tlim )
ylim( [ -20 120 ] )
set( gca, 'XTickLabel', [] )
ylabel( 'Moment Rate (EN m/s)' )
legend( { 'Moment Rate' } )
subplot(2,1,2)
f      = -diff( readf32( 'stats/estrain' ) ) / dt;
f(:,2) =  diff( readf32( 'stats/efric' ) ) / dt; 
f(:,3) = 2 * ( f(:,1) - f(:,2) );
plot( tlim, [ 0 0 ], 'k--', 'HandleVisibility', 'off' )
hold on
plot( t, 1e-15 * f )
xlim( tlim )
ylim( [ -10 60 ] )
xlabel( 'Time (s)' )
ylabel( 'Power (PW)' )
legend( { 'Strain Power' 'Frictional Power' 'Radiated Power (x2)' } )
print -depsc energy
!sed 's|/DA { \[6|/DA { \[1|' energy.eps > tmp.eps
!ps2pdf14 -dPDFSETTINGS=/prepress -dEPSCrop tmp.eps energy.pdf
return

figure(1); clf
f(:,1) = readf32( 'prof/step' );
f(:,2) = readf32( 'prof/comp' );
f(:,3) = readf32( 'prof/comm' );
f(:,4) = readf32( 'prof/out' );
plot( f, '.' )
xlabel( 'Step' )
ylabel( 'Run Time (s)' )
legend( { 'Total' 'Computation' 'Communication' 'Output' } )

t = ( 1:floor(it/itstats) ) * dt * itstats;

figure(2); clf
subplot(3,1,1)
f = readf32( 'stats/umax' );
plot( t, f )
xlim( tlim )
set( gca, 'XTickLabel', [] )
ylabel( 'u (m)' )
subplot(3,1,2)
f = readf32( 'stats/vmax' );
plot( t, f )
xlim( tlim )
set( gca, 'XTickLabel', [] )
ylabel( 'u'' (m/s)' )
subplot(3,1,3)
f = readf32( 'stats/amax' );
plot( t, f )
xlim( tlim )
xlabel( 'Time (s)' )
ylabel( 'u'''' (m/s^2)' )

if faultnormal

figure(3); clf
f      = readf32( 'stats/tnmin' );
f(:,2) = readf32( 'stats/tnmax' );
f(:,3) = readf32( 'stats/tsmax' );
plot( t, 1e-6 * f )
xlim( tlim )
xlabel( 'Time (s)' )
ylabel( 'Stress (MPa)' )
legend( { 'Min \sigma_n' 'Max \sigma_n' 'Max \tau_s' } )

figure(4); clf
subplot(3,1,1)
f = readf32( 'stats/sumax' );
plot( t, f )
xlim( tlim )
set( gca, 'XTickLabel', [] )
ylabel( 's (m)' )
subplot(3,1,2)
f = readf32( 'stats/svmax' );
plot( t, f )
xlim( tlim )
set( gca, 'XTickLabel', [] )
ylabel( 's'' (m/s)' )
subplot(3,1,3)
f = readf32( 'stats/samax' );
plot( t, f )
xlim( tlim )
xlabel( 'Time (s)' )
ylabel( 's'''' (m/s^2)' )

end

