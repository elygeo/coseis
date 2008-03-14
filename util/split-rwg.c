// Split RWG format
#include <stdio.h>
#include <stdlib.h>
#define INT_SIZE 4
#define FLOAT_SIZE 4

int main( int argc, char** argv ) {
  FILE* input = fopen( argv[1], "rb" );
  FILE* v1 = fopen( "v1", "wb" );
  FILE* v2 = fopen( "v2", "wb" );
  FILE* v3 = fopen( "v3", "wb" );
  int n1, n2, n3, nt, n, it;
  float* vv;
  fseek( input, 16, SEEK_SET );
  fread( &n1, INT_SIZE, 1, input );
  fread( &n2, INT_SIZE, 1, input );
  fread( &n3, INT_SIZE, 1, input );
  fread( &nt, INT_SIZE, 1, input );
  printf( "%d %d %d %d\n", n1, n2, n3, nt );
  n = n1 * n2 * n3;
  vv = malloc( n * sizeof( float ) );
  if ( vv == NULL) { printf( "Malloc error.\n" ); exit(1); }
  fseek( input, 60, SEEK_SET );
  for ( it = 1; it <= nt; it++ ) {
    printf( "%d\n", it );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v1 );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v2 );
    fread( vv, FLOAT_SIZE, n, input ); fwrite( vv, FLOAT_SIZE, n, v3 );
  }
  fclose( input );
  fflush( v1 ); fclose( v1 );
  fflush( v2 ); fclose( v2 );
  fflush( v3 ); fclose( v3 );
  return 0;
}

