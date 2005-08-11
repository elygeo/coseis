FC      = f95
#FFLAGS  = -ffree-form
#LDFLAGS = -ffree-form
OBJECT  = dfnc.o dfcn.o hgnc.o hgcn.o step.o snormals.o main.o

sord: $(OBJECT)
	$(FC) $(OBJECT) -o sord $(LDFLAGS)

$(OBJECT): makefile

clean:
	rm *.o *.mod

%.o: %.f95
	$(FC) -c $(FFLAGS) $< -o $@

