--- NetworkVscUtils:
--- @class NetworkVscUtils for getting and setting values in VariableStorageComponents of Noita-API
NetworkVscUtils = {}



local idcounter = 0


--- Checks if an entity already has a specific VariableStorageComponent.
--- @param entityId number Id of an entity provided by Noita
--- @param componentTypeName string "VariableStorageComponent", "LuaComponent", etc
--- @param fieldNameForMatch string Components attribute to match the specific component you are searching for: "name", "script_source_file", "etc". component.name = "brah": 'name' -> fieldNameForMatch
--- @param matchValue string The components attribute value, you want to match to: component.name = "brah": 'brah' -> matchValue Have a look on NetworkVscUtils.componentNameOf___
--- @param fieldNameForValue string "name", "script_source_file", "etc"
--- @return number|false? compId The specific componentId, which contains the searched value or false if there isn't any Component
--- @return string? value The components value
local function checkIfSpecificVscExists(entityId, componentTypeName, fieldNameForMatch, matchValue, fieldNameForValue)
    local cpc = CustomProfiler.start("NetworkVscUtils.checkIfSpecificVscExists")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.checkIfSpecificVscExists", cpc)
        return false, nil
    end

    local componentIds = EntityGetComponentIncludingDisabled(entityId, componentTypeName) or {}
    if Utils.IsEmpty(componentIds) then
        Logger.debug(Logger.channels.vsc,
            ("Entity(%s) does not have any %s. Returning nil."):format(entityId, componentTypeName))
        CustomProfiler.stop("NetworkVscUtils.checkIfSpecificVscExists", cpc)
        return false, nil
    end

    for i = 1, #componentIds do
        local componentId = componentIds[i]
        -- get the components name
        local compName    = tostring(ComponentGetValue2(componentId, fieldNameForMatch))
        if string.find(compName, matchValue, 1, true) then
            -- if the name of the component match to the one we are searching for, then get the value
            local value = ComponentGetValue2(componentId, fieldNameForValue)
            CustomProfiler.stop("NetworkVscUtils.checkIfSpecificVscExists", cpc)
            return componentIds[i], value
        end
    end
    Logger.trace(Logger.channels.vsc,
        ("Looks like the %s.%s does not exists on entity(%s). Returning nil!")
        :format(componentTypeName, fieldNameForMatch, entityId))
    CustomProfiler.stop("NetworkVscUtils.checkIfSpecificVscExists", cpc)
    return false, nil
end

--- Adds a VariableStorageComponent for the owners name.
---@param entityId number Id of an entity provided by Noita
---@param ownerName string This is the owner of an entity. Owners name.
local function addOrUpdateVscForOwnerName(entityId, ownerName)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateVscForOwnerName")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerName", cpc)
        return
    end

    if not ownerName or ownerName == "" then
        error(("Unable to update VSC on entity (%s), when ownerName is '%s'"):format(entityId, ownerName), 2)
        ownerName = tostring(ownerName)
    end

    local compId, compOwnerName = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfOwnersName, NetworkVscUtils.valueString)
    if compId then
        ComponentSetValue2(compId, NetworkVscUtils.valueString, ownerName)
        Logger.debug(Logger.channels.vsc,
            ("Owner.name(%s) was set to already existing VSC(%s, %s) on entity(%s). Previous owner name = %s")
            :format(ownerName, NetworkVscUtils.componentNameOfOwnersName, compId, entityId,
                compOwnerName))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerName", cpc)
        return compId
    else
        compId = EntityAddComponent2(entityId, "VariableStorageComponent", {
            name         = NetworkVscUtils.componentNameOfOwnersName,
            value_string = ownerName
        })
        ComponentAddTag(compId, "enabled_in_hand")
        ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc,
            ("VariableStorageComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfOwnersName, ownerName, compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerName", cpc)
        return compId
    end

    error("Unable to add ownerNameVsc!", 2)
    CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerName", cpc)
    return nil
end

