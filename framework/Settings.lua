-- ASSOCIATED settings store

local Settings = {}
Settings.__index = Settings

function Settings.new(defaults)
    local values = {}
    for key, value in pairs(defaults or {}) do
        values[key] = value
    end
    return setmetatable({ _values = values }, Settings)
end

function Settings:Get(key, fallback)
    local value = self._values[key]
    if value == nil then return fallback end
    return value
end

function Settings:Set(key, value)
    assert(type(key) == "string" and key ~= "", "Setting key is required")
    self._values[key] = value
end

function Settings:Snapshot()
    local copy = {}
    for key, value in pairs(self._values) do
        copy[key] = value
    end
    return copy
end

return Settings
