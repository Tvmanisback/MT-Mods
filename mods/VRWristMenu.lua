-- ASSOCIATED VR wrist menu
-- Place this ModuleScript in a client-accessible location in an experience/client
-- you own or are authorized to modify. This module uses public Roblox APIs only.
--
-- Usage:
-- local WristMenu = require(path.To.VRWristMenu)
-- local menu = WristMenu.Start({
--     Registry = registry,
--     TargetUniverseId = 76028293692604,
--     Context = {},
--     OnFeatureChanged = function(feature, enabled) ... end,
-- })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local Workspace = game:GetService("Workspace")

local WristMenu = {}
WristMenu.__index = WristMenu

local CATEGORIES = { "Movement", "Physics", "Visuals", "Extra Mods" }
local TARGET_UNIVERSE_ID = 76028293692604

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

function WristMenu.new(options)
    options = options or {}
    assert(options.Registry, "VRWristMenu requires Registry")

    local self = setmetatable({}, WristMenu)
    self.Registry = options.Registry
    self.Context = options.Context
    self.TargetUniverseId = options.TargetUniverseId or TARGET_UNIVERSE_ID
    self.OnFeatureChanged = options.OnFeatureChanged
    self.Open = false
    self.ActiveCategory = "Movement"
    self.Connections = {}
    self.Destroyed = false
    self.Player = Players.LocalPlayer
    self.GuiObjects = {}
    return self
end

function WristMenu:IsSupportedExperience()
    return game.GameId == self.TargetUniverseId
end

function WristMenu:_build()
    local anchor = make("Part", {
        Name = "ASSOCIATED_WristMenuAnchor",
        Size = Vector3.new(0.01, 0.01, 0.01),
        Transparency = 1,
        Anchored = true,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
        CastShadow = false,
    }, Workspace)
    self.Anchor = anchor

    local surface = make("SurfaceGui", {
        Name = "ASSOCIATED_WristMenu",
        Face = Enum.NormalId.Front,
        SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
        CanvasSize = Vector2.new(640, 460),
        LightInfluence = 0,
        AlwaysOnTop = true,
        Enabled = false,
    }, anchor)
    self.Surface = surface

    local root = make("Frame", {
        Name = "Root",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(18, 22, 31),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
    }, surface)
    round(root, 22)

    make("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(20, 12),
        Size = UDim2.new(1, -40, 0, 48),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "ASSOCIATED  /  VR",
        TextColor3 = Color3.fromRGB(235, 242, 255),
        TextSize = 28,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)

    local tabs = make("Frame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(16, 68),
        Size = UDim2.new(1, -32, 0, 54),
        BackgroundTransparency = 1,
    }, root)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabs)

    self.Content = make("ScrollingFrame", {
        Name = "FeatureList",
        Position = UDim2.fromOffset(16, 134),
        Size = UDim2.new(1, -32, 1, -150),
        BackgroundColor3 = Color3.fromRGB(27, 33, 45),
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, root)
    round(self.Content, 14)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, self.Content)
    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, self.Content)

    for index, category in ipairs(CATEGORIES) do
        local tab = make("TextButton", {
            Name = category:gsub("%W", "") .. "Tab",
            Size = UDim2.new(0, 145, 1, 0),
            BackgroundColor3 = Color3.fromRGB(42, 53, 72),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamSemibold,
            Text = category,
            TextColor3 = Color3.fromRGB(220, 230, 245),
            TextSize = 17,
            LayoutOrder = index,
            AutoButtonColor = true,
        }, tabs)
        round(tab, 10)
        table.insert(self.Connections, tab.Activated:Connect(function()
            self:SetCategory(category)
        end))
    end
end

function WristMenu:_renderFeatures()
    for _, child in ipairs(self.Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local features = self.Registry:GetByCategory(self.ActiveCategory)
    for index, feature in ipairs(features) do
        local row = make("Frame", {
            Name = feature.name,
            Size = UDim2.new(1, -4, 0, 72),
            BackgroundColor3 = Color3.fromRGB(38, 47, 63),
            BorderSizePixel = 0,
            LayoutOrder = index,
        }, self.Content)
        round(row, 10)

        make("TextLabel", {
            Position = UDim2.fromOffset(14, 7),
            Size = UDim2.new(1, -150, 0, 28),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = feature.name,
            TextColor3 = Color3.fromRGB(240, 245, 255),
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        make("TextLabel", {
            Position = UDim2.fromOffset(14, 35),
            Size = UDim2.new(1, -150, 0, 25),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = feature.description or "",
            TextColor3 = Color3.fromRGB(160, 176, 198),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)

        local toggle = make("TextButton", {
            Position = UDim2.new(1, -118, 0.5, -19),
            Size = UDim2.fromOffset(104, 38),
            BackgroundColor3 = feature.enabled and Color3.fromRGB(48, 145, 105) or Color3.fromRGB(65, 76, 96),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = feature.enabled and "ON" or "OFF",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
        }, row)
        round(toggle, 9)

        table.insert(self.Connections, toggle.Activated:Connect(function()
            local nextState = not feature.enabled
            local ok, err = self.Registry:SetEnabled(feature.name, nextState, self.Context)
            if not ok then
                warn("[ASSOCIATED] " .. tostring(err))
                return
            end
            if type(self.OnFeatureChanged) == "function" then
                self.OnFeatureChanged(feature, nextState, self.Context)
            end
            self:_renderFeatures()
        end))
    end
end

function WristMenu:SetCategory(category)
    for _, valid in ipairs(CATEGORIES) do
        if valid == category then
            self.ActiveCategory = category
            self:_renderFeatures()
            return true
        end
    end
    return false
end

function WristMenu:SetOpen(open)
    self.Open = open == true
    if self.Surface then
        self.Surface.Enabled = self.Open
    end
end

function WristMenu:Toggle()
    self:SetOpen(not self.Open)
end

function WristMenu:_updateWristAnchor()
    if not self.Anchor or not self.Open then
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local ok, handCFrame = pcall(function()
        return VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
    end)
    if not ok then
        return
    end

    -- UserCFrame is camera-relative. Keep the panel just above the left wrist.
    local worldHand = camera.CFrame * handCFrame
    self.Anchor.CFrame = worldHand * CFrame.new(0, 0.10, -0.18)
end

function WristMenu:Start()
    assert(not self.Destroyed, "Cannot start a destroyed VRWristMenu")
    if not self:IsSupportedExperience() then
        return false, "ASSOCIATED is disabled outside supported universe " .. tostring(self.TargetUniverseId)
    end
    if not VRService.VREnabled then
        return false, "VR is not enabled in this session."
    end
    if self.Started then
        return true
    end

    self.Started = true
    self:_build()
    self:_renderFeatures()

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.ButtonY then
            self:Toggle()
        end
    end))

    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:_updateWristAnchor()
    end))

    return true
end

function WristMenu:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self:SetOpen(false)
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    table.clear(self.Connections)
    if self.Anchor then
        self.Anchor:Destroy()
        self.Anchor = nil
    end
end

function WristMenu.Start(options)
    local instance = WristMenu.new(options)
    local ok, reason = instance:Start()
    if not ok then
        instance:Destroy()
        return nil, reason
    end
    return instance
end

return WristMenu
