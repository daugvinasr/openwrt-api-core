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
