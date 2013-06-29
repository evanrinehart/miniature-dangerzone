#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <eroc.h>
#include <clock.h>

static lua_State* L;

void lua_init(){
  int error;

  L = luaL_newstate();
  if(L == NULL){
    fprintf(stderr, "luaL_newstate failed\n");
    exit(1);
  }

  luaL_openlibs(L);

  lua_register(L, "c_send", c_send);
  lua_register(L, "c_log", c_log);
  lua_register(L, "c_kick", c_kick);
  lua_register(L, "c_checkpoint", c_checkpoint);
  lua_register(L, "c_poweroff", c_poweroff);
  lua_register(L, "c_clock", c_clock);
  lua_register(L, "c_dir", c_dir);

  error = luaL_dofile(L, "kernel.lua");
  if(error){
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    exit(1);
  }

}

void lua_close_(){
  lua_close(L);
}


void connect_signal(int fd, const char* addr){
  int error;

  lua_getglobal(L, "connect_signal");
  lua_pushinteger(L, fd);
  lua_pushstring(L, addr);
  error = lua_pcall(L, 2, 0, 0);
  if(error){
    fprintf(stderr, "%s", lua_tostring(L, -1));
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }
}

void disconnect_signal(int fd){
  int error;

  lua_getglobal(L, "disconnect_signal");
  lua_pushinteger(L, fd);
  error = lua_pcall(L, 1, 0, 0);
  if(error){
    fprintf(stderr, "%s", lua_tostring(L, -1));
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }
}

int wake_signal(unsigned* output){
  double micro;
  int error;

  double now = timestamp();

  lua_getglobal(L, "wake_signal");
  lua_pushnumber(L, now);
  error = lua_pcall(L, 1, 1, 0);
  if(error){
    fprintf(stderr, "%s", lua_tostring(L, -1));
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }

  if(lua_isnil(L, -1)){
    return 1;
  }
  else if(!lua_isnumber(L, -1)){
    fprintf(
      stderr,
      "wake_event returned unexpected type (%s)\n",
      lua_typename(L, lua_type(L, -1))
    );
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }
  else{
    micro = lua_tonumber(L, -1);
    lua_pop(L, 1);

    *output = micro > UINT_MAX ? UINT_MAX : micro;
    return 0;
  }

}

void control_signal(int fd, const char* text){
  int error;

  lua_getglobal(L, "control_signal");
  lua_pushinteger(L, fd);
  lua_pushstring(L, text);
  error = lua_pcall(L, 2, 0, 0);
  if(error){
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }
}

void boot_signal(){
  int error;
  lua_getglobal(L, "boot_signal");
  error = lua_pcall(L, 0, 0, 0);
  if(error){
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
    exit(EXIT_FAILURE);
  }
}
