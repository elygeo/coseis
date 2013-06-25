# GNU Compiler Collection

ifeq ($(MODE), mpi)
    FC = mpif90 
else
    FC = gfortran 
endif

FFLAGS = $(LDFLAGS) -fimplicit-none
LDFLAGS = -g -O3 -Wall
