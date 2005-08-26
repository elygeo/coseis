%------------------------------------------------------------------------------%
% SORD

fprintf( 'SORD - Support-Operator Rupture Dynamics\n' )

%profile report
%profile plot
%profile clear
%profile on
%dbstop if error

clear all

input
setup
init = 1; viz
init = 1; output
gridgen
matmodel
init = 1; fault
init = 1; momentsrc
init = 2; viz

if gui
  control
else
  step
end

