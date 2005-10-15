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
gridgen
matetial
fault
momentsource
output
step

