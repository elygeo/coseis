# GNU Compiler Collection

ifeq ($(MODE), mpi)
    CC = mpicc
    FC = mpif90 
    LD = mpif90
else
    CC = gcc
    FC = gfortran 
    LD = gfortran
endif

CFLAGS = $(LDFLAGS) -pedantic
FFLAGS = $(LDFLAGS) -fimplicit-none
LDFLAGS = -g -O3 -Wall

ifdef REAL8
    FFLAGS += -fdefault-real-8
endif

ifdef OMP
    LDFLAGS += -fopenmp
endif

ifdef PROFILE
    LDFLAGS += -pg
endif

ifdef DEBUG
    LDFLAGS += -fbounds-check -ffpe-trap=invalid,zero,overflow
endif