local function addOrUpdateVscForOwnerGuid(entityId, ownerGuid)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateVscForOwnerGuid")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerGuid", cpc)
        return
    end

    if not ownerGuid or ownerGuid == "" then
        error(("Unable to update VSC on entity (%s), when ownerGuid is '%s'"):format(entityId, ownerGuid), 2)
        ownerGuid = tostring(ownerGuid)
    end

    local compId, compOwnerGuid = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfOwnersGuid, NetworkVscUtils.valueString)
    if compId then
        ComponentSetValue2(compId, NetworkVscUtils.valueString, ownerGuid)
        Logger.debug(Logger.channels.vsc,
            ("Owner.guid(%s) was set to already existing VSC(%s, %s) on entity(%s). Previous owner guid = %s")
            :format(ownerGuid, NetworkVscUtils.componentNameOfOwnersGuid, compId, entityId,
                compOwnerGuid))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerGuid", cpc)
        return compId
    else
        compId = EntityAddComponent2(entityId, "VariableStorageComponent", {
            name         = NetworkVscUtils.componentNameOfOwnersGuid,
            value_string = ownerGuid
        })
        ComponentAddTag(compId, "enabled_in_hand")
        ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc,
            ("VariableStorageComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfOwnersName, ownerGuid, compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerGuid", cpc)
        return compId
    end

    error("Unable to add ownerGuidVsc!")
    CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForOwnerGuid", cpc)
    return nil
end

local function addOrUpdateVscForNuid(entityId, nuid)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateVscForNuid")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForNuid", cpc)
        return
    end

    if _G.whoAmI() == _G.Server.iAm and not nuid or nuid == "" then
        error(("Unable to update VSC on entity (%s), when nuid is '%s'"):format(entityId, nuid), 2)
    end

    local compId, compNuid = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfNuid, "value_int")
    if compNuid == 0 or compNuid == -1 then
        compNuid = nil
    end

    if compId and nuid == compNuid then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForNuid", cpc)
        return compId
    end

    if compNuid and compNuid ~= "" and compNuid ~= -1 and compNuid ~= "-1" and compNuid ~= 0 and compNuid ~= "0" then
        error(("It is not possible to re-set a nuid(%s) on a entity(%s), which already has one set(%s)! Returning nil!")
            :format(nuid, entityId, compNuid), 2)
    end

    if not Utils.IsEmpty(nuid) and nuid > 0 then
        GlobalsUtils.setNuid(nuid, entityId)
    end

    -- There already might be a nuid vsc without any nuid set, think of a client shooting projectiles
    if compId and Utils.IsEmpty(compNuid) or compNuid == -1 or compNuid == 0 or compNuid == "-1" or compNuid == "0" then
        ComponentSetValue2(compId, "value_int", nuid)
        Logger.debug(Logger.channels.vsc, ("Nuid(%s) was set to already existing VSC(%s, %s) on entity(%s)")
            :format(nuid, NetworkVscUtils.componentNameOfNuid, compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForNuid", cpc)
        return compId
    end

    -- If compId isn't set, there is no vsc already added
    if not compId then
        compId = EntityAddComponent2(entityId, "VariableStorageComponent", {
            name      = NetworkVscUtils.componentNameOfNuid,
            value_int = nuid
        })
        ComponentAddTag(compId, "enabled_in_hand")
        ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc, ("VariableStorageComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfNuid, nuid, compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForNuid", cpc)
        return compId
    end

    error("Unable to add nuidVsc!", 2)
    CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForNuid", cpc)
    return nil
end

---@param entityId number
---@param spawnX number
local function addOrUpdateVscForSpawnX(entityId, spawnX)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateVscForSpawnX")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnX", cpc)
        return
    end


    local compIdX, compSpawnX = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfSpawnX, "value_float")

    if not Utils.IsEmpty(compIdX) and not Utils.IsEmpty(compSpawnX) then
        return compIdX
    end

    if type(compSpawnX) == "number" and compSpawnX < 0 then
        compSpawnX = nil
    end

    -- There already might be a vsc without any value set
    if compIdX and Utils.IsEmpty(compSpawnX) then
        ComponentSetValue2(compIdX, "value_float", spawnX)
        Logger.debug(Logger.channels.vsc, ("SpawnX(%s) was set to already existing VSC(%s, %s) on entity(%s)")
            :format(spawnX, NetworkVscUtils.componentNameOfSpawnX, compIdX, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnX", cpc)
        return compIdX
    end

    -- If compId isn't set, there is no vsc. Add one!
    if not compIdX then
        compIdX = EntityAddComponent2(entityId, "VariableStorageComponent", {
            name        = NetworkVscUtils.componentNameOfSpawnX,
            value_float = spawnX
        })
        -- ComponentAddTag(compId, "enabled_in_hand")
        -- ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc, ("VariableStorageComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfSpawnX, spawnX, compIdX, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnX", cpc)
        return compIdX
    end

    error("Unable to add spawnXVsc!", 2)
    CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnX", cpc)
    return nil
end

---@param entityId number
---@param spawnY number
local function addOrUpdateVscForSpawnY(entityId, spawnY)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateVscForSpawnY")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnY", cpc)
        return
    end


    local compIdY, compSpawnY = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfSpawnY, "value_float")

    if not Utils.IsEmpty(compIdY) and not Utils.IsEmpty(compSpawnY) then
        return compIdY
    end

    if type(compSpawnY) == "number" and compSpawnY < 0 then
        compSpawnY = nil
    end

    -- There already might be a vsc without any value set
    if compIdY and Utils.IsEmpty(compSpawnY) then
        ComponentSetValue2(compIdY, "value_float", spawnY)
        Logger.debug(Logger.channels.vsc, ("SpawnY(%s) was set to already existing VSC(%s, %s) on entity(%s)")
            :format(spawnY, NetworkVscUtils.componentNameOfSpawnY, compIdY, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnX", cpc)
        return compIdY
    end

    -- If compId isn't set, there is no vsc. Add one!
    if not compIdY then
        compIdY = EntityAddComponent2(entityId, "VariableStorageComponent", {
            name        = NetworkVscUtils.componentNameOfSpawnY,
            value_float = spawnY
        })
        -- ComponentAddTag(compId, "enabled_in_hand")
        -- ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc, ("VariableStorageComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfSpawnY, spawnY, compIdY, entityId))
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnY", cpc)
        return compIdY
    end

    error("Unable to add spawnYVsc!", 2)
    CustomProfiler.stop("NetworkVscUtils.addOrUpdateVscForSpawnY", cpc)
    return nil
end

--- Adds a LuaComponent for the nuid debugger.
---@param entityId number Id of an entity provided by Noita
local function addNuidDebugger(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.addNuidDebugger")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addNuidDebugger", cpc)
        return
    end
    local compId, compOwnerName = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidDebugger, "script_source_file")
    if compId then
        Logger.debug(Logger.channels.vsc, ("Entity(%s) already has a nuid debugger."):format(entityId))
        CustomProfiler.stop("NetworkVscUtils.addNuidDebugger", cpc)
        return compId
    else
        compId = EntityAddComponent2(entityId, "LuaComponent", {
            script_source_file    = "mods/noita-mp/files/scripts/noita-components/nuid_debug.lua",
            --script_enabled_changed = "mods/noita-mp/files/scripts/noita-components/lua_component_enabler.lua",
            execute_every_n_frame = 1,
        })
        ComponentAddTag(compId, "enabled_in_hand")
        ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc,
            ("LuaComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfNuidDebugger, "nuid_debug.lua", compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addNuidDebugger", cpc)
        return compId
    end

    error("Unable to add nuid debugger!", 2)
    CustomProfiler.stop("NetworkVscUtils.addNuidDebugger", cpc)
    return nil
end

--- Adds a LuaComponent for the nuid updater.
---@param entityId number Id of an entity provided by Noita
local function addNuidUpdater(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.addNuidUpdater")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addNuidUpdater", cpc)
        return
    end
    local compId, compOwnerName = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidUpdater, "script_source_file")
    if compId then
        Logger.debug(Logger.channels.vsc, ("Entity(%s) already has a nuid updater."):format(entityId))
        CustomProfiler.stop("NetworkVscUtils.addNuidUpdater", cpc)
        return compId
    else
        compId = EntityAddComponent2(entityId, "LuaComponent", {
            script_source_file    = "mods/noita-mp/files/scripts/noita-components/nuid_updater.lua",
            --script_enabled_changed = "mods/noita-mp/files/scripts/noita-components/lua_component_enabler.lua",
            execute_on_added      = true,
            execute_on_removed    = true,
            execute_every_n_frame = -1, -- = -1 -> execute only on add/remove/event
        })
        ComponentAddTag(compId, "enabled_in_hand")
        ComponentAddTag(compId, "enabled_in_world")
        Logger.debug(Logger.channels.vsc,
            ("LuaComponent (%s = %s) added with noita componentId = %s to entityId = %s!")
            :format(NetworkVscUtils.componentNameOfNuidUpdater, "nuid_updater.lua", compId, entityId))
        CustomProfiler.stop("NetworkVscUtils.addNuidUpdater", cpc)
        return compId
    end

    error("Unable to add nuid updater!", 2)
    CustomProfiler.stop("NetworkVscUtils.addNuidUpdater", cpc)
    return nil
end

local function getNetworkComponents(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.getNetworkComponents")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.getNetworkComponents", cpc)
        return
    end
    local ownerNameCompId                            = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfOwnersName, NetworkVscUtils.valueString)
    local ownerGuidCompId                            = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfOwnersGuid, NetworkVscUtils.valueString)
    local nuidCompId                                 = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfNuid, NetworkVscUtils.valueString)
    local componentIdForNuidDebugger, scriptFileName = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidDebugger, "script_source_file")
    local componentIdForNuidUpdater, scriptFileName  = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidUpdater, "script_source_file")

    CustomProfiler.stop("NetworkVscUtils.getNetworkComponents", cpc)
    return ownerNameCompId, ownerGuidCompId, nuidCompId, componentIdForNuidDebugger, componentIdForNuidUpdater
