local json = require "cjson"
local env = require "./uhttpd/env"
local config_handler = require "./uhttpd/libs/config_handler"
local ubus = require "ubus"

local BrokerController = {}

function BrokerController.mqttSet(params, body, authorization, contentType)

    local function validateConfig(configName)
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

    local handler = config_handler.loadConfig("mosquitto")
    handler:addNamed("mqtt", "mqtt", configs)
    handler:commit()
    handler:reloadConfigs()

    return "OK", 200, "configuration saved successfully"
end

return BrokerController