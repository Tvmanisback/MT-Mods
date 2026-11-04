-- ASSOCIATED Visual feature definitions.
-- Intended for developer-controlled visual testing in your own experience.

local Visuals = {}

Visuals.Features = {
    Fullbright = { category = "Visuals", description = "Lighting preview for a controlled test scene." },
    FieldOfView = { category = "Visuals", description = "Camera field-of-view preview." },
    PlayerBoundsDebug = { category = "Visuals", description = "Debug bounds for permitted test dummies." },
}

function Visuals.Register(registry, handlers)
    handlers = handlers or {}
    for name, definition in pairs(Visuals.Features) do
        registry:Register(name, definition.category, definition.description, handlers[name])
    end
end

return Visuals