end

--#endregion

--#region Global public variables

NetworkVscUtils.variableStorageComponentName = "VariableStorageComponent"
NetworkVscUtils.name                         = "name"
NetworkVscUtils.valueString                  = "value_string"
NetworkVscUtils.componentNameOfOwnersName    = "noita-mp.nc_owner.name"
NetworkVscUtils.componentNameOfOwnersGuid    = "noita-mp.nc_owner.guid"
NetworkVscUtils.componentNameOfNuid          = "noita-mp.nc_nuid"
NetworkVscUtils.componentNameOfNuidDebugger  = "nuid_debug.lua"
NetworkVscUtils.componentNameOfNuidUpdater   = "nuid_updater.lua"
NetworkVscUtils.componentNameOfSpawnX        = "noita-mp.nc_spawn.x"
NetworkVscUtils.componentNameOfSpawnY        = "noita-mp.nc_spawn.y"


--#endregion

--#region Global public functions

--- Simply adds or updates all needed Network Variable Storage Components.
---@param entityId number Id of an entity provided by Noita
---@param ownerName string Owners name. Cannot be nil.
---@param ownerGuid string Owners guid. Cannot be nil.
---@param nuid number|nil Network unique identifier. Can only be nil on clients, but not on server.
---@param spawnX number|nil X position of the entity, when spawned. Can only be set once! Can be nil.
---@param spawnY number|nil Y position of the entity, when spawned. Can only be set once! Can be nil.
---@return integer|nil componentIdForOwnerName
---@return integer|nil componentIdForOwnerGuid
---@return integer|nil componentIdForNuid
---@return integer|nil componentIdForNuidDebugger
---@return integer|nil componentIdForNuidDebugger
function NetworkVscUtils.addOrUpdateAllVscs(entityId, ownerName, ownerGuid, nuid, spawnX, spawnY)
    local cpc = CustomProfiler.start("NetworkVscUtils.addOrUpdateAllVscs")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.addOrUpdateAllVscs", cpc)
        return
    end

    if _G.whoAmI() == _G.Server.iAm and Utils.IsEmpty(nuid) then
        error("You are not allowed to add a empty or nil nuid, when beeing server!", 2)
    end

    local componentIdForOwnerName    = addOrUpdateVscForOwnerName(entityId, ownerName)
    local componentIdForOwnerGuid    = addOrUpdateVscForOwnerGuid(entityId, ownerGuid)
    local componentIdForNuid         = addOrUpdateVscForNuid(entityId, nuid)
    local componentIdForNuidDebugger = addNuidDebugger(entityId)
    local componentIdForNuidUpdater  = addNuidUpdater(entityId)
    local componentIdForSpawnX       = addOrUpdateVscForSpawnX(entityId, spawnX)
    local componentIdForSpawnY       = addOrUpdateVscForSpawnY(entityId, spawnY)


    if not componentIdForOwnerName or not componentIdForOwnerGuid or not componentIdForNuid or not componentIdForNuidDebugger
        or not componentIdForNuidUpdater or not componentIdForSpawnX or not componentIdForSpawnY then
        error(
            ("Something terrible went wrong! A component id for a Network Vsc was nil. OwnerNameCompId = %s, OwnerGuidCompId = %s, NuidCompId = %s, NuidDebuggerCompId = %s, NuidUpdaterCompId = %s")
            :format(componentIdForOwnerName, componentIdForOwnerGuid, componentIdForNuid,
                componentIdForNuidDebugger, componentIdForNuidUpdater), 2)
    end

    CustomProfiler.stop("NetworkVscUtils.addOrUpdateAllVscs", cpc)
    return componentIdForOwnerName, componentIdForOwnerGuid, componentIdForNuid, componentIdForNuidDebugger, componentIdForNuidUpdater,
        componentIdForSpawnX, componentIdForSpawnY
