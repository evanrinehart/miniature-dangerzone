void lua_init(void);
void lua_close_(void);

void disconnect_event(int fd);
void connect_event(int fd, const char* addr);
unsigned wake_event(void);

void control_event(int fd, const char* text);
