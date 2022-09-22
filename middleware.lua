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

function userRules(username)
    for _, value in ipairs(env.logins) do
        if username == value.username then
            return value.rules
        end
    end
    return nil
end

function middleware.checkUserSpecificRules(authorization, route)
    if authorization["Bearer"] ~= nil then
        local token = authorization["Bearer"]
        local decoded, err = jwt.decode(token, env.jwtKey, true)

        if not decoded.iss.username then
            return false
        end

        local rules = userRules(decoded.iss.username)
        if rules == nil then
            return false
        end

        for rule in string.gmatch(rules, '([^|]+)') do
            if rule == "no" .. route.method then
                return false
            end
        end

        return true
    else
        return false
    end
end

return middleware