local json = require("cjson")
local jwt = require "./uhttpd/luajwt"
local env = require "./uhttpd/env"

local middleware = {}

function middleware.checkIfTokenIsValid(authorization)
    if authorization["Bearer"] ~= nil then
        local token = authorization["Bearer"]
        local decoded, err = jwt.decode(token, env.jwtKey, true) -- forcing token expiry check
        if decoded ~= nil then
            return true
        else
            return false
        end
    else
        return false
    end
end

return middleware
