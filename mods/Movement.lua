-- ASSOCIATED Movement feature definitions.
-- Deliberately exposes registration hooks, not unauthorized client manipulation.
-- Implement movement mechanics in an experience you own, with server validation.

local Movement = {}

Movement.Features = {
    SpeedBoost = { category = "Movement", description = "Developer movement-speed test." },
    Fly = { category = "Movement", description = "Controlled flight test for your own experience." },
    LongArms = { category = "Movement", description = "Reach/rig calibration test." },
    Plats = { category = "Movement", description = "Temporary platform mechanic for your own map." },
    BunnyHop = { category = "Movement", description = "Jump timing and momentum test." },
    AirControl = { category = "Movement", description = "Air steering test." },
    Dash = { category = "Movement", description = "Dash ability test." },
    WallGlide = { category = "Movement", description = "Wall movement mechanic test." },
}

function Movement.Register(registry, handlers)
    handlers = handlers or {}
    for name, definition in pairs(Movement.Features) do
        registry:Register(name, definition.category, definition.description, handlers[name])
    end
end

return Movement
