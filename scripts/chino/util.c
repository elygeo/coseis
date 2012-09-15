// Miscellaneous utility functions

// packed cell-centered average of four neighboring nodes
void
average(float *x, const int nx, const int ny)
{
    int i, j, k;
    for (j = 0; j < (nx - 1); j++)
    for (k = 0; k < (ny - 1); k++) {
        i = j * ny + k;
        x[i-j] = 0.25 * (x[i] + x[i+1] + x[i+ny] + x[i+ny+1]);
    }
    return;
}
                             
// compute the mean of an array of floats
float
mean(float *x, const size_t n)
{
    float xbar;
    size_t i;
    xbar = 0.0;
    for (i = 0; i < n; i++)
        xbar += x[i];
    return xbar / n;
}
                             
// fill np outer layers from inner layer
void
extrude(float *x, const int nx, const int ny, const int np)
{
    int j, k, i0, i1;
    for (j = np; j > 0; j--) {
        i0 = ny * j;
        i1 = ny * (nx - j - 1);
        for (k = i0; k < i0+ny; k++) x[k-ny] = x[k];
        for (k = i1; k < i1+ny; k++) x[k+ny] = x[k];
    }
    for (j = 0; j < nx; j++) {
        i0 = j * ny + np;
        i1 = j * ny + ny - np - 1;
        for (k = np; k > 0; k--) x[i0-k] = x[i0];
        for (k = np; k > 0; k--) x[i1+k] = x[i1];
    }
    return;
}
                             
