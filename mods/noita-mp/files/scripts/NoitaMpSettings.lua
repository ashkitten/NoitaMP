--- NoitaMpSettings: Replacement for Noita ModSettings.
--- @class NoitaMpSettings
local NoitaMpSettings                  = {}

local lfs                              = require("lfs")
local winapi                           = require("winapi")
local json                             = require("json")

local cachedSettings                   = {}

local convertToDataType                = function(value, dataType)
    if not Utils.IsEmpty(dataType) then
        if dataType == "boolean" then
            if Utils.IsEmpty(value) then
                return false
            end
            return toBoolean(value)
        end
        if dataType == "number" then
            if Utils.IsEmpty(value) then
                return 0
            end
            return tonumber(value)
        end
    end
    return tostring(value)
end

local isMoreThanOneNoitaProcessRunning = function()
    local cpc = CustomProfiler.start("NoitaMpSettings.isMoreThanOneNoitaProcessRunning")
    local pids = winapi.get_processes()
    local noitaCount = 0
    for _, pid in ipairs(pids) do
        local P = winapi.process_from_id(pid)
        local name = P:get_process_name(true)
        if name and string.contains(name, ("Noita%snoita"):format(pathSeparator)) then
            noitaCount = noitaCount + 1
        end
        P:close()
    end
    CustomProfiler.stop("NoitaMpSettings.isMoreThanOneNoitaProcessRunning", cpc)
    return noitaCount > 1
end



function NoitaMpSettings.clearAndCreateSettings()
    -- local cpc         = CustomProfiler.start("NoitaMpSettings.clearAndCreateSettings")
    -- local settingsDir = FileUtils.GetAbsolutePathOfNoitaMpSettingsDirectory()
    -- if FileUtils.Exists(settingsDir) then
    --     FileUtils.RemoveContentOfDirectory(settingsDir)
    --     Logger.info(Logger.channels.initialize, ("Removed old settings in '%s'!"):format(settingsDir))
    -- else
    --     lfs.mkdir(settingsDir)
    --     Logger.info(Logger.channels.initialize, ("Created settings directory in '%s'!"):format(settingsDir))
    -- end
    -- CustomProfiler.stop("NoitaMpSettings.clearAndCreateSettings", cpc)
end

function NoitaMpSettings.set(key, value)
    local cpc = CustomProfiler.start("NoitaMpSettings.set")
    if Utils.IsEmpty(key) or type(key) ~= "string" then
        error(("'key' must not be nil or is not type of string!"):format(key), 2)
    end

    local pid = ""
    local who = ""
    if isMoreThanOneNoitaProcessRunning() then
        pid = winapi.get_current_pid()
        if whoAmI then
            who = whoAmI()
        end
    end

    local settingsFile = ("%s%ssettings%s%s.json")
        :format(FileUtils.GetAbsolutePathOfNoitaMpSettingsDirectory(), pathSeparator, pid, who)

    if Utils.IsEmpty(cachedSettings) or not FileUtils.Exists(settingsFile) then
        NoitaMpSettings.load()
    end

    cachedSettings[key] = value

    CustomProfiler.stop("NoitaMpSettings.set", cpc)
    return cachedSettings
end

function NoitaMpSettings.get(key, dataType)
    local cpc = CustomProfiler.start("NoitaMpSettings.get")

    local pid = ""
    local who = ""
    if isMoreThanOneNoitaProcessRunning() then
        pid = winapi.get_current_pid()
        if whoAmI then
            who = whoAmI()
        end
    end

    local settingsFile = ("%s%ssettings%s%s.json")
        :format(FileUtils.GetAbsolutePathOfNoitaMpSettingsDirectory(), pathSeparator, pid, who)

    if Utils.IsEmpty(cachedSettings) or not FileUtils.Exists(settingsFile) then
        NoitaMpSettings.load()
    end

    if Utils.IsEmpty(cachedSettings[key]) then
        --error(("Unable to find '%s' in NoitaMpSettings: %s"):format(key, contentString), 2)
        CustomProfiler.stop("NoitaMpSettings.get", cpc)
        return convertToDataType("", dataType)
    end
    CustomProfiler.stop("NoitaMpSettings.get", cpc)
    return convertToDataType(cachedSettings[key], dataType)
end

function NoitaMpSettings.load()
    local pid = ""
    local who = ""
    if isMoreThanOneNoitaProcessRunning() then
        pid = winapi.get_current_pid()
        if whoAmI then
            who = whoAmI()
        end
    end

    local settingsFile = ("%s%ssettings%s%s.json")
        :format(FileUtils.GetAbsolutePathOfNoitaMpSettingsDirectory(), pathSeparator, pid, who)

    if not FileUtils.Exists(settingsFile) then
        NoitaMpSettings.save()
    end

    local contentString = FileUtils.ReadFile(settingsFile)
    cachedSettings      = json.decode(contentString)
end

function NoitaMpSettings.save()
    local pid = ""
    local who = ""
    if isMoreThanOneNoitaProcessRunning() then
        pid = winapi.get_current_pid()
        if whoAmI then
            who = whoAmI()
        end
    end

    local settingsFile = ("%s%ssettings%s%s.json")
        :format(FileUtils.GetAbsolutePathOfNoitaMpSettingsDirectory(), pathSeparator, pid, who)
    FileUtils.WriteFile(settingsFile, json.encode(cachedSettings))
    if guiI then
        guiI.setShowSettingsSaved(true)
    end
end

return NoitaMpSettings
