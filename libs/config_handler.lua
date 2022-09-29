local uci = require("uci").cursor()
local ubus = require "ubus"

local config_handler = {}
config_handler.__index = config_handler

function config_handler.loadConfig(init)
    local self = setmetatable({}, config_handler)
    self.configFile = init
    return self
end

function config_handler:commit()
    return uci:commit(self.configFile)
end

function config_handler:revert()
    return uci:revert(self.configFile)
end

function config_handler:reloadConfigs()
    local u = ubus.connect()
    u:call("uci", "reload_config", {})
    u:close()
end

function config_handler:addTyped(sectionName, data)
    if uci:add(self.configFile, sectionName) then
        for i, sample in ipairs(data) do
            if not uci:set(self.configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
                return false
            end
        end
    else return true end
end

function config_handler:addNamed(sectionName, sectionTitle, data)
    if uci:set(self.configFile, sectionTitle, sectionName) then
        for i, sample in ipairs(data) do
            if not uci:set(self.configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
                return false
            end
        end
    else return true end
end

function config_handler:addOption(sidOrSectionTitle, data)
    for i, sample in ipairs(data) do
        if not uci:set(self.configFile, sidOrSectionTitle, sample.option, sample.value) then
            return false
        end
    return true end
end

function config_handler:deleteSection(sidOrSectionTitle)
    return uci:delete(self.configFile, sidOrSectionTitle)
end

function config_handler:deleteOption(sidOrSectionTitle, optionName)
    return uci:delete(self.configFile, sidOrSectionTitle, optionName)
end

function config_handler:reorder(sidOrSectionTitle, position)
    return uci:reorder(self.configFile, sidOrSectionTitle, position)
end

function config_handler:getSections(sectionName)
    local data = {}
    uci:foreach(self.configFile, sectionName, function(s)
        local singleSection = {}
        for key, value in pairs(s) do
            singleSection[key] = value
        end
        table.insert(data, singleSection)
    end)
    if data[1] ~= nil then return data else return false end
end

function config_handler:getSection(sectionName, sidOrSectionTitle)
    local data = {}
    uci:foreach(self.configFile, sectionName, function(s)
        if s[".name"] == sidOrSectionTitle then
            for key, value in pairs(s) do
                data[key] = value
            end
        end
    end)
    if data[".name"] ~= nil then return data else return false end
end

return config_handler
