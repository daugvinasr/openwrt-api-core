local uci = require "./uhttpd/libs/uci_handler"
local ubus = require "ubus"

local enabled          = 0
local use_tls_ssl      = 0
local client_enabled   = 0
local persistence      = 0
local anonymous_access = 1
local local_port       = 1883

local data = {
    { option = "enabled", value = enabled },
    { option = "use_tls_ssl", value = use_tls_ssl },
    { option = "client_enabled", value = client_enabled },
    { option = "persistence", value = persistence },
    { option = "anonymous_access", value = anonymous_access },
    { option = "local_port", value = local_port },
}

uci.loadConfig("mosquitto")
uci.addNamed("mqtt", "mqtt", data)

local u = ubus.connect()
u:call("uci", "reload_config", {})










