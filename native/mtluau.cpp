#include <jni.h>
#include <android/log.h>
#include <luacode.h>
#include <lua.h>
#include <lualib.h>
#include <mutex>
#include <string>
#include <unordered_set>

namespace {
constexpr const char* TAG = "MT-Luau";
std::mutex statesMutex;
std::unordered_set<lua_State*> states;

void logPrint(lua_State* L, const char* message, int length) {
    __android_log_write(ANDROID_LOG_INFO, TAG, std::string(message, length).c_str());
    (void)L;
}

int printCallback(lua_State* L) {
    const int count = lua_gettop(L);
    std::string line;
    for (int i = 1; i <= count; ++i) {
        size_t length = 0;
        const char* value = luaL_tolstring(L, i, &length);
        if (i > 1) line += "\t";
        if (value) line.append(value, length);
        lua_pop(L, 1);
    }
    logPrint(L, line.c_str(), static_cast<int>(line.size()));
    return 0;
}

lua_State* stateFrom(jlong handle) {
    auto* L = reinterpret_cast<lua_State*>(static_cast<intptr_t>(handle));
    std::lock_guard<std::mutex> lock(statesMutex);
    return states.count(L) ? L : nullptr;
}
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_tvman_mtmods_LuauRuntime_nativeCreate(JNIEnv*, jclass) {
    lua_State* L = luaL_newstate();
    if (!L) return 0;
    luaL_openlibs(L);
    lua_pushcfunction(L, printCallback, "print");
    lua_setglobal(L, "print");
    {
        std::lock_guard<std::mutex> lock(statesMutex);
        states.insert(L);
    }
    return static_cast<jlong>(reinterpret_cast<intptr_t>(L));
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_tvman_mtmods_LuauRuntime_nativeExecute(JNIEnv* env, jclass, jlong handle, jstring source) {
    lua_State* L = stateFrom(handle);
    if (!L || !source) return env->NewStringUTF("Luau state is not initialized.");
    const char* chars = env->GetStringUTFChars(source, nullptr);
    if (!chars) return env->NewStringUTF("Unable to read script text.");
    const std::string code(chars);
    env->ReleaseStringUTFChars(source, chars);

    const int loadStatus = luau_load(L, "MT-Mods", code.data(), code.size(), 0);
    if (loadStatus != 0) {
        const char* error = lua_tostring(L, -1);
        jstring result = env->NewStringUTF(error ? error : "Luau compile error.");
        lua_pop(L, 1);
        return result;
    }
    const int runStatus = lua_pcall(L, 0, 0, 0);
    if (runStatus != 0) {
        const char* error = lua_tostring(L, -1);
        jstring result = env->NewStringUTF(error ? error : "Luau runtime error.");
        lua_pop(L, 1);
        return result;
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL
Java_com_tvman_mtmods_LuauRuntime_nativeDestroy(JNIEnv*, jclass, jlong handle) {
    lua_State* L = stateFrom(handle);
    if (!L) return;
    {
        std::lock_guard<std::mutex> lock(statesMutex);
        states.erase(L);
    }
    lua_close(L);
}
