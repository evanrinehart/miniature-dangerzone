#include <stdlib.h>
#include <lua.h>
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

  error = luaL_dofile(L, "main.lua");
  if(error){
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
    exit(1);
  }
}

void lua_close_(){
  lua_close(L);
}
