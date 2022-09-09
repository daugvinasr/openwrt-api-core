local json = require("cjson")
local jwt = require "./uhttpd/libs/luajwt"
local base64 = require './uhttpd/libs/base64'
local env = require "./uhttpd/env"
local validation = require "./uhttpd/libs/validation"
local multipart = require "./uhttpd/libs/multipart"


local MainController = {}

function MainController.login(params, body, authorization, contentType)
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

function MainController.usersOnline(params, body, authorization, contentType)
    return { people = 20 }
end

function MainController.validation(params, body, authorization, contentType)
    -- Available validations : required|max:255|min:100|email|
    --      |contains:train|number|startsWith:train|endsWith:train|netmask|declined|accepted
    local text = json.decode(body)["test"]
    if validation.validate(text, "required|max:2") then
        return { ok = "validation passed" }
    else
        return { error = "validation failed" }
    end
end

function MainController.fileUpload(params, body, authorization, contentType)
    local multipart_data = multipart(body, contentType)

    local data = multipart_data["_data"]["data"][1]["value"]
    local headers = multipart_data["_data"]["data"][1]["headers"][1]
    local filename = string.match(headers, "filename=\"([^\"]+)\"")

    local file = io.open("/etc/uploads/"..filename, "w+")
    if file ~= nil then
        file:write(data)
        file:close()
        return { ok = "file uploaded successfully" }
    else
        return { error = "file could not be written to the system" }
    end
end

return MainController
