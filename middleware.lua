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

function middleware.checkUserSpecificRules(authorization, route)
    if authorization["Bearer"] ~= nil then
        local token = authorization["Bearer"]
        local decoded, err = jwt.decode(token, env.jwtKey, true)
        if decoded.iss.username ~= nil then
            for index, value in ipairs(env.logins) do
                if decoded.iss.username == value.username then
                    for rule in string.gmatch(value.rules, '([^|]+)') do
                        if rule == "no" .. route.method then
                            return false
                        end
                    end
                    return true
                end
                return true
            end
            return true
        end
        return true
    end
    return false
end

-- function middleware.checkUserSpecificRules(authorization, route)
--     if authorization["Bearer"] ~= nil then
--         local token = authorization["Bearer"]
--         local decoded, err = jwt.decode(token, env.jwtKey, true)
--         if decoded.iss.rules ~= nil then
--             for rule in string.gmatch(decoded.iss.rules, '([^|]+)') do
--                 if rule == "no" .. route.method then
--                     return false
--                 end
--             end
--             return true
--         else
--             return true
--         end
--     else
--         return false
--     end
-- end

return middleware
