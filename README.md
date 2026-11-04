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
  VRWristMenu.lua
  FeaturePack.lua
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
- VR wrist-mounted SurfaceGui menu, following the left-hand pose
- Controller **Y** button toggle
- Universe-ID gate for `76028293692604`; it stays disabled in other experiences
- Local-player movement feature handlers
- Local physics and visual feature handlers
- Extensible feature registration

The Lua files are source modules, not a standalone APK runtime. Integrate them through APIs provided by a client or experience you control. Keep privileged operations server-authoritative and restrict developer controls to explicitly authorized test users.

## VR wrist menu integration

`mods/VRWristMenu.lua` creates a world-space panel attached to the left controller pose. Press **Y** on the gamepad to show or hide it. The module refuses to start unless VR is enabled and `game.GameId` equals the configured universe ID.

Example LocalScript (adjust the ModuleScript paths to match your project):

```lua
local Registry = require(script.Parent.framework.Registry)
local FeaturePack = require(script.Parent.mods.FeaturePack)
local WristMenu = require(script.Parent.mods.VRWristMenu)

local registry = Registry.new()
local features = FeaturePack.new({
    TargetUniverseId = 76028293692604,
})
features:Register(registry)

local menu, reason = WristMenu.Start({
    Registry = registry,
    TargetUniverseId = 76028293692604,
    OnFeatureChanged = function(feature, enabled, context)
        -- Connect only mechanics implemented and authorized by your host experience.
        print(feature.name, enabled)
    end,
})

if not menu then
    warn("ASSOCIATED VR menu did not start: " .. tostring(reason))
end
```

The menu and controller binding are implemented here. `mods/FeaturePack.lua` supplies local-player handlers for the listed movement, physics, and visual features. These are client-side effects; a multiplayer server may override or reject movement/physics changes. Long Arms depends on the avatar exposing an R15 scale value. Fly uses Space/Ctrl for vertical movement on keyboard; adapt those controls for your client's VR controller mapping. Call `features:Destroy()` when unloading the mod to restore saved local settings and remove its temporary objects.

## Branding

The SVG icon uses an original tilted-square game mark paired with an **M**. It is Roblox-inspired but is not an official Roblox logo or endorsement.
