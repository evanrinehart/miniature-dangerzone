#include <stdio.h>
#include <stdlib.h>
#include <sys/select.h>

#include <net.h>
#include <script.h>

/*
core IO/time support

use select to multiplex the server socket, client connections,
the server stdin console, and the watchdog timer which drives
autonomous activity.

single threaded C
*/

#define MAX_CONNECTIONS 10000

void core_loop(){
  int connections[MAX_CONNECTIONS];
  int conn_count = 0;
  int ready;
  int i;
  struct connection new_client;
  fd_set fds;
  struct timeval timeout;
  int server = get_server_fd();
  int max_fd = server + 1;

  for(;;){
    FD_ZERO(&fds);
    FD_SET(server, &fds);

    for(i=0; i<conn_count; i++){
      FD_SET(connections[i], &fds);
    }

    timeout.tv_sec = 1;
    timeout.tv_usec = 0;

    ready = select(max_fd, &fds, NULL, NULL, &timeout);

    if(ready == -1){
      perror("select");
      exit(EXIT_FAILURE);
    }
    else if(ready == 0){
      // wake up event
    }
    else{
      if(FD_ISSET(server, &fds)){
        new_client = get_new_connection();
        printf("new connection:\n");
        printf("fd = %d\n", new_client.fd);
        printf("addr = %s\n", new_client.addr);
        if(conn_count == MAX_CONNECTIONS){
          printf("too many connections!\n");
          disconnect(new_client.fd);
        }
        else{
          connections[conn_count] = new_client.fd;
          conn_count += 1;
          if(new_client.fd > max_fd){
            max_fd = new_client.fd;
          }
          connect_event(new_client.fd, new_client.addr);
        }
      }
      else{
        for(i=0; i<conn_count; i++){
          if(FD_ISSET(connections[i], &fds)){
            //read
          }
        }
      }
    }
  }
}

//things we need:
//  accepting (connectevent, fd_add)
//  console (fgets, echo for now)
//  input (read, control event)
//  disconnect (read 0, disconnevent, close, fd_clear)
//  timer (wakeup, time until next event)
