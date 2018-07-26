// lua registry table

#include <stdlib.h>
#include <lua.hpp>
#include <lualib.h>
#include <lauxlib.h>

/*
Foo.lua
function foo()
    print("hello world")
end
*/


int main()
{
    lua_State *L = luaL_newstate();  
    luaL_openlibs(L);
    luaL_dofile(L,"Foo.lua");
    lua_getglobal(L,"foo");
    printf("stack size:%d,%d\n",lua_gettop(L),lua_type(L,-1));
    // 存放函数到注册表中并返回引用
    int ref =  luaL_ref(L,LUA_REGISTRYINDEX);
    printf("stack size:%d\n",lua_gettop(L));

   // 从注册表中读取该函数并调用
    lua_rawgeti(L,LUA_REGISTRYINDEX,ref);
    printf("stack size:%d,%d\n",lua_gettop(L),lua_type(L,-1));
   
    //printf("stack size:%d,%d\n",lua_gettop(L),lua_type(L,-1));
    lua_pcall(L,0,0,0);
    printf("stack size:%d\n",lua_gettop(L));
    printf("------------------------华丽的分割线------------\n");

    lua_getglobal(L,"foo");
    printf("stack size:%d\n",lua_gettop(L));
    lua_setfield(L,LUA_REGISTRYINDEX,"sb");
    printf("stack size:%d\n",lua_gettop(L));
    lua_getfield(L,LUA_REGISTRYINDEX,"sb");
    lua_pcall(L,0,0,0);
    printf("------------------------又一次华丽的分割线------------\n");
    printf("stack size:%d,%d\n",lua_gettop(L),lua_type(L,-1));
    luaL_unref(L,LUA_REGISTRYINDEX,ref);
    lua_rawgeti(L,LUA_REGISTRYINDEX,ref);
    printf("stack size:%d\n",lua_gettop(L));
    lua_getfield(L,LUA_REGISTRYINDEX,"sb");
    lua_pcall(L,0,0,0);
    lua_close(L);

   return 0;
}

/*
[root@localhost testLua]# g++ -g luaRef.cpp -ldl -llua 
[root@localhost testLua]# ./a.out 
stack size:1,6
stack size:0
stack size:1,6
hello world
stack size:0
------------------------华丽的分割线------------
stack size:1
stack size:0
hello world
------------------------又一次华丽的分割线------------
stack size:0,0
stack size:1
hello world

4.1：从程序的运行结果可以知道：luaL_ref返回一个int的值ref。ref这个值就是对应的value(foo函数)的key，
通过API方法    lua_rawgeti(L,LUA_REGISTRYINDEX,ref);可以从注册表获取到对应的value（foo函数）。
一旦ref在注册表的引用解除，就无法继续通过ref这个引用获取到value(即foo函数)。



4.2：如果想在c模块之间通过ref来引用到value(即foo函数)。也是可以的。但是c模块之间必须共享ref的值。
这里就不写测试用例了。



4.3：注册表的key也可以C/C++静态变量地址作为key；C连接器可以确保这个key在整个注册表中的唯一性。

static int i =0;

lua_pushlightuserdata(L, (void*) &i) ;  /**取静态变量i的地址作为key压栈**/
/*
lua_pushInteger(L, "value");   /**把值压栈**/
/*
lua_settable(L, LUA_REGISTERINDEX); /** &i, value出栈；并且实现register[&i] = value**/


/*
lua_pushlightuserdata(L, (void*) &i) ;  /**取静态变量i的地址作为key压栈**/
/*
lua_gettable(L, LUA_REGISTERINDEX); /**获取value值，如果函数调用成功，那么value目前在栈顶**/
/*
const char* str = lua_tostring(L,-1);

load (chunk [, chunkname [, mode [, env]]])
加载一个代码块。

如果 chunk 是一个字符串，代码块指这个字符串。 如果 chunk 是一个函数， load 不断地调用它获取代码块的片断。 
每次对 chunk 的调用都必须返回一个字符串紧紧连接在上次调用的返回串之后。 当返回空串、nil、或是不返回值时，都表示代码块结束。

如果没有语法错误， 则以函数形式返回编译好的代码块； 否则，返回 nil 加上错误消息。

如果结果函数有上值， env 被设为第一个上值。 若不提供此参数，将全局环境替代它。 所有其它上值初始化为 nil。 
（当你加载主代码块时候，结果函数一定有且仅有一个上值 _ENV （参见 §2.2））。 然而，如果你加载一个用函数（参见 string.dump， 结果函数可以有任意数量的上值）
 创建出来的二进制代码块时，所有的上值都是新创建出来的。 也就是说它们不会和别的任何函数共享。

chunkname 在错误消息和调试消息中（参见 §4.9），用于代码块的名字。 如果不提供此参数，它默认为字符串chunk 。 chunk 不是字符串时，则为 "=(load)" 。

字符串 mode 用于控制代码块是文本还是二进制（即预编译代码块）。 它可以是字符串 "b" （只能是二进制代码块）， "t" （只能是文本代码块）， 或 "bt" （可以是二进制也可以是文本）。
 默认值为 "bt"。

Lua 不会对二进制代码块做健壮性检查。 恶意构造一个二进制块有可能把解释器弄崩溃。

loadfile ([filename [, mode [, env]]])
和 load 类似， 不过是从文件 filename 或标准输入（如果文件名未提供）中获取代码块。

*/