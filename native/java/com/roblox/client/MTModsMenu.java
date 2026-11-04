package com.roblox.client;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import java.util.LinkedHashMap;
import java.util.Map;

/** Small in-client menu for the single MT-Mods target experience. */
public final class MTModsMenu {
    private static final String PREFS = "mt_mods_single_game";
    private static final Map<String, String> FEATURES = new LinkedHashMap<>();
    static {
        FEATURES.put("Speed Boost", "Movement");
        FEATURES.put("Air Control", "Movement");
        FEATURES.put("Dash", "Movement");
        FEATURES.put("Bunny Hop", "Movement");
        FEATURES.put("Low Gravity", "Physics");
        FEATURES.put("Fullbright", "Visuals");
        FEATURES.put("FOV Override", "Visuals");
    }

    private MTModsMenu() {}\n    private static MTModsScriptLoader scriptLoader;

    public static void install(Activity activity) {
        if (activity == null || activity.isFinishing()) return;
        activity.runOnUiThread(() -> {
            try {
                if (scriptLoader == null) {
                    scriptLoader = new MTModsScriptLoader(activity);
                    String bootError = scriptLoader.load("bootstrap.lua");
                    if (!bootError.isEmpty()) android.util.Log.e("MT-Mods", bootError);
                }
                attach(activity);
            } catch (Throwable error) {
                android.util.Log.e("MT-Mods", "Script host startup failed", error);
                attach(activity);
            }
        });
    }

    private static GradientDrawable shape(int color, int radius) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(radius);
        d.setStroke(1, Color.argb(70, 180, 205, 255));
        return d;
    }

    private static TextView label(Context c, String text, int size) {
        TextView v = new TextView(c);
        v.setText(text);
        v.setTextColor(Color.WHITE);
        v.setTextSize(size);
        v.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        return v;
    }

    private static void attach(Activity a) {
        try {
            View decor = a.getWindow().getDecorView();
            if (!(decor instanceof ViewGroup)) return;
            ViewGroup root = (ViewGroup) decor;
            if (root.findViewWithTag("mtmods-root") != null) return;

            FrameLayout layer = new FrameLayout(a);
            layer.setTag("mtmods-root");
            layer.setClipChildren(false);
            layer.setClipToPadding(false);

            Button opener = new Button(a);
            opener.setText("MT");
            opener.setTextColor(Color.WHITE);
            opener.setTextSize(15);
            opener.setAllCaps(false);
            opener.setBackground(shape(Color.rgb(35, 105, 190), 48));
            FrameLayout.LayoutParams op = new FrameLayout.LayoutParams(dp(a, 58), dp(a, 58), Gravity.RIGHT | Gravity.CENTER_VERTICAL);
            op.rightMargin = dp(a, 18);
            layer.addView(opener, op);

            LinearLayout panel = new LinearLayout(a);
            panel.setOrientation(LinearLayout.VERTICAL);
            panel.setPadding(dp(a, 16), dp(a, 14), dp(a, 16), dp(a, 14));
            panel.setBackground(shape(Color.rgb(17, 24, 38), 18));
            panel.setElevation(dp(a, 14));
            panel.setVisibility(View.GONE);
            FrameLayout.LayoutParams pp = new FrameLayout.LayoutParams(dp(a, 300), ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.RIGHT | Gravity.CENTER_VERTICAL);
            pp.rightMargin = dp(a, 86);
            layer.addView(panel, pp);

            panel.addView(label(a, "MT-MODS  •  GAME MENU", 17), new LinearLayout.LayoutParams(-1, dp(a, 34)));
            TextView subtitle = new TextView(a);
            subtitle.setText("Single-game feature controls");
            subtitle.setTextColor(Color.LTGRAY);
            subtitle.setTextSize(12);
            panel.addView(subtitle, new LinearLayout.LayoutParams(-1, dp(a, 26)));

            for (Map.Entry<String, String> feature : FEATURES.entrySet()) {
                String key = feature.getKey();
                boolean enabled = a.getSharedPreferences(PREFS, 0).getBoolean(key, false);
                Button toggle = new Button(a);
                toggle.setAllCaps(false);
                toggle.setText(key + "     " + (enabled ? "ON" : "OFF"));
                toggle.setTextSize(13);
                toggle.setTextColor(Color.WHITE);
                toggle.setBackground(shape(enabled ? Color.rgb(30, 125, 91) : Color.rgb(48, 61, 82), 10));
                LinearLayout.LayoutParams row = new LinearLayout.LayoutParams(-1, dp(a, 43));
                row.topMargin = dp(a, 5);
                panel.addView(toggle, row);
                toggle.setOnClickListener(v -> {
                    boolean next = !a.getSharedPreferences(PREFS, 0).getBoolean(key, false);
                    a.getSharedPreferences(PREFS, 0).edit().putBoolean(key, next).apply();
                    toggle.setText(key + "     " + (next ? "ON" : "OFF"));
                    toggle.setBackground(shape(next ? Color.rgb(30, 125, 91) : Color.rgb(48, 61, 82), 10));
                    Toast.makeText(a, key + (next ? " enabled" : " disabled"), Toast.LENGTH_SHORT).show();
                });
            }

            Button close = new Button(a);
            close.setText("Close");
            close.setAllCaps(false);
            close.setTextColor(Color.WHITE);
            close.setBackground(shape(Color.rgb(75, 83, 101), 10));
            LinearLayout.LayoutParams closeLp = new LinearLayout.LayoutParams(-1, dp(a, 42));
            closeLp.topMargin = dp(a, 8);
            panel.addView(close, closeLp);
            opener.setOnClickListener(v -> panel.setVisibility(panel.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE));
            close.setOnClickListener(v -> panel.setVisibility(View.GONE));
            root.addView(layer, new ViewGroup.LayoutParams(-1, -1));
        } catch (Throwable ignored) {
            // Optional menu must never prevent the game activity from starting.
        }
    }

    private static int dp(Context c, int value) {
        return (int) (value * c.getResources().getDisplayMetrics().density + 0.5f);
    }
}