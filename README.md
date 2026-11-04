# ASSOCIATED — VR Modding Framework

> **Scope:** This repository contains source modules and a packaging workflow for authorized development and testing in an experience you own or have explicit permission to modify.

## Important compatibility notice

This repository does **not** produce a modified Roblox application, inject Lua into the Roblox Android client, decompile or rebuild Roblox's production APK, alter Roblox signatures, or bypass client integrity checks. The GitHub Actions workflow packages the source framework only. The APK check is an input-validation gate for an authorized test APK; the APK is not modified or redistributed by this workflow.

This is not a Roblox Studio project template and it is not a standalone Roblox game. The Lua modules are source components intended to be integrated into an experience through its authorized development workflow. They do not run as arbitrary scripts inside the official Roblox mobile application.

## Repository layout

```text
.github/workflows/build.yml
RBLX_APK/                 # Place one authorized test APK here for input validation
mods/
  MenuUI.lua              # ASSOCIATED developer menu controller scaffold
  Movement.lua            # Movement feature registration and safe hooks
  Physics.lua             # Physics feature registration and safe hooks
  Visuals.lua             # Visual feature registration and safe hooks
framework/
  Registry.lua
  Settings.lua
res/
  drawable/splash.xml
  mipmap/icon.svg
```

## Build

1. Put exactly one APK that you are authorized to test in `RBLX_APK/`.
2. Push to `main`, or open **Actions → ASSOCIATED Framework Build → Run workflow**.
3. If the APK is missing, the workflow stops with a clear error. If multiple APKs are present, it also stops.
4. Download the `ASSOCIATED-Framework` artifact from the completed run.

The workflow packages the Lua source and assets into `ASSOCIATED-Framework.zip` and generates SHA-256 checksums. It intentionally does not decompile, patch, inject into, sign, or rebuild the Roblox APK.

## Integration

Integrate modules only through supported APIs in an experience you control. Keep privileged operations server-authoritative, validate remote requests on the server, and restrict developer controls to explicitly authorized test users. Client-only toggles are not security boundaries.

## Features represented by the module scaffolds

- ASSOCIATED category menu structure
- Movement feature registry and input hooks
- Physics feature registry
- Visual settings registry
- Extensible feature registration

The scaffolds do not implement cheats for a third-party live client, arbitrary code injection, anti-cheat evasion, or unauthorized ESP/No-Clip.

## Branding

The SVG icon uses an original tilted-square game mark paired with an **M**. It is Roblox-inspired but is not an official Roblox logo or endorsement.

## Risk notice

Modifying or redistributing the official Roblox application can violate platform terms, break updates, expose devices to untrusted code, or result in account enforcement. Use only authorized test builds and accounts. No account-safety guarantee is made.