end

--- Returns all Network Vsc values by its entity id.
--- @param entityId number Entity Id provided by Noita
--- @return string? ownerName, string? ownerGuid, number? nuid - nuid can be nil
function NetworkVscUtils.getAllVscValuesByEntityId(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.getAllVscValuesByEntityId")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.getAllVscValuesByEntityId", cpc)
        return
    end
    local ownerNameCompId, ownerGuidCompId, nuidCompId, _, _ = getNetworkComponents(entityId)
    CustomProfiler.stop("NetworkVscUtils.getAllVscValuesByEntityId", cpc)
    if ownerNameCompId and ownerGuidCompId then
        return NetworkVscUtils.getAllVcsValuesByComponentIds(ownerNameCompId, ownerGuidCompId, nuidCompId)
    else
        --error(("getAllVcsValuesByEntityId: Got unexpected nil id. entityId, = %s ownerNameCompId = %s, ownerGuidCompId = %s, nuidCompId = %s")
        --              :format(entityId, ownerNameCompId, ownerGuidCompId, nuidCompId), 2)
    end
end

--- Returns all Network Vsc values by its component ids.
---@param ownerNameCompId number Component Id of the OwnerNameVsc
---@param ownerGuidCompId number Component Id of the OwnerGuidVsc
---@param nuidCompId number Component Id of the NuidVsc
---@return string ownerName
---@return string ownerGuid
---@return number nuid
function NetworkVscUtils.getAllVcsValuesByComponentIds(ownerNameCompId, ownerGuidCompId, nuidCompId)
    local cpc           = CustomProfiler.start("NetworkVscUtils.getAllVcsValuesByComponentIds")
    local compOwnerName = ComponentGetValue2(ownerNameCompId, NetworkVscUtils.valueString)
    local compOwnerGuid = ComponentGetValue2(ownerGuidCompId, NetworkVscUtils.valueString)
    local compNuid      = ComponentGetValue2(nuidCompId, "value_int")

    if compNuid == 0 or compNuid == -1 then
        compNuid = nil
    end

    if Utils.IsEmpty(compOwnerName) then
        error(("Something really bad went wrong! compOwnerName must not be empty: %s"):format(compOwnerName), 2)
    end
    if Utils.IsEmpty(compOwnerGuid) then
        error(("Something really bad went wrong! compOwnerGuid must not be empty: %s"):format(compOwnerGuid), 2)
    end

    CustomProfiler.stop("NetworkVscUtils.getAllVcsValuesByComponentIds", cpc)
    return compOwnerName, compOwnerGuid, compNuid
