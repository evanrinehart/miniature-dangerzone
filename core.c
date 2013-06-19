#include <stdlib.h>
#include <sys/select.h>

/*
core IO/time support

use select to multiplex the server socket, client connections,
the server stdin console, and the watchdog timer which drives
autonomous activity.

single threaded C
*/

void core_loop(){
  fd_set fds;
  struct timeval timeout;
  int keep_looping = 1;
  int total_fds = 1;
  int server = get_server_fd();
  int ready;

  FD_ZERO(&fds);
  FD_SET(server, &fds);

  timeout.tv_sec = 0;
  timeout.tv_usec = 0;

  while(keep_looping){
    ready = select(total_fds, &fds, NULL, NULL, &timeout);
    if(ready == -1){
      perror("select");
      exit(EXIT_FAILURE);
    }
    else if(ready){
      //FD_ISSET? for each fd
      //server -> accept followed by new connection events
      //player -> fgets+controlevent OR disconnect event
      //stdin -> fgets and server function... keep looping?
    }
    else{
      //watchdog timer!
      //get time until next event
      //set value of timeout struct
    }
  }
}
