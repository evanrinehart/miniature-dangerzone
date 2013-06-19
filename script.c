#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static lua_State* L;

void lua_init(){
  int error;

  L = luaL_newstate();
  if(L == NULL){
    fprintf(stderr, "luaL_newstate failed\n");
    exit(1);
  }

  luaL_openlibs(L);

  error = luaL_dofile(L, "kernel.lua");
  if(error){
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    exit(1);
  }

  // TODO register the following lua_CFunctions:
  //   c_send(fd, string)
  //   c_log(format, ...)
  //   c_kick(fd)
  //   c_checkpoint()
  //   c_poweroff()
}

void lua_close_(){
  lua_close(L);
}


void connect_event(int fd, const char* addr){
  // TODO execute kernel.connect_event(fd, addr)
}

void disconnect_event(int fd){
  // TODO execute kernel.disconnect_event(fd)
}

unsigned wake_event(){
  double micro;
  micro = 234567; //TODO run kernel.wake_event
  return micro > UINT_MAX ? UINT_MAX : micro;
}

void control_event(int fd, const char* text){
  // TODO execute kernel control event(fd, text)
}
