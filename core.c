#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <sys/socket.h>

#include <net.h>
#include <script.h>
#include <log.h>

/*
core IO/time support

use select to multiplex the server socket, client connections,
the server stdin console, and the watchdog timer which drives
autonomous activity.

single threaded C
*/

#define MAX_CONNECTIONS 10000
#define BUF_SIZE 1024

void core_loop(){
  int connections[MAX_CONNECTIONS];
  int conn_count = 0;
  int ready;
  int i;
  struct connection new_client;
  fd_set fds;
  struct timeval timeout;
  int server = get_server_fd();
  int max_fd = server;
  char buf[BUF_SIZE];
  size_t n;
  int fd;
  unsigned micro;

  for(;;){
    FD_ZERO(&fds);
    FD_SET(server, &fds);
    for(i=0; i<conn_count; i++){
      FD_SET(connections[i], &fds);
    }

    micro = wake_event();
    timeout.tv_sec  = micro / 1000000;
    timeout.tv_usec = micro % 1000000;

    ready = select(max_fd+1, &fds, NULL, NULL, &timeout);

    if(ready == -1){
      perror("select");
      exit(EXIT_FAILURE);
    }
    else if(ready == 0){
      // do nothing
    }
    else{
      if(FD_ISSET(server, &fds)){
        new_client = get_new_connection();
        write_log("new connection (%d) from %s\n", new_client.fd, new_client.addr);
        if(conn_count == MAX_CONNECTIONS){
          write_log("too many connections, dropping %d!\n", new_client.fd);
          // TODO notify client before disconnecting him
          disconnect(new_client.fd);
        }
        else{
          connections[conn_count] = new_client.fd;
          conn_count += 1;
          if(new_client.fd > max_fd){
            max_fd = new_client.fd;;
          }
          connect_event(new_client.fd, new_client.addr);
        }
      }

      for(i=0; i<conn_count; i++){
        fd = connections[i];

        if(FD_ISSET(fd, &fds)){
          n = recv(fd, buf, BUF_SIZE, 0);

          if(n < BUF_SIZE){
            buf[n] = '\0';
          }
          else{
            buf[BUF_SIZE-1] = '\0';
          }

          if(n == 0){
            write_log("peer %d is now gone\n", fd);
            close(fd);
            disconnect_event(fd);
            connections[i] = connections[conn_count-1];
            conn_count -= 1;
          }
          else{
            control_event(fd, buf);
          }

        }
      }

    }
  }
}
