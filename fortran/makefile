FC = f95
CC = cc
FFLAGS = -g
OBJECT = \
  globals.o \
  dfcn.o \
  dfnc.o \
  hgcn.o \
  hgnc.o \
  snormals.o \
  utils.o \
  inputs.o \
  gridgen.o \
  matmodel.o \
  vstep.o \
  wstep.o \
  output.o \
  fault.o \
  main.o

sord: $(OBJECT) makefile
	$(FC) $(FFLAGS) $(OBJECT) -o sord
	./tarball.sh

clean:
	rm *.o *.mod

%.o: %.f95 makefile
	$(FC) $(FFLAGS) -c $< -o $@

