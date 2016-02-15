// Create CVM-S 3D input mesh from 2D mesh.
// Can be run concurrently for each file (3 processes).

#include <stdio.h>    // for printf(), fdopen, fopen(), remove()
#include <stdlib.h>   // for malloc(), exit()
#include <fcntl.h>    // for open(), mode, flags
#include <unistd.h>   // for close()
#include <string.h>   // for strrchr()
//#include <sys/stat.h>

int
main(int argc, char *argv[])
{
const float zstart = ZSTART, delta = DELTA;
const size_t nnode = NNODE;
const int nz = NZ;
const int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
const int flags = O_WRONLY | O_CREAT | O_EXCL;
const char *files[] = {"mesh-lon.bin", "mesh-lat.bin", "mesh-dep.bin"};
const char *path, *path0;
float *buff = (float *)malloc(nnode * sizeof(float));
FILE *stream;
int j, k, fh, err;
size_t i;

// lon/lat
for (k = 0; k < 2; k++) {
    path = files[k];
    fh = open(path, flags, mode);
    if (fh >= 0) {
        path0 = strrchr(path, '/') + 1;
        err = (stream = fopen(path0, "r")) == NULL;
        err = err || fread(buff, sizeof(float), nnode, stream) != nnode;
        fseek(stream, 0, SEEK_END);
        err = err || ftell(stream) != sizeof(float) * nnode;
        if (fclose(stream) || err) {
            close(fh);
            remove(path);
            printf("Error reading %s\n", path0);
            exit(1);
        }
        err = (stream = fdopen(fh, "w")) == NULL;
        for (j = 0; j < nz && !err; j++)
            err = fwrite(buff, sizeof(float), nnode, stream) != nnode;
        if (fclose(stream) || err) {
            remove(path);
            printf("Error writing %s\n", path);
            exit(1);
        }
    }
}

// depth
path = files[2];
fh = open(path, flags, mode);
if (fh >= 0) {
    err = (stream = fdopen(fh, "w")) == NULL;
    for (j = 0; j < nz && !err; j++) {
        for (i = 0; i < nnode; i++)
            buff[i] = zstart + j * delta;
        err = fwrite(buff, sizeof(float), nnode, stream) != nnode;
    }
    if (fclose(stream) || err) {
        remove(path);
        printf("Error writing %s\n", path);
        exit(1);
    }
}

// all done
return 0;
}

