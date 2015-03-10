# Coseis Makefile

interp_.c : interp_.pyx

clean :
	rm -rf build *.so *.pyc

distclean : clean
	rm -rf Repository interp_.c

%.c : %.pyx
	cython $<

