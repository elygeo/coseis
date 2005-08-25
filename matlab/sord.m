%------------------------------------------------------------------------------%
% SORD - Support-Operator Rupture Dynamics

%profile report
%profile plot
profile clear
profile on
%dbstop if error
clear all
format short e
format compact

fprintf( 'SORD - Support-Operator Rupture Dynamics\n' )

defaults
in
init
viz
gridgen
matmodel
fault
momentsrc
output
viz

if gui
  control
else
  step
  quit
end

