local OxPlayer = lib.class('OxPlayer')
local groups = {}

function OxPlayer:__index(index)
    local value = OxPlayer[index] --[[@as any]]

    if type(value) == 'function' then
        self[index] = value == OxPlayer.__call and function(...)
            return value(self, index, ...)
        end or function(...)
            return value(self, ...)
        end

        return self[index]
    end

    return value
end

function OxPlayer:__call(...)
    return exports.ox_core:CallPlayer(...)
end

function OxPlayer:__tostring()
    return string.format('{\n  "userId": %s\n  "charId": %s\n  "stateId": %s\n}',
        self.userId, self.charId, self.stateId)
end

local getters = {}

function OxPlayer:get(key)
    if not self.charId then return end

    if not getters[key] then
        print(('make event ox:player:%s'):format(key))

        AddEventHandler(('ox:player:%s'):format(key), function(data)
            if GetInvokingResource() == 'ox_core' and source == '' then
                print(('triggered ox:player:%s'):format(key))
                self[key] = data
            end
        end)

        getters[key] = true
        self[key] = exports.ox_core.CallPlayer('get', key);
    end

    return self[key]
end

function OxPlayer:getCoords()
    return GetEntityCoords(cache.ped);
end

function OxPlayer:getState()
    return LocalPlayer.state;
end

for method in pairs(exports.ox_core:GetPlayerCalls() or {}) do
    if not OxPlayer[method] then OxPlayer[method] = OxPlayer.__call end
end

local player = OxPlayer:new(exports.ox_core.GetPlayer())

function OxPlayer:getGroups() return groups end

function OxPlayer:getGroup(filter)
    local type = type(filter)

    if type == 'string' then
        local grade = groups[filter]

        if grade then
            return filter, grade
        end
    elseif type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local playerGrade = groups[name]

                if playerGrade and grade <= playerGrade then
                    return name, playerGrade
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local grade = groups[name]

                if grade then
                    return name, grade
                end
            end
        end
    end
end

---@class OxClient
local Ox = Ox

function Ox.GetPlayer()
    return player
end

AddEventHandler('ox:playerLoaded', function(data)
    if player.charId then return end

    for k, v in pairs(data) do player[k] = v end
end)

AddEventHandler('ox:playerLogout', function()
    table.wipe(player)
end)

RegisterNetEvent('ox:setGroup', function(name, grade)
    if source == '' then return end

    groups[name] = grade
end)
