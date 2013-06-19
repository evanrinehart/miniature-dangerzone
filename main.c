#include <stdio.h>
#include <signal.h>

#include <script.h>
#include <net.h>
#include <core.h>
#include <log.h>

void clean_up(int unused);

int main(int argc, char* argv[]){

  open_log("log/server.log");
  write_log("*** SERVER BOOT ***\n");

  lua_init();
  listen_on(4321);
  signal(SIGINT, clean_up);
  core_loop();
  return 0;
}


void clean_up(int unused){
  write_log("signal caught\n");

  lua_close_();
  net_close();

  write_log("*** POWER OFF ***\n\n");
  fflush(NULL);

  signal(SIGINT, SIG_DFL);
  raise(SIGINT);
}
