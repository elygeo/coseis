# KAUST Shaheen: IBM Blue Gene/P

MODE = mpi
FC = *FIXME*
FFLAGS = $(LDFLAGS)
LDFLAGS = -g -O5 -qarch=450d -qtune=450 -qsuppress=cmpmsg
