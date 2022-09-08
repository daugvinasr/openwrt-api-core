local json = require("cjson")
local jwt = require "./uhttpd/libs/luajwt"
local base64 = require './uhttpd/libs/base64'
local env = require "./uhttpd/env"
local validation = require "./uhttpd/libs/validation"


local AuthController = {}

function AuthController.login(params, body, authorization)
    if authorization["Basic"] ~= nil then
        local payload = { iss = "petras", nbf = os.time(), exp = os.time() + 3600 }
        local decoded = base64.decode(authorization["Basic"])
        local username, password = string.match(decoded, "([^:]+):([^:]+)")
        if username == "petras" and password == "petras" then
            local token, err = jwt.encode(payload, env.jwtKey, "HS256")
            return { token = token }
        else
            return { error = "Incorrect log in details provided" }
        end
    else
        return { error = "Wrong type of authorization chosen for the log in" }
    end
end

function AuthController.usersOnline(params)
    return { people = 20 }
end

function AuthController.test(params, body, authorization)

    -- Available validations : required|max:255|min:100|email|
    --      |contains:train|number|startsWith:train|endsWith:train|netmask|declined|accepted

    local text = json.decode(body)["test"]
    if validation.validate(text, "required|max:2") then
        return true
    else
        return false
    end
end

return AuthController
