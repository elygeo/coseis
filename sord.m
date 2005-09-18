%------------------------------------------------------------------------------%
% SORD

fprintf( '\nSORD - Support Operator Rupture Dynamics\n' )

%profile report
%profile plot
%profile clear
%profile on
%dbstop if error

clear all
if exist( 'out', 'dir' ), rmdir( 'out', 's' ), end

addpath m
inread
setup
arrays
init = 1; viz
gridgen
matmodel
pml
init = 1; fault
init = 1; momentsrc
init = 2; viz, viz
init = 1; output

if gui
  control
else
  step
end

