#------------------------------------------------------------------------------#
# SORD Makefile

FC = f95
FFLAGS = -O3
FFLAGS = -g
OBJECT = \
  globals.o \
  dfcn.o \
  dfnc.o \
  hgcn.o \
  hgnc.o \
  snormals.o \
  utils.o \
  main.o \
  inputs.o \
  gridgen.o \
  matmodel.o \
  vstep.o \
  wstep.o \
  output.o \
  fault.o

sord: $(OBJECT) makefile
	$(FC) $(FFLAGS) $(OBJECT) -o sord

clean:
	-rm *.o *.mod

%.o: %.f95
	$(FC) $(FFLAGS) -c $< -o $@

