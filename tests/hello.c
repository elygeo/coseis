#include "mpi.h"
#include <stdio.h>

int main(int argc,char *argv[]) {
int i, n;
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &i);
MPI_Comm_size(MPI_COMM_WORLD, &n);
fprintf(stdout,"Hello C process %d of %d\n", i, n);
fflush(stdout);
#pragma omp parallel for schedule(static) private(i)
for (i = 0; i < 100000000; i++) continue;
MPI_Finalize();
return 0;

}
