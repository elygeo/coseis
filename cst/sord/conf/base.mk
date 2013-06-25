# Options

CC =
FC =
LD =
CFLAGS =
FFLAGS =
LDFLAGS =
MODE = serial
OMP = 1
DEBUG =    
PROFILE =
REAL8 =
LIBS =

{local}

sord.x : {objects} \
	collective_$(MODE).o
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

collective.mod : collective_$(MODE).o
	@true   

clean :
	rm -f *.o *.mod *.x *.lst *.pyc

distclean : clean
	rm Makefile

{rules}

%.mod : %.o
	@true
