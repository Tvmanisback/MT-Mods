-- ASSOCIATED MenuUI
-- Integration scaffold for an experience you control.
-- Build the actual UI with supported Roblox APIs in your own experience.

local MenuUI = {}
MenuUI.__index = MenuUI

MenuUI.Title = "ASSOCIATED"
MenuUI.Categories = {
    "Movement",
    "Physics",
    "Visuals",
    "Extra Mods",
}

function MenuUI.new(registry, options)
    assert(registry, "MenuUI requires a feature registry")

    local self = setmetatable({}, MenuUI)
    self.Registry = registry
    self.Options = options or {}
    self.Open = false
    self.ActiveCategory = "Home"
    self.OnDisconnect = self.Options.OnDisconnect
    return self
end

function MenuUI:SetOpen(isOpen)
    self.Open = isOpen == true
end

function MenuUI:SetCategory(category)
    for _, name in ipairs(self.Categories) do
        if name == category then
            self.ActiveCategory = category
            return true
        end
    end
    return false
end

function MenuUI:GetCategoryFeatures(category)
    return self.Registry:GetByCategory(category)
end

-- The host experience supplies a safe, authorized disconnect callback.
function MenuUI:Disconnect()
    if type(self.OnDisconnect) == "function" then
        self.OnDisconnect()
        return true
    end
    return false, "No disconnect callback was configured."
end

return MenuUI
