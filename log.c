#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>

#include <log.h>

static FILE* log_file = NULL;

void open_log(const char* path){
  log_file = fopen(path, "a");
  if(log_file == NULL){
    perror("open_log");
    exit(EXIT_FAILURE);
  }
}

void write_log(const char* format, ...){
  va_list ap;
  char time_string[256];
  time_t raw;
  struct tm* local;

  if(log_file == NULL){
    fprintf(stderr, "log: log file uninitialized\n");
    exit(EXIT_FAILURE);
  }

  raw = time(NULL);
  local = localtime(&raw);
  strftime(time_string, 256, "%Y-%m-%d %H:%M:%S", local);
  fprintf(log_file, "%s ", time_string);

  va_start(ap, format);

  if(vfprintf(log_file, format, ap) < 0){
    perror("log");
    exit(EXIT_FAILURE);
  }

  va_end(ap);
}
