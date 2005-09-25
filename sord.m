%------------------------------------------------------------------------------%
% SORD

fprintf( '\nSORD - Support Operator Rupture Dynamics\n' )

%profile report
%profile plot
%profile clear
%profile on
%dbstop if error

clear all
addpath m

clean
inread
setup
arrays
init = 1; viz
gridgen
matetial
init = 1; fault
init = 1; momentsource
init = 2; viz, viz
init = 1; output

if gui
  control
else
  step
end

