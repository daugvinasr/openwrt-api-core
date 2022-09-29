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
                return "OK", 200, { token = token }
            end
        end
        return "OK", 300, "Incorrect log in details provided"
    else
        return "OK", 300, "Wrong type of authorization chosen for the log in"
    end
end

function MainController.usersOnline(params, body, authorization, contentType)
    local response = { people = 20, devices = 10 }
    return "OK", 200, response
end

function MainController.validation(params, body, authorization, contentType)
    -- Available validations : required|max:255|min:100|email|
    --      |contains:train|number|startsWith:train|endsWith:train|netmask|declined|accepted
    local text = json.decode(body)["test"]
    if validation.validate(text, "required|max:2") then
        return "OK", 200, "Validation passed"
    else
        return "OK", 300, "Validation failed"
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
            return "OK", 200, "File uploaded successfully"
        else
            return "OK", 500, "File could not be written to the system"
        end
    else
        return "OK", 300, "Wrong content type"
    end
end

function MainController.availableCerts(params, body, authorization, contentType)

    local dataCert = {}
    local dataReq = {}
    local dataKey = {}
    local dataDH = {}

    local p = io.popen('find "' .. env.certLocation .. '" -type f')

    if p ~= nil then
        for file in p:lines() do
            local temp = cert_info.getCertInfo(file)
            if temp ~= nil then
                if temp.fileType == "cert" then
                    table.insert(dataCert, temp)
                elseif temp.fileType == "req" then
                    table.insert(dataReq, temp)
                elseif temp.fileType == "dh" then
                    table.insert(dataDH, temp)
                elseif temp.fileType == "key" then
                    table.insert(dataKey, temp)
                end
            end
        end
        return "OK", 200, { certs = dataCert, reqs = dataReq, dh = dataDH, keys = dataKey }
    else
        return "OK", 200, "Could not find any compatible files"
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

    return "OK", 200, "CA generation is in progress"
end

function MainController.generateCert(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s --caFileName %s --daysValid %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"]),
        shellquote(data["caFileName"]),
        shellquote(data["daysValid"])
    ))

    return "OK", 200, "Certificate generation is in progress"
end

function MainController.generateCertNotSigned(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"])
    ))

    return "OK", 200, "Certificate generation is in progress"
end

function MainController.generateDH(params, body, authorization, contentType)

    local data = json.decode(body)

    os.execute(string.format(
        cert_generation .. " --fileType %s --keySize %s --cn %s",
        shellquote(data["fileType"]),
        shellquote(data["keySize"]),
        shellquote(data["cn"])
    ))

    return "OK", 200, "DH generation is in progress"
end

return MainController
