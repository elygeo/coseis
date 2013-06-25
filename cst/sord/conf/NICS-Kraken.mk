# NICS Kraken: Cray XT5

MODE = mpi
CC = cc
FC = ftn
LD = ftn

CFLAGS = $(LDFLAGS)
FFLAGS = $(LDFLAGS) -Mdclchk
LDFLAGS = -fast

ifdef REAL8
    FFLAGS += -Mr8
endif

ifdef OMP
    LDFLAGS += -mp
endif

ifdef DEBUG
    LDFLAGS += -g -Ktrap=fp -Mbounds -Mchkptr
endif

ifdef PROFILE
    LDFLAGS += -g -pg -Mprof=func
endif
