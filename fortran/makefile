#------------------------------------------------------------------------------#
# SORD Makefile

FC = f95
OBJECT = zoneselect.o globals.o dfnc.o dfcn.o hgnc.o hgcn.o vstep.o wstep.o fault.o matmodel.o gridgen.o snormals.o main.o

sord: $(OBJECT)
	$(FC) $(OBJECT) -o sord $(LDFLAGS)

$(OBJECT): makefile

clean:
	rm *.o *.mod a.out

%.o: %.f95
	$(FC) -c $(FFLAGS) $< -o $@

