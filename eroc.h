int c_clock(lua_State* L);
int c_poweroff(lua_State* L);
int c_kick(lua_State* L); /* fd */
int c_checkpoint(lua_State* L);
int c_log(lua_State* L); /* text */
int c_send(lua_State* L); /* fd, data */
