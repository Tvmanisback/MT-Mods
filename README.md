# ASSOCIATED — VR Modding Framework

> **Scope:** Source modules and packaging tools for authorized development and testing in an experience or client you own or have explicit permission to modify.

## Build workflow

The GitHub Actions workflow downloads the decoded project archive from the repository's `Test` release:

`roblox-apk-full-decode.zip`

It validates that the archive contains an Apktool decoded tree (including `AndroidManifest.xml` and `apktool.yml`), records its SHA-256 checksum and file count, and packages this repository's mod source and visual resources into `ASSOCIATED-Modding-Kit.zip`.

To run it:

1. Open **Actions → ASSOCIATED Modding Package Build**.
2. Select **Run workflow**.
3. Download the `ASSOCIATED-Modding-Package` artifact when the run completes.

The workflow currently produces a validated-input report and a separate source/assets package. It does not merge Lua files into the decoded app, modify DEX/Smali, sign an APK, or output a rebuilt installable APK. Those steps require the actual custom-client source and a documented integration interface; the decoded archive alone does not establish that interface.

## Repository layout

```text
.github/workflows/build.yml
mods/
  MenuUI.lua
  Movement.lua
  Physics.lua
  Visuals.lua
framework/
  Registry.lua
  Settings.lua
res/
  drawable/splash.xml
  mipmap/icon.svg
```

## Framework modules

- ASSOCIATED category menu structure
- Movement feature registry and input hooks
- Physics feature registry
- Visual settings registry
- Extensible feature registration

The Lua files are source modules, not a standalone APK runtime. Integrate them through APIs provided by a client or experience you control. Keep privileged operations server-authoritative and restrict developer controls to explicitly authorized test users.

## Branding

The SVG icon uses an original tilted-square game mark paired with an **M**. It is Roblox-inspired but is not an official Roblox logo or endorsement.
