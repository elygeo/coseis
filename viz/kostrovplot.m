% Plot Kostrov results

clear all
addpath viz out
meta
field = 'sv';
dark = 1;
fig

dofilter = 1;
for ir = 10:10:30
  sensor = ihypo + [ ir 0 0 ];
  timeseries
  labels{2} = sprintf( 'r=%g', rg );
  tsplot
end

return

print -dpsc2 kost.ps

