#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include <net.h>
#include <log.h>

static int server;

// to start a listening socket the steps are:
// s = socket()
// bind(s)
// listen(s)
// c = accept(s) (eventually)
void listen_on(int port){
  struct sockaddr_in addr;

  server = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  
  if(server == -1){
    perror("socket");
    exit(EXIT_FAILURE);
  }

  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = htonl(INADDR_ANY);

  if(bind(server, (struct sockaddr*)&addr, sizeof(addr)) == -1){
    perror("bind");
    close(server);
    exit(EXIT_FAILURE);
  }

  if(listen(server, 10) == -1){
    perror("listen");
    close(server);
    exit(EXIT_FAILURE);
  }
}

void disconnect(int client){
  write_log("disconnecting peer %d ... \n", client);

  if(shutdown(client, SHUT_RDWR) == -1){
    perror("shutdown");
    exit(EXIT_FAILURE);
  }
}

void net_close(){
  close(server);
}

int get_server_fd(){
  return server;
}

struct connection get_new_connection(){
  struct connection conn;
  int client;

  // TODO get address
  client = accept(server, NULL, NULL);

  conn.fd = client;
  strcpy(conn.addr, "unknown-address");

  return conn;
}

int net_send(int fd, const char* data, size_t size){
  return send(fd, data, size, 0);
}
