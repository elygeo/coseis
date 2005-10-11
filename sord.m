% SORD - main program

%profile report
%profile plot
%profile clear
%profile on
%dbstop if error

clear all
addpath m

fprintf( '\nSORD - Support Operator Rupture Dynamics\n' )

clean
inread
setup
arrays
viz
gridgen
matetial
fault
momentsource
output
viz
viz

if gui
  control
else
  step
end

