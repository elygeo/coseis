%------------------------------------------------------------------------------%
% SORD

fprintf( 'SORD - Matlab version\n' )

%profile report
%profile plot
%profile clear
%profile on
%dbstop if error

clear all

input
setup
init = 1; viz
gridgen
matmodel
init = 1; fault
init = 1; momentsrc
init = 2; viz, viz
init = 1; output

if gui
  control
else
  step
end

