# ALCF IBM Blue Gene/Q

MODE = mpi
FC = mpixlf2003_r
FFLAGS = $(LDFLAGS) -g -O3 -qfixed
LDFLAGS = -g -O3 -qsuppress=cmpmsg
