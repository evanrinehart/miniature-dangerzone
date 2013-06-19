struct connection {
  int fd;
  char addr[256];
};

void listen_on(int port);
void disconnect(int client);
void net_close(void);
int get_server_fd(void);
struct connection get_new_connection(void);
