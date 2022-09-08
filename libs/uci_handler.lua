local handler = {}
local uci = require("uci").cursor()
configFile = ""

function handler.loadConfig(name)
    configFile = name
    return true
end

function handler.addTyped(sectionName, data)
    if uci:add(configFile, sectionName) then
        for i, sample in ipairs(data) do
            if not uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
                uci:revert(configFile)
                return false
            end
        end
        return uci:commit(configFile)
    else
        uci:revert(configFile)
        return false
    end
end

function handler.addNamed(sectionName, sectionTitle, data)
    if uci:set(configFile, sectionTitle, sectionName) then
        for i, sample in ipairs(data) do
            if not uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
                uci:revert(configFile)
                return false
            end
        end
        return uci:commit(configFile)
    else
        uci:revert(configFile)
        return false
    end
end

function handler.addOption(sidOrSectionTitle, data)
    for i, sample in ipairs(data) do
        if not uci:set(configFile, sidOrSectionTitle, sample.option, sample.value) then
            uci:revert(configFile)
            return false
        end
    end
    return uci:commit(configFile)
end

function handler.deleteSection(sidOrSectionTitle)
    if uci:delete(configFile, sidOrSectionTitle) then
        return uci:commit(configFile)
    else
        uci:revert(configFile)
        return false
    end
end

function handler.removeOption(sidOrSectionTitle, optionName)
    if uci:delete(configFile, sidOrSectionTitle, optionName) then
        return uci:commit(configFile)
    else
        uci:revert(configFile)
        return false
    end
end

function handler.reorder(sidOrSectionTitle, position)
    if (uci:reorder(configFile, sidOrSectionTitle, position)) then
        return uci:commit(configFile)
    else
        uci:revert(configFile)
        return false
    end
end

function handler.getSections(sectionName)
    local data = {}
    uci:foreach(configFile, sectionName, function(s)
        local singleSection = {}
        for key, value in pairs(s) do
            singleSection[key] = value
        end
        table.insert(data, singleSection)
    end)
    if data[1] ~= nil then return data else return false end
end

function handler.getSection(sectionName, sidOrSectionTitle)
    local data = {}
    uci:foreach(configFile, sectionName, function(s)
        if s[".name"] == sidOrSectionTitle then
            for key, value in pairs(s) do
                data[key] = value
            end
        end
    end)
    if data[".name"] ~= nil then return data else return false end
end

return handler
