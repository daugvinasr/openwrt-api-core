local json = require("cjson")
local uci = require("uci").cursor()

-- io.open("/etc/config/test", "w"):close()

--typed section
-- config interface
-- 	    option ifname 'eth0'
-- 	    option proto 'static'
-- 	    list server '0.openwrt.pool.ntp.org'
-- 	    list server '1.openwrt.pool.ntp.org'
-- uci:add("test", "interface")
-- uci:set("test", "@interface[-1]", "ifname", "eth0")
-- uci:set("test", "@interface[-1]", "proto", "static")
-- uci:set("test", "@interface[-1]", "server", { "0.openwrt.pool.ntp.org", "1.openwrt.pool.ntp.org" })
-- uci:commit("test")


--named section
-- config debug 'aaa'
-- 	    option sms_utils_debug_level '4'
-- uci:set("test", "a", "debug")
-- uci:set("test", "@debug[-1]", "sms_utils_debug_level", "1")
-- uci:set("test", "@debug[-1]", "wireguard_status", "true")
-- uci:set("test", "aa", "debug")
-- uci:set("test", "@debug[-1]", "sms_utils_debug_level", "2")
-- uci:set("test", "@debug[-1]", "wireguard_status", "true")
-- uci:commit("test")


-- uci:delete("test", "a", "sms_utils_debug_level")
-- uci:delete("test", "aa")
-- uci:commit("test")


local data = {
    {
        type = "option",
        option = "proto",
        value = "static1"
    },
    {
        type = "option",
        option = "status",
        value = "true"
    },
    {
        type = "list",
        option = "server",
        value = { "0.pool.ntp.org", "2.pool.ntp.org", "3.pool.ntp.org" }
    }
}
local data2 = {
    {
        type = "option",
        option = "protoaaaaaaaaaaaaaaaaaa",
        value = "static1bbbbbbbbbbbbbbbbbbbbbbbbbb"
    }
}

function addTyped(configFile, sectionName, data)
    uci:add(configFile, sectionName)
    for i, sample in ipairs(data) do
        if sample.type == "option" or sample.type == "list" then
            uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value)
        else
            uci:revert(configFile)
            return false
        end
    end
    return uci:commit(configFile)
end

function addNamed(configFile, sectionName, sectionTitle, data)
    uci:set(configFile, sectionTitle, sectionName)
    for i, sample in ipairs(data) do
        if sample.type == "option" or sample.type == "list" then
            uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value)
        else
            uci:revert(configFile)
            return false
        end
    end
    return uci:commit(configFile)
end

function deleteSection(configFile, sidOrSectionTitle)
    uci:delete(configFile, sidOrSectionTitle)
    return uci:commit(configFile)
end

function addOption(configFile, sidOrSectionTitle, data)
    for i, sample in ipairs(data) do
        if sample.type == "option" or sample.type == "list" then
            uci:set(configFile, sidOrSectionTitle, sample.option, sample.value)
        else
            uci:revert(configFile)
            return false
        end
    end
    return uci:commit(configFile)
end

function removeOption(configFile, sidOrSectionTitle, optionName)
    uci:delete(configFile, sidOrSectionTitle, optionName)
    return uci:commit(configFile)
end

function reorder(configFile, sidOrSectionTitle, position)
    uci:reorder(configFile, sidOrSectionTitle, position)
    return uci:commit(configFile)
end

for i = 1, 20, 1 do
    print()
end

-- addTyped("test", "wireguard", data)
-- addNamed("test", "wireguard", "aaaaaaaaa", data)


uci:foreach("test", "wireguard", function(s)
    print('------------------')
    for key, value in pairs(s) do
        if key == ".name" then
            print(value)
        end
    end
end)

-- removeOption("test","cfg0127cf","proto")
-- removeOption("test","aaaaaaaaa","proto")
-- reorder("test", "aaaaaaaaa", 1)
-- addOption("test", "aaaaaaaaa", data2)
-- print(deleteNamed("test","aaaaaaaaa"))
-- uci:commit("test")

print(io.open("/etc/config/test", "rb"):read "*a");
