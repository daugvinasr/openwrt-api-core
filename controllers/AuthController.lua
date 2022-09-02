local json = require("cjson")
local jwt = require "./uhttpd/luajwt"
local base64 = require './uhttpd/base64'
local env = require "./uhttpd/env"


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

return AuthController
