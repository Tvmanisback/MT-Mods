-- ASSOCIATED FeaturePack
-- Local-player mechanics for a client/experience where client-side mods are permitted.
-- All effects are local to the player running this module.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local FeaturePack = {}
FeaturePack.__index = FeaturePack

local TARGET_UNIVERSE_ID = 76028293692604

function FeaturePack.new(options)
    options = options or {}
    local self = setmetatable({}, FeaturePack)
    self.Player = Players.LocalPlayer
    self.TargetUniverseId = options.TargetUniverseId or TARGET_UNIVERSE_ID
    self.Enabled = {}
    self.Connections = {}
    self.Objects = {}
    self.Originals = {}
    self.Destroyed = false
    self._lastJump = 0
    self._lastDash = 0
    return self
end

function FeaturePack:_character()
    return self.Player and self.Player.Character
end

function FeaturePack:_humanoid()
    local character = self:_character()
    return character and character:FindFirstChildOfClass("Humanoid")
end

function FeaturePack:_root()
    local character = self:_character()
    return character and character:FindFirstChild("HumanoidRootPart")
end

function FeaturePack:_set(name, value)
    self.Enabled[name] = value == true
end

function FeaturePack:_makePlatform()
    if self.Objects.Platform then return end
    local part = Instance.new("Part")
    part.Name = "ASSOCIATED_LocalPlatform"
    part.Size = Vector3.new(5, 0.35, 5)
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.ForceField
    part.Transparency = 0.25
    part.Parent = Workspace
    self.Objects.Platform = part
end

function FeaturePack:_removePlatform()
    if self.Objects.Platform then
        self.Objects.Platform:Destroy()
        self.Objects.Platform = nil
    end
end

function FeaturePack:_setHighlight(name, enabled)
    if enabled then
        if self.Objects[name] then return end
        local folder = Instance.new("Folder")
        folder.Name = "ASSOCIATED_" .. name
        folder.Parent = Workspace
        self.Objects[name] = folder

        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "DebugBounds"
                highlight.Adornee = player.Character
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.fromRGB(65, 190, 255)
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = folder
            end
        end
    elseif self.Objects[name] then
        self.Objects[name]:Destroy()
        self.Objects[name] = nil
    end
end

function FeaturePack:_applySpeed(enabled)
    local humanoid = self:_humanoid()
    if not humanoid then return end
    if enabled then
        if self.Originals.WalkSpeed == nil then
            self.Originals.WalkSpeed = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = 28
    elseif self.Originals.WalkSpeed ~= nil then
        humanoid.WalkSpeed = self.Originals.WalkSpeed
        self.Originals.WalkSpeed = nil
    end
end

function FeaturePack:_applyJump(enabled)
    local humanoid = self:_humanoid()
    if not humanoid then return end
    if enabled then
        if self.Originals.JumpPower == nil then
            self.Originals.JumpPower = humanoid.JumpPower
            self.Originals.JumpHeight = humanoid.JumpHeight
            self.Originals.UseJumpPower = humanoid.UseJumpPower
        end
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 62
    elseif self.Originals.JumpPower ~= nil then
        humanoid.UseJumpPower = self.Originals.UseJumpPower
        humanoid.JumpPower = self.Originals.JumpPower
        humanoid.JumpHeight = self.Originals.JumpHeight
        self.Originals.JumpPower = nil
        self.Originals.JumpHeight = nil
        self.Originals.UseJumpPower = nil
    end
end

function FeaturePack:_flyStep()
    local root = self:_root()
    local camera = Workspace.CurrentCamera
    if not root or not camera then return end

    local direction = Vector3.zero
    local humanoid = self:_humanoid()
    if humanoid then direction = humanoid.MoveDirection end

    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical += 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical -= 1 end

    local velocity = direction * 38 + Vector3.new(0, vertical * 28, 0)
    root.AssemblyLinearVelocity = velocity
end

function FeaturePack:_dash()
    local root = self:_root()
    local camera = Workspace.CurrentCamera
    if not root or not camera then return end
    local now = os.clock()
    if now - self._lastDash < 0.8 then return end
    self._lastDash = now

    local direction = camera.CFrame.LookVector
    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude < 0.05 then return end
    root.AssemblyLinearVelocity = flat.Unit * 68 + Vector3.new(0, 12, 0)
end

function FeaturePack:_tick()
    if self.Destroyed then return end
    if self.Enabled.Fly then self:_flyStep() end

    local root = self:_root()
    if root and self.Enabled.Plats then
        self:_makePlatform()
        self.Objects.Platform.CFrame = CFrame.new(root.Position - Vector3.new(0, 3.5, 0))
    end

    if root and self.Enabled.WallGlide then
        local humanoid = self:_humanoid()
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { self:_character() }
            local hit = Workspace:Raycast(root.Position, humanoid.MoveDirection.Unit * 2.5, params)
            if hit then
                local velocity = root.AssemblyLinearVelocity
                if velocity.Y < -8 then
                    root.AssemblyLinearVelocity = Vector3.new(velocity.X, -8, velocity.Z)
                end
            end
        end
    end

    if root and self.Enabled.AirControl then
        local humanoid = self:_humanoid()
        if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
            local move = humanoid.MoveDirection
            local velocity = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(
                velocity.X + move.X * 1.2,
                velocity.Y,
                velocity.Z + move.Z * 1.2
            )
        end
    end

    if root and self.Enabled.BunnyHop then
        local humanoid = self:_humanoid()
        if humanoid and humanoid.MoveDirection.Magnitude > 0
            and humanoid.FloorMaterial ~= Enum.Material.Air
            and os.clock() - self._lastJump > 0.16 then
            self._lastJump = os.clock()
            humanoid.Jump = true
        end
    end
