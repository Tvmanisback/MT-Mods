package com.roblox.client;

import android.content.Context;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * Separate script loader for the single-game MT-Mods menu.
 * Scripts are bundled under assets/mt-mods/scripts and executed by the
 * embedded Luau VM. The MT API surface is deliberately explicit; it does
 * not pretend Roblox engine globals exist in a standalone VM.
 */
public final class MTModsScriptLoader implements AutoCloseable {
    private static final String TAG = "MT-Mods";
    private static final String ROOT = "mt-mods/scripts/";
    private final Context context;
    private final LuauRuntime runtime;
    private final Set<String> loaded = Collections.synchronizedSet(new HashSet<String>());

    public MTModsScriptLoader(Context context) {
        this.context = context.getApplicationContext();
        this.runtime = new LuauRuntime();
    }

    public synchronized String load(String fileName) {
        if (fileName == null || !fileName.matches("[A-Za-z0-9_-]+\\.lua")) {
            return "Invalid script filename.";
        }
        try {
            String source = readAsset(ROOT + fileName);
            String error = runtime.execute(source);
            if (error == null || error.isEmpty()) {
                loaded.add(fileName);
                Log.i(TAG, "Loaded " + fileName);
                return "";
            }
            Log.e(TAG, "Script failed: " + fileName + ": " + error);
            return error;
        } catch (IOException e) {
            return "Cannot read " + fileName + ": " + e.getMessage();
        }
    }

    public synchronized String runFeature(String feature, boolean enabled) {
        if (feature == null || !feature.matches("[A-Za-z0-9_ -]+")) {
            return "Invalid feature name.";
        }
        String file = feature.replace(' ', '_') + ".lua";
        try {
            String source = readAsset(ROOT + file);
            source = source.replace("{{FEATURE_ENABLED}}", enabled ? "true" : "false");
            String error = runtime.execute(source);
            if (error == null || error.isEmpty()) return "";
            return error;
        } catch (IOException e) {
            return "Missing feature script " + file + ": " + e.getMessage();
        }
    }

    public Set<String> getLoadedScripts() {
        synchronized (loaded) { return new HashSet<>(loaded); }
    }

    private String readAsset(String path) throws IOException {
        try (InputStream in = context.getAssets().open(path);
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[8192];
            int count;
            while ((count = in.read(buffer)) != -1) out.write(buffer, 0, count);
            return new String(out.toByteArray(), StandardCharsets.UTF_8);
        }
    }

    @Override public synchronized void close() {
        runtime.close();
        loaded.clear();
    }
}