end

--- Returns true, componentId and nuid if the entity has a NetworkVsc.
--- @param entityId number entityId provided by Noita
--- @return boolean isNetworkEntity
--- @return number componentId
--- @return number|nil nuid
function NetworkVscUtils.isNetworkEntityByNuidVsc(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.isNetworkEntityByNuidVsc")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.isNetworkEntityByNuidVsc", cpc)
        return false, -1, -1
    end
    local componentId, value = checkIfSpecificVscExists(
        entityId, NetworkVscUtils.variableStorageComponentName, NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfNuid, "value_int")
    if Utils.IsEmpty(componentId) or Utils.IsEmpty(value) then
        CustomProfiler.stop("NetworkVscUtils.isNetworkEntityByNuidVsc", cpc)
        return false, -1, -1
    end
    CustomProfiler.stop("NetworkVscUtils.isNetworkEntityByNuidVsc", cpc)
    if not componentId then
        componentId = -1
    end
    if not value then
        value = -1
    end
    if value == 0 or value == -1 then
        value = nil
    end
    return true, componentId, value
end

--- Checks if the nuid Vsc exists, if so returns nuid
--- @param entityId number
--- @return boolean has retruns 'false, -1': Returns false, if there is no NuidVsc or nuid is empty.
--- @return number nuid Returns 'true, nuid', if set.
function NetworkVscUtils.hasNuidSet(entityId)
    local cpc              = CustomProfiler.start("NetworkVscUtils.hasNuidSet")
    local nuidCompId, nuid = checkIfSpecificVscExists(entityId, NetworkVscUtils.variableStorageComponentName,
        NetworkVscUtils.name,
        NetworkVscUtils.componentNameOfNuid, "value_int")

    if not nuidCompId then
        CustomProfiler.stop("NetworkVscUtils.hasNuidSet", cpc)
        return false, -1
    end
    if Utils.IsEmpty(nuid) or nuid == 0 or nuid == -1 then
        CustomProfiler.stop("NetworkVscUtils.hasNuidSet", cpc)
        return false, nuid
    end
    CustomProfiler.stop("NetworkVscUtils.hasNuidSet", cpc)
    ---@diagnostic disable-next-line: return-type-mismatch
    return true, tonumber(nuid)
end

function NetworkVscUtils.hasNetworkLuaComponents(entityId)
    local cpc = CustomProfiler.start("NetworkVscUtils.hasNetworkLuaComponents")
    if not EntityUtils.isEntityAlive(entityId) then
        CustomProfiler.stop("NetworkVscUtils.hasNetworkLuaComponents", cpc)
        return
    end
    local has                  = false
    local nuid_debugger, value = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidDebugger, "script_source_file")
    local nuid_updater, value  = checkIfSpecificVscExists(
        entityId, "LuaComponent", "script_source_file",
        NetworkVscUtils.componentNameOfNuidUpdater, "script_source_file")

    if nuid_debugger and nuid_updater then
        has = true
    end
    CustomProfiler.stop("NetworkVscUtils.hasNetworkLuaComponents", cpc)
    return has
end

--#endregion

-- Because of stack overflow errors when loading lua files,
-- I decided to put Utils 'classes' into globals
_G.NetworkVscUtils = NetworkVscUtils

-- But still return for Noita Components,
-- which does not have access to _G,
-- because of own context/vm
return NetworkVscUtils
