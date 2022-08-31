local json = require("cjson")

local AuthController = {}

function AuthController.register(params)
    return 2
end

function AuthController.usersOffline(params)
    return 2
end

function AuthController.usersOnline(params)
    return json.encode({ people = 20 })
end

function AuthController.updatePeopleOnline(params, body)
    return json.encode(params)
end

return AuthController
