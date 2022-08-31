local json = require("cjson")
local jwt = require "/root/uhttpd/luajwt"
local privateKey = "a1f7a65d-5a1f-49dc-9651-59fab5b038ad"

local middleware = {}

function middleware.checkIfTokenIsValid(authorization)
    local type = authorization[1]
    local token = authorization[2]

    local token, err = jwt.encode('petras', privateKey)
    logPrint(token)

    return true
end

return middleware
