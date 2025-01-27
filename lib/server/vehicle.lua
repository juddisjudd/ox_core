local OxVehicle = lib.class('OxVehicle')

function OxVehicle:__index(index)
    local value = OxVehicle[index] --[[@as any]]

    if type(value) == 'function' then
        self[index] = value == OxVehicle.__call and function(...)
            return value(self, index, ...)
        end or function(...)
            return value(self, ...)
        end

        return self[index]
    end

    return value
end

function OxVehicle:__call(...)
    return exports.ox_core:CallVehicle(self.entity, ...)
end

function OxVehicle:__tostring()
    return json.encode(self)
end

function OxVehicle:getCoords()
    return GetEntityCoords(self.entity);
end

function OxVehicle:getState()
    return Entity(self.entity).state;
end

for method in pairs(exports.ox_core:GetVehicleCalls() or {}) do
    if not OxVehicle[method] then OxVehicle[method] = OxVehicle.__call end
end

local function CreateVehicleInstance(vehicle)
    if not vehicle then return end;

    return OxVehicle:new(vehicle)
end

---@class OxServer
local Ox = Ox

function Ox.GetVehicle(entityId)
    return CreateVehicleInstance(exports.ox_core:GetVehicle(entityId))
end

function Ox.GetVehicleFromNetId(netId)
    return CreateVehicleInstance(exports.ox_core:GetVehicleFromNetId(netId))
end

function Ox.GetVehicleFromVin(vin)
    return CreateVehicleInstance(exports.ox_core:GetVehicleFromVin(vin))
end

function Ox.CreateVehicle(data, coords, heading)
    return CreateVehicleInstance(exports.ox_core:CreateVehicle(data, coords, heading));
end

function Ox.SpawnVehicle(dbId, coords, heading)
    return CreateVehicleInstance(exports.ox_core:SpawnVehicle(dbId, coords, heading));
end
