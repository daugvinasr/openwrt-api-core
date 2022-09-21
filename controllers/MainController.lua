local json = require("cjson")
local jwt = require "./uhttpd/libs/luajwt"
local base64 = require './uhttpd/libs/base64'
local env = require "./uhttpd/env"
local validation = require "./uhttpd/libs/validation"
local multipart = require "./uhttpd/libs/multipart"
local cert_info = require "./uhttpd/libs/cert_info"
local cert_generation = "lua /usr/lib/lua/uhttpd/libs/cert_generation.lua"

function shellquote(value)
    return string.format("'%s'", string.gsub(value or "", "'", "'\\''"))
end

local MainController = {}

function MainController.login(params, body, authorization, contentType)
    if authorization["Basic"] ~= nil then
        local decoded = base64.decode(authorization["Basic"])
        local username, password = string.match(decoded, "([^:]+):([^:]+)")
        for _, value in ipairs(env.logins) do
            if username == value.username and password == value.password then
                local payload = { iss = { username = value.username }, nbf = os.time(), exp = os.time() + 3600 }
                local token, err = jwt.encode(payload, env.jwtKey, "HS256")
                return { token = token }
            end
        end
        return { error = "incorrect log in details provided" }
    else
        return { error = "wrong type of authorization chosen for the log in" }
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
    local match = "multipart/form-data; boundary=-----"
    if not string.match(contentType, '^' .. match) then
        local multipart_data = multipart(body, contentType)
        local data = multipart_data["_data"]["data"][1]["value"]
        local headers = multipart_data["_data"]["data"][1]["headers"][1]
        local filename = string.match(headers, "filename=\"([^\"]+)\"")

        local file = io.open("/etc/uploads/" .. filename, "w+")
        if file ~= nil then
            file:write(data)
            file:close()
            return { ok = "file uploaded successfully" }
        else
            return { error = "file could not be written to the system" }
        end
    else
        return { error = "wrong content type" }
    end
end

function MainController.availableCerts(params, body, authorization, contentType)

    local dataCert = {}
    local dataReq = {}
    local dataKey = {}

    local p = io.popen('find "' .. env.certLocation .. '" -type f')

    if p ~= nil then
        for file in p:lines() do
            local temp = cert_info.getCertInfo(file)
            if temp ~= nil then
                if temp.fileType == "cert" then
                    table.insert(dataCert, temp)
                elseif temp.fileType == "req" then
                    table.insert(dataReq, temp)
                elseif temp.fileType == "key" then
                    table.insert(dataKey, temp)
                end
            end
        end
        return { certs = dataCert, reqs = dataReq, keys = dataKey }
    else
        return { error = "could not find any compatible files" }
    end
end

function MainController.generateCA(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"])
    ))

    return { ok = "CA generation is in progress" }

end

function MainController.generateClientServer(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s --caFileName %s --daysValid %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"]),
        shellquote(data["caFileName"]),
        shellquote(data["daysValid"])
    ))

    return { ok = "Certificate generation is in progress" }

end

function MainController.generateClientServerNotSigned(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"])
    ))

    return { ok = "Certificate generation is in progress" }

end



return MainController
