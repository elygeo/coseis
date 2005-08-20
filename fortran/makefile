FC     = mpif95
CC     = mpicc
FFLAGS = -O3
OBJECT =    globals.o   dfcn.o   dfnc.o   hgcn.o   hgnc.o   snormals.o   utils.o   inputs.o   gridgen.o   matmodel.o   vstep.o   wstep.o   output.o   fault.o  pmain.o mpisetup.o mpioutput.o
sord_bin: $(OBJECT)
	$(FC) $(FFLAGS) $(OBJECT) -o sord_bin
	./tarball.sh

clean:
	rm *.o *.mod

%.o: src/%.f95 makefile
        $(FC) $(FFLAGS) -c $< -o $@
