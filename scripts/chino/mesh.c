// Create CVM-S 3D inpute mesh from 2D mesh.
// Can be run concurrently for each file (3 processes).

#include <stdio.h>    // for printf(), fdopen, fopen(), remove()
#include <stdlib.h>   // for malloc(), exit()
#include <fcntl.h>    // for open(), mode, flags
#include <unistd.h>   // for close()
#include <string.h>   // for strrchr()
//#include <sys/stat.h>
#include "util.c"

int
main(int argc, char *argv[])
{
const float delta = DELTA;
const int nx = NX, ny = NY, nz = NZ;
const int npml = NPML, ntop = NTOP;
const int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
const int flags = O_WRONLY | O_CREAT | O_EXCL;
const char *files[] = {"hold/lon.bin", "hold/lat.bin", "hold/dep.bin", "hold/z3.bin"};
const char *path, *path0;
const size_t nnode = nx * ny;
const size_t ncell = (nx - 1) * (ny - 1);
const size_t size = sizeof(float);
float *buff0 = (float *)malloc(nnode * sizeof(float));
float *buff = (float *)malloc(nnode * sizeof(float));
FILE *stream;
float z0, w;
int j, k, n, fh, err;
size_t i;

// lon/lat
for (k = 0; k < 2; k++) {
    path = files[k];
    fh = open(path, flags, mode);
    if (fh >= 0) {
        path0 = strrchr(path, '/') + 1;
        err = (stream = fopen(path0, "r")) == NULL;
        err = err || fread(buff, size, nnode, stream) != nnode;
        fseek(stream, 0, SEEK_END);
        err = err || ftell(stream) != size * nnode;
        if (fclose(stream) || err) {
            close(fh);
            remove(path);
            printf("Error reading %s\n", path0);
            exit(1);
        }
        extrude(buff, nx, ny, npml);
        average(buff, nx, ny);
        err = (stream = fdopen(fh, "w")) == NULL;
        for (j = 0; j < nz - 1 && !err; j++)
            err = fwrite(buff, size, ncell, stream) != ncell;
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
    err = (stream = fopen("topo.bin", "r")) == NULL;
    err = err || fread(buff0, size, nnode, stream) != nnode;
    if (fclose(stream) || err) {
        close(fh);
        remove(path);
        printf("Error reading topo.bin\n");
        exit(1);
    }
    extrude(buff, nx, ny, npml);
    average(buff, nx, ny);
    err = (stream = fdopen(fh, "w")) == NULL;
    n = nz - ntop - npml - 1;
    for (j = 0; j < nz - 1 && !err; j++) {
        //XXX FIXME
        w = 0.5 + 1.0 * (j - ntop) / n;
        w = w > 0.0 ? w : 0.0;
        w = w < 1.0 ? w : 1.0;
        for (i = 0; i < nx; i++);
            buff[i] = buff[i] * w;
        err = fwrite(buff, size, ncell, stream) != ncell;
    }
    if (fclose(stream) || err) {
        remove(path);
        printf("Error writing %s\n", path);
        exit(1);
    }
}

// elevation
path = files[3];
fh = open(path, flags, mode);
if (fh >= 0) {
    err = (stream = fopen("topo.bin", "r")) == NULL;
    path0 = strrchr(path, '/') + 1;
    err = err || fread(buff0, size, nnode, stream) != nnode;
    if (fclose(stream) || err) {
        close(fh);
        remove(path);
        printf("Error reading topo.bin\n");
        exit(1);
    }
    z0 = demean(buff0, nnode);
    extrude(buff0, nx, ny, npml);
    err = (stream = fdopen(fh, "w")) == NULL;
    n = nz - ntop - npml - 1;
    for (j = 0; j < nz && !err; j++) {
        //XXX FIXME
        w = 1.0 * (j - ntop) / n;
        w = w > 0.0 ? w : 0.0;
        w = w < 1.0 ? w : 1.0;
        for (i = 0; i < nx; i++);
            buff[i] = buff[i] * w;
        err = fwrite(buff, size, nnode, stream) != nnode;
    }
    if (fclose(stream) || err) {
        remove(path);
        printf("Error writing %s\n", path);
        exit(1);
    }
}

// finished
return 0;

}

