# MT-Mods native Luau runtime

This directory builds a real Luau VM shared library for Android ARM64.

## JNI interface

The library exports methods for the Java class `com.tvman.mtmods.LuauRuntime`:

- `nativeCreate()`: create a Luau state and return its handle.
- `nativeExecute(handle, source)`: compile and execute a Luau chunk; returns an empty string on success or an error message.
- `nativeDestroy(handle)`: release the state.

The host app must load `mtluau` with `System.loadLibrary("mtluau")` and declare matching static native methods. This runtime executes standalone Luau. It does not automatically expose Roblox engine globals such as `game`, `Players`, `Workspace`, or `VRService`; those require explicit host-provided API bindings. No anti-cheat bypass or process injection is included.
