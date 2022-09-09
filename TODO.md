## uhttpd

<!-- while inotifywait -r -e modify,create,delete,move ./uhttpd; do
    sshpass -p admin01 rsync -avz /home/studentas/Documents/uhttpd root@192.168.1.1:/root/ --delete
done -->

while inotifywait -r -e modify,create,delete,move ./uhttpd; do
    sshpass -p admin01 rsync -avz /home/studentas/Documents/uhttpd root@192.168.1.1:/usr/lib/lua/ --delete
done

while inotifywait -r -e modify,create,delete,move /usr/lib/lua/uhttpd; do
    /etc/init.d/uhttpd restart
done

logread -f










local json = require("cjson")
local uci = require("uci").cursor()

io.open("/etc/config/test","w"):close()

--typed section
-- config interface
-- 	    option ifname 'eth0'
-- 	    option proto 'static'
-- 	    list server '0.openwrt.pool.ntp.org'
-- 	    list server '1.openwrt.pool.ntp.org'
uci:add("test", "interface")
uci:set("test", "@interface[-1]", "ifname", "eth0")
uci:set("test", "@interface[-1]", "proto", "static")
uci:set("test", "@interface[-1]", "server", { "0.openwrt.pool.ntp.org", "1.openwrt.pool.ntp.org" })
uci:commit("test")


--named section
-- config debug 'aaa'
-- 	    option sms_utils_debug_level '4'
uci:set("test", "aaaa", "debug")
uci:set("test", "@debug[-1]", "sms_utils_debug_level", "4")
uci:commit("test")


for i = 1, 20, 1 do
    print()
end
print (io.open("/etc/config/test", "rb"):read "*a");




local json = require("cjson")
-- local uci = require("uci").cursor()



-- --named section
-- -- config debug 'aaa'
-- -- 	    option sms_utils_debug_level '4'
-- -- uci:set("test", "a", "debug")
-- -- uci:set("test", "@debug[-1]", "sms_utils_debug_level", "1")
-- -- uci:set("test", "@debug[-1]", "wireguard_status", "true")
-- -- uci:set("test", "aa", "debug")
-- -- uci:set("test", "@debug[-1]", "sms_utils_debug_level", "2")
-- -- uci:set("test", "@debug[-1]", "wireguard_status", "true")
-- -- uci:commit("test")


-- -- uci:delete("test", "a", "sms_utils_debug_level")
-- -- uci:delete("test", "aa")
-- -- uci:commit("test")


-- local data = {
--     {
--         type = "option",
--         option = "proto",
--         value = "static1"
--     },
--     {
--         type = "option",
--         option = "status",
--         value = "true"
--     },
--     {
--         type = "list",
--         option = "server",
--         value = { "0.pool.ntp.org", "2.pool.ntp.org", "3.pool.ntp.org" }
--     }
-- }

-- -- function addTyped(configFile, sectionName, data)
-- --     if uci:add(configFile, sectionName) then
-- --         for i, sample in ipairs(data) do
-- --             if not uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
-- --                 uci:revert(configFile)
-- --                 return false
-- --             end
-- --         end
-- --         return uci:commit(configFile)
-- --     else
-- --         uci:revert(configFile)
-- --         return false
-- --     end

-- -- end

-- -- function addNamed(configFile, sectionName, sectionTitle, data)
-- --     if uci:set(configFile, sectionTitle, sectionName) then
-- --         for i, sample in ipairs(data) do
-- --             if not uci:set(configFile, "@" .. sectionName .. "[-1]", sample.option, sample.value) then
-- --                 uci:revert(configFile)
-- --                 return false
-- --             endlibuci-lua i
-- --     end
-- -- end

-- -- function addOption(configFile, sidOrSectionTitle, data)
-- --     for i, sample in ipairs(data) do
-- --         if not uci:set(configFile, sidOrSectionTitle, sample.option, sample.value) then
-- --             uci:revert(configFile)
-- --             return false
-- --         end
-- --     end
-- --     return uci:commit(configFile)
-- -- end

-- -- function deleteSection(configFile, sidOrSectionTitle)
-- --     if uci:delete(configFile, sidOrSectionTitle) then
-- --         return uci:commit(configFile)
-- --     else
-- --         uci:revert(configFile)
-- --         return false
-- --     end
-- -- end

-- -- function removeOption(configFile, sidOrSectionTitle, optionName)
-- --     if uci:delete(configFile, sidOrSectionTitle, optionName) then
-- --         return uci:commit(configFile)
-- --     else
-- --         uci:revert(configFile)
-- --         return false
-- --     end
-- -- end

-- -- function reorder(configFile, sidOrSectionTitle, position)
-- --     if (uci:reorder(configFile, sidOrSectionTitle, position)) then
-- --         return uci:commit(configFile)
-- --     else
-- --         uci:revert(configFile)
-- --         return false
-- --     end
-- -- end


-- -- io.open("/etc/config/test", "w"):close()

-- for i = 1, 20, 1 do
--     print()
-- end

-- local handler = require("libs.uci_handler")

-- handler.loadConfig("test")
-- -- print(json.encode(handler.getSections("wireguard")))
-- -- print(json.encode(handler.getSection("wireguard","cfg0127cf")))
-- -- print(json.encode(handler.getSection("wireguard","aaaaaaa")))

-- -- handler.addNamed("wireguard", "a" ,data)



-- -- uci:foreach("test", "wireguard", function(s)
-- --     print('------------------')
-- --     for key, value in pairs(s) do
-- --         if key == ".name" then
-- --             print(value)
-- --         end
-- --     end
-- -- end)

-- -- removeOption("test","cfg0127cf","proto")
-- -- removeOption("test","aaaaaaaaa","proto")
-- -- reorder("test", "aaaaaaaaa", 1)
-- -- addOption("test", "aaaaaaaaa", data2)
-- -- print(deleteNamed("test","aaaaaaaaa"))
-- -- uci:commit("test")
-- print('-------------------------------------------')
-- print('-------------------------------------------')

-- print(io.open("/etc/config/test", "rb"):read "*a");

