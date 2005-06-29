FC       = f95
FFLAGS   = -ffree-form
LDFLAGS  = -ffree-form
OBJECT   = dfnc.o dfcn.o hgnc.o hgcn.o

$(OBJECT): makefile

sord: $(OBJECT)
	$(FC) $(OBJECT) -o sord $(LDFLAGS)
clean:
	rm *.o
