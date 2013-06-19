#include <stdio.h>
#include <signal.h>

#include <script.h>
#include <net.h>
#include <core.h>

void clean_up(int unused);

int main(int argc, char* argv){

  lua_init();
  listen_on(4321);
  signal(SIGINT, clean_up);
  core_loop();
  shutdown(0);

  return 0;
}


void clean_up(int unused){
  puts("cleaning up...");

  lua_close_();
  net_close();

  signal(SIGINT, SIG_DFL);
  raise(SIGINT);
}