end

function FeaturePack:_setGravity(enabled)
    if enabled then
        if self.Originals.Gravity == nil then
            self.Originals.Gravity = Workspace.Gravity
        end
        Workspace.Gravity = 110
    elseif self.Originals.Gravity ~= nil then
        Workspace.Gravity = self.Originals.Gravity
        self.Originals.Gravity = nil
    end
end

function FeaturePack:_setFullbright(enabled)
    if enabled then
        if self.Originals.Lighting == nil then
            self.Originals.Lighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
        end
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(190, 190, 190)
        Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
    elseif self.Originals.Lighting then
        for property, value in pairs(self.Originals.Lighting) do
            Lighting[property] = value
        end
        self.Originals.Lighting = nil
    end
end

function FeaturePack:_setFov(enabled)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    if enabled then
        if self.Originals.FieldOfView == nil then
            self.Originals.FieldOfView = camera.FieldOfView
        end
        camera.FieldOfView = 90
    elseif self.Originals.FieldOfView ~= nil then
        camera.FieldOfView = self.Originals.FieldOfView
        self.Originals.FieldOfView = nil
    end
end

function FeaturePack:_handler(name)
    return function(enabled)
        self:_set(name, enabled)
        if name == "SpeedBoost" then self:_applySpeed(enabled)
        elseif name == "BunnyHop" then self:_applyJump(enabled)
        elseif name == "Plats" and not enabled then self:_removePlatform()
        elseif name == "GravityScale" then self:_setGravity(enabled)
        elseif name == "CollisionDebug" then self:_setHighlight("CollisionDebug", enabled)
        elseif name == "PlayerBoundsDebug" then self:_setHighlight("PlayerBoundsDebug", enabled)
        elseif name == "Fullbright" then self:_setFullbright(enabled)
        elseif name == "FieldOfView" then self:_setFov(enabled)
        elseif name == "LongArms" then
            -- R15 scale values are applied only when the avatar exposes the matching scale values.
            local character = self:_character()
            local scale = character and character:FindFirstChild("BodyHeightScale")
            if scale and scale:IsA("NumberValue") then
                if enabled then
                    self.Originals.BodyHeightScale = scale.Value
                    scale.Value = math.max(scale.Value, 1.15)
                elseif self.Originals.BodyHeightScale then
                    scale.Value = self.Originals.BodyHeightScale
                    self.Originals.BodyHeightScale = nil
                end
            end
        elseif name == "Dash" and enabled then
            self:_dash()
        elseif name == "Fly" and not enabled then
            local root = self:_root()
            if root then
                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
            end
        elseif name == "PlatformSupport" then
            if enabled then self:_makePlatform() else self:_removePlatform() end
        end
        return true
    end
end

function FeaturePack:Register(registry)
    assert(game.GameId == self.TargetUniverseId,
        "ASSOCIATED features are restricted to universe " .. tostring(self.TargetUniverseId))

    local handlers = {}
    local definitions = {
        { "SpeedBoost", "Movement", "Increase local walk speed." },
        { "Fly", "Movement", "Move freely in the air; Space/Ctrl change height." },
        { "LongArms", "Movement", "Adjust supported avatar body scale." },
        { "Plats", "Movement", "Spawn a local platform beneath your character." },
        { "BunnyHop", "Movement", "Automatically jump while moving." },
        { "AirControl", "Movement", "Steer more strongly while airborne." },
        { "Dash", "Movement", "Perform a forward dash when enabled." },
        { "WallGlide", "Movement", "Reduce downward speed near walls." },
        { "CollisionDebug", "Physics", "Show local debug outlines on player characters." },
        { "GravityScale", "Physics", "Adjust local workspace gravity." },
        { "PlatformSupport", "Physics", "Toggle the local support platform." },
        { "Fullbright", "Visuals", "Brighten the local scene." },
        { "FieldOfView", "Visuals", "Set the local camera field of view to 90." },
        { "PlayerBoundsDebug", "Visuals", "Outline player characters for debugging." },
    }

    for _, item in ipairs(definitions) do
        local name, category, description = item[1], item[2], item[3]
        handlers[name] = self:_handler(name)
        registry:Register(name, category, description, handlers[name])
    end

    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:_tick()
    end))

    table.insert(self.Connections, self.Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if self.Enabled.SpeedBoost then self:_applySpeed(true) end
        if self.Enabled.BunnyHop then self:_applyJump(true) end
    end))

    return handlers
end

function FeaturePack:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true

    for name in pairs(self.Enabled) do
        self.Enabled[name] = false
    end
    self:_applySpeed(false)
    self:_applyJump(false)
    self:_setGravity(false)
    self:_setFullbright(false)
    self:_setFov(false)
    self:_removePlatform()
    self:_setHighlight("CollisionDebug", false)
    self:_setHighlight("PlayerBoundsDebug", false)

    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    table.clear(self.Connections)

    for name, object in pairs(self.Objects) do
        if typeof(object) == "Instance" then object:Destroy() end
        self.Objects[name] = nil
    end
end

return FeaturePack
