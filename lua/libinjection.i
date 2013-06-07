/* libinjection.i SWIG interface file */
%module libinjection
%{
#include "libinjection.h"

static char libinjection_lua_check_fingerprint(sfilter* sf, char ch, const char* s, size_t len)
{
    lua_State* L = (lua_State*) sf->userdata;
#if 1
    int i;
    int top = lua_gettop(L);
    for (i = 1; i <= top; i++) {  /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {

        case LUA_TSTRING:  /* strings */
            printf("%d `%s'\n", i,lua_tostring(L, i));
            break;

        case LUA_TBOOLEAN:  /* booleans */
            printf("%d %s\n", i, lua_toboolean(L, i) ? "true" : "false");
            break;

        case LUA_TNUMBER:  /* numbers */
            printf("%d %g\n", i, lua_tonumber(L, i));
            break;

        default:  /* other values */
            printf("%d, %s\n", i, lua_typename(L, t));
            break;

        }
        printf("  ");  /* put a separator */
    }
    printf("\n");  /* end the listing */

#endif
    char* luafunc = (char *)lua_tostring(L, 2);
    lua_getglobal(L, (char*) luafunc);
    SWIG_NewPointerObj(L, (void*)sf, SWIGTYPE_p_libinjection_sqli_state, 0);
    if (lua_pcall(L, 1, 1, 0)) {
        printf("Something bad happened");
    }
    //int issqli = lua_tonumber(L, -1);
    return 'X';
}
%}
%include "typemaps.i"


// The C functions all start with 'libinjection_' as a namespace
// We don't need this since it's in the libinjection table
// i.e. libinjection.libinjection_is_sqli --> libinjection.is_sqli
 //
%rename("%(strip:[libinjection_])s") "";

%typemap(in) (ptr_lookup_fn fn, void* userdata) {
    if (lua_isnil(L, 0)) {
        arg2 = NULL;
        arg3 = NULL;
    } else {
        arg2 = libinjection_lua_check_fingerprint;
        arg3 = (void *) L;
    }
 }


%typemap(out) stoken_t [ANY] {
    int i;
    lua_newtable(L);
    for (i = 0; i < $1_dim0; i++) {
        lua_pushnumber(L, i+1);
        SWIG_NewPointerObj(L, (void*)(& $1[i]), SWIGTYPE_p_stoken_t,0);
        lua_settable(L, -3);
    }
    SWIG_arg += 1;
}


%include "libinjection.h"
