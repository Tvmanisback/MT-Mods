-- MT-Mods client bootstrap
-- This is the entry point for a client that supports loading LocalScripts/ModuleScripts.
-- Place this script beside the mods folder, with framework as a sibling of mods.
-- The APK asset bundle alone cannot execute this file without a Luau script host.

local TARGET_UNIVERSE_ID = 76028293692604

if game.GameId ~= TARGET_UNIVERSE_ID then
    warn("[MT-Mods] Disabled: unsupported universe " .. tostring(game.GameId))
    return
end

local Players = game:GetService("Players")
local VRService = game:GetService("VRService")

if not Players.LocalPlayer then
    warn("[MT-Mods] Waiting for a local player is not supported by this bootstrap context.")
    return
end

if not VRService.VREnabled then
    warn("[MT-Mods] VR is not enabled; MT-Mods was not started.")
    return
end

local root = script.Parent.Parent
local Registry = require(root.framework.Registry)
local FeaturePack = require(script.Parent.FeaturePack)
local WristMenu = require(script.Parent.VRWristMenu)

local registry = Registry.new()
local features = FeaturePack.new({
    TargetUniverseId = TARGET_UNIVERSE_ID,
})
features:Register(registry)

local menu, menuError = WristMenu.Start({
    Registry = registry,
    TargetUniverseId = TARGET_UNIVERSE_ID,
})

if not menu then
    features:Destroy()
    error("[MT-Mods] Wrist menu failed to start: " .. tostring(menuError))
end

local stopped = false
local function shutdown()
    if stopped then
        return
    end
    stopped = true
    menu:Destroy()
    features:Destroy()
    print("[MT-Mods] Unloaded.")
end

script.Destroying:Connect(shutdown)

print("[MT-Mods] Loaded all features and started the VR wrist menu.")
