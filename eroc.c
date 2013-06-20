#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

#include <lua.h>

#include <clock.h>
#include <net.h>
#include <log.h>

/*
these functions may be called by lua code and will all
be registered in the kernel environment
*/

int c_clock(lua_State* L){
  double ts = timestamp();
  lua_pushnumber(L, ts);
  return 1;
}

int c_poweroff(lua_State* L){
  write_log("script executed c_poweroff\n");
  raise(SIGINT);
  return 0; /* never occurs */
}

int c_kick(lua_State* L){ /* fd */
  int fd;

  if(lua_gettop(L) == 0){
    fprintf(stderr, "c_kick called with no argument\n");
  }
  else if(!lua_isnumber(L, -1)){
    fprintf(
      stderr,
      "c_kick used with unexpected type (%s)\n",
      lua_typename(L, lua_type(L, -1))
    );
  }
  else{
    fd = lua_tointeger(L, -1);
    write_log("c_kick on socket %d requested\n", fd);
    disconnect(fd);
  }

  return 0;
}

int c_checkpoint(lua_State* L){
  // checkpoint the state log
  return 0;
}

int c_log(lua_State* L){ /* text */
  const char* text;

  if(lua_gettop(L) == 0){
    fprintf(stderr, "c_log used with no argument\n");
  }
  else if(!lua_isstring(L, -1)){
    fprintf(
      stderr,
      "c_log used with unexpected type (%s)\n",
      lua_typename(L, lua_type(L, -1))
    );
  }
  else{
    text = lua_tostring(L, -1);
    write_log("%s", text);
  }

  return 0;
}

int c_send(lua_State* L){ /* fd, data */
  int fd;
  const char* data;
  size_t len;
  int argc = lua_gettop(L);

  if(argc < 2){
    fprintf(stderr, "c_send called with incorrect number of arguments (%d)\n", argc);
  }
  else if(!lua_isnumber(L, 1)){
    fprintf(
      stderr,
      "c_send first argument has incorrect type (%s)\n",
      lua_typename(L, lua_type(L, 1))
    );
  }
  else if(!lua_isstring(L, 2)){
    fprintf(
      stderr,
      "c_send second argument has incorrect type (%s)\n",
      lua_typename(L, lua_type(L, 2))
    );
  }
  else{
    data = lua_tolstring(L, 2, &len);
    fd = lua_tointeger(L, 1);
    net_send(fd, data, len);
  }

  return 0;
}

