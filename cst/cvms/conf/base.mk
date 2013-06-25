# CVMS Makefile

{local}

cvms.x : io$(MODE).o version{version}.o
	$(FC) $(FFLAGS) -o $@ $^ $(LIBS)

clean :
	rm -f *.o *.x *.lst *.pyc

distclean : clean
	rm Makefile

