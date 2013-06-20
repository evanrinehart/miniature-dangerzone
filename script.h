void lua_init(void);
void lua_close_(void);

void disconnect_signal(int fd);
void connect_signal(int fd, const char* addr);
unsigned wake_signal(void);
void control_signal(int fd, const char* text);
