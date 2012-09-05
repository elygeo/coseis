#include "mpi.h"
#include <stdio.h>
#include <unistd.h>

int main(int argc,char *argv[]) {
int i, n;
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &i);
MPI_Comm_size(MPI_COMM_WORLD, &n);
fprintf(stdout,"Process %d of %d\n", i, n);
fflush(stdout);
#pragma omp parallel
sleep(1);
MPI_Finalize();
return 0;

}
