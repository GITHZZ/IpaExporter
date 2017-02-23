//
//  LuaException.h
//  IpaExporter
//
//  Created by 何遵祖 on 2016/9/6.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#ifndef LuaException_h
#define LuaException_h

#include <stdio.h>
#include <setjmp.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

//result code
#define LUA_DLL_OK 10000
#define LUA_DLL_UNKNOW_FAIL 10001 //发生未知错误
#define LUA_DLL_UNEXPECTED 10002 //异常
#define LUA_DLL_MEMORY_OUT 10003 //内存不足
#define LUA_DLL_ERROR 10004 //发生编译错误
#define LUA_DLL_MEMORY_ERROR 10005 //访问内存错误

//try .. catch
#define TRY do{jmp_buf buf; if(!setjmp(buf)){
#define CATCH }else{
#define END_TRY } }while(0)
#define THROW longjmp(buf, 1)

const char* get_error_description(lua_State* L, int code);

#endif /* LuaException_h */
