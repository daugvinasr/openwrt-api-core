local json = require "cjson"
local env = require "./uhttpd/env"
local uci = require "./uhttpd/libs/uci_handler"
local ubus = require "ubus"


local BrokerController = {}

function BrokerController.mqttInit(params, body, authorization, contentType)

    function validateConfig(configName)
        for index, value in ipairs(env.mqttOptions) do
            if configName == value then
                return true
            end
        end
        return false
    end

    local data = json.decode(body)
    local configs = {}

    for key, value in pairs(data) do
        if validateConfig(key) then
            table.insert(configs, { option = key, value = value })
        end
    end

    uci.loadConfig("mosquitto")
    uci.deleteSection("mqtt")
    uci.addNamed("mqtt", "mqtt", configs)

    local u = ubus.connect()
    u:call("uci", "reload_config", {})

    return { ok = "config written successfully" }
end

return BrokerController



-- option client_enabled '0'
-- option persistence '0'
-- option anonymous_access '1'
-- option local_port '1883'
-- option use_tls_ssl '1'
-- option _device_sec_files '1'
-- option tls_type 'cert'
-- option ca_file '/etc/certificates/ca.cert.pem'
-- option cert_file '/etc/certificates/server.cert.pem'
-- option key_file '/etc/certificates/ca.key.pem'
-- option tls_version 'all'
-- option enabled '1'

