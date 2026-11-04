-- ASSOCIATED feature registry

local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({ _features = {} }, Registry)
end

function Registry:Register(name, category, description, handler)
    assert(type(name) == "string" and name ~= "", "Feature name is required")
    assert(type(category) == "string" and category ~= "", "Feature category is required")
    assert(self._features[name] == nil, "Duplicate feature: " .. name)

    self._features[name] = {
        name = name,
        category = category,
        description = description or "",
        handler = handler,
        enabled = false,
    }
end

function Registry:SetEnabled(name, enabled, context)
    local feature = assert(self._features[name], "Unknown feature: " .. tostring(name))
    enabled = enabled == true

    if feature.enabled == enabled then
        return true
    end

    if type(feature.handler) == "function" then
        local ok, result = pcall(feature.handler, enabled, context)
        if not ok then
            return false, result
        end
        if result == false then
            return false, "Feature handler rejected the state change."
        end
    end

    feature.enabled = enabled
    return true
end

function Registry:GetByCategory(category)
    local result = {}
    for _, feature in pairs(self._features) do
        if feature.category == category then
            table.insert(result, feature)
        end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

function Registry:GetAll()
    local result = {}
    for _, feature in pairs(self._features) do
        table.insert(result, feature)
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

return Registry
