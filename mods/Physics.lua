-- ASSOCIATED Physics feature definitions.
-- Implement these as mechanics in an experience you control.
-- Do not use client-side physics toggles as a security boundary.

local Physics = {}

Physics.Features = {
    CollisionDebug = { category = "Physics", description = "Inspect collision configuration in a test map." },
    GravityScale = { category = "Physics", description = "Adjust gravity for an authorized physics test." },
    PlatformSupport = { category = "Physics", description = "Test supported temporary platforms." },
}

function Physics.Register(registry, handlers)
    handlers = handlers or {}
    for name, definition in pairs(Physics.Features) do
        registry:Register(name, definition.category, definition.description, handlers[name])
    end
end

return Physics
