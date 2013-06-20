#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

/*
get precise timestamp because lua does not support this
*/

double timestamp(){
  struct timeval tv;

  if(gettimeofday(&tv, NULL) == -1){
    perror("gettimeofday");
    exit(EXIT_FAILURE);
  }

  return tv.tv_sec + tv.tv_usec / 1000000.0;
}
