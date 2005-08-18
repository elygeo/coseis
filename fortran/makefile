#------------------------------------------------------------------------------#
# SORD Makefile

FC = f95
OPTFLAGS = -O3
OPTFLAGS = -g
SRC = \
  globals.f95 \
  main.f95 \
  inputs.f95 \
  gridgen.f95 \
  matmodel.f95 \
  vstep.f95 \
  wstep.f95 \
  output.f95 \
  dfcn.f95 \
  dfnc.f95 \
  hgcn.f95 \
  hgnc.f95 \
  fault.f95 \
  snormals.f95 \
  zoneselect.f95

sord: $(SRC) makefile
	$(FC) $(OPTFLAGS) $(SRC) -o sord

