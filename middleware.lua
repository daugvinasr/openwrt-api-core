local json = require("cjson")
local jwt = require "./uhttpd/libs/luajwt"
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

function middleware.checkRoleSpecificRules(authorization, route)

    local function checkDisallowedMethods(decoded, route)
        for index, value in ipairs(decoded.iss.rules.disallowedMethods) do
            if value == route.method then
                return false
            end
        end
        return true
    end

    if authorization["Bearer"] ~= nil then
        local token = authorization["Bearer"]
        local decoded, err = jwt.decode(token, env.jwtKey, true)
        -- this is where you can add your own rules that need to be checked
        if decoded ~= nil and checkDisallowedMethods(decoded, route) then
            return true
        else
            return false
        end
    else
        return false
    end
end

return middleware
