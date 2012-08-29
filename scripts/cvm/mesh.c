// CVM-S Mesher
// May be run concurrently for each file (3 processes).

#include <stdio.h>
#include <fcntl.h>

int main(void) {

const float z_start = Z_START, delta = DELTA;
const size_t m = SHAPE_X, n = SHAPE_Z;
const size_t b = sizeof(float);
const int flags = O_WRONLY | O_CREAT | O_EXCL;
const int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
float x[m];
size_t i, j;
int fh;
FILE *f;

// write longitude file
if ((fh = open("hold/lon.bin", flags, mode)) > 0) {
    f = fopen("lon.bin", "r");
    if (f == NULL) {
        perror("lon open error");
        return 1;
    }
    i = fread(x, b, m, f);
    fclose(f);
    if (f == NULL || i != m) {
        perror("lon read error");
        return 1;
    }
    f = fdopen(fh, "w");
    for (j = 0; j < n; j++)
        if (f == NULL || fwrite(x, b, m, f) != m) {
            perror("lon write error");
            return 1;
        }
    sleep(5);
}

// write latitude file
if ((fh = open("hold/lat.bin", flags, mode)) > 0) {
    f = fopen("lat.bin", "r");
    if (f == NULL) {
        perror("lat open error");
        return 1;
    }
    i = fread(x, b, m, f);
    fclose(f);
    if (f == NULL || i != m) {
        perror("lat read error");
        return 1;
    }
    f = fdopen(fh, "w");
    for (j = 0; j < n; j++)
        if (f == NULL || fwrite(x, b, m, f) != m) {
            perror("lat write error");
            return 1;
        }
    sleep(5);
}

// write depth file
if ((fh = open("hold/dep.bin", flags, mode)) > 0) {
    f = fdopen(fh, "w");
    if (f == NULL) {
        perror("dep open error");
        return 1;
    }
    for (j = 0; j < n; j++) {
        for (i = 0; i < m; i++)
            x[i] = z_start + j * delta;
        if (f == NULL || fwrite(x, b, m, f) != m) {
            perror("dep write error");
            return 1;
        }
    }
    sleep(5);
}

// all done
return 0;

}

