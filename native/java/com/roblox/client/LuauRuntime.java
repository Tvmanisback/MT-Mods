package com.roblox.client;

/**
 * Thin Java owner for the embedded Luau VM.
 * The host application must call this class from its own startup flow.
 */
public final class LuauRuntime implements AutoCloseable {
    static {
        System.loadLibrary("mtluau");
    }

    private long handle;

    public LuauRuntime() {
        handle = nativeCreate();
        if (handle == 0) {
            throw new IllegalStateException("Could not create Luau state");
        }
    }

    public synchronized String execute(String source) {
        if (handle == 0) {
            return "Luau runtime is closed.";
        }
        return nativeExecute(handle, source == null ? "" : source);
    }

    @Override
    public synchronized void close() {
        if (handle != 0) {
            nativeDestroy(handle);
            handle = 0;
        }
    }

    private static native long nativeCreate();
    private static native String nativeExecute(long handle, String source);
    private static native void nativeDestroy(long handle);
}
