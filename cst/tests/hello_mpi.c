#include "mpi.h"
#include <stdio.h>
#include <unistd.h>

int main(int argc,char *argv[]) {
int n, i;
MPI_Init(&argc, &argv);
MPI_Comm_size(MPI_COMM_WORLD, &n);
MPI_Comm_rank(MPI_COMM_WORLD, &i);
fprintf(stdout,"Process %d of %d\n", i, n);
fflush(stdout);
#pragma omp parallel
sleep(1);
MPI_Finalize();
return 0;

}
