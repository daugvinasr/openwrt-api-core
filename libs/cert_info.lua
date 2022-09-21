local openssl = require 'openssl'
local env = require "./uhttpd/env"
local json = require("cjson")

local certs = {}

function certs.getCertInfo(filePath)
    local file = io.open(filePath, "r")
    if file ~= nil then
        local fileRawContent = file:read("*all")
        file:close()

        function findCN(contentObjName)
            for index, value in ipairs(contentObjName:info()) do
                if value["CN"] ~= nil then
                    return value["CN"]
                end
            end
            return "CN not found"
        end

        if string.match(filePath, ".cert.pem" .. '$') then

            local contentObj = openssl.x509.read(fileRawContent)
            local contentObjName = contentObj:subject()

            return {
                fileName = string.sub(filePath, string.len(env.certLocation) + 2),
                filePath = filePath,
                fileType = "cert",
                commonName = findCN(contentObjName),
                notbefore = contentObj:notbefore():get(),
                notafter = contentObj:notafter():get(),
                keyLength = contentObj:pubkey():bits()
            }

        elseif string.match(filePath, ".req.pem" .. '$') then

            local contentObj = openssl.x509.req.read(fileRawContent)
            local contentObjName = contentObj:subject()

            return {
                fileName = string.sub(filePath, string.len(env.certLocation) + 2),
                filePath = filePath,
                fileType = "req",
                commonName = findCN(contentObjName),
                notbefore = nil,
                notafter = nil,
                keyLength = contentObj:public():bits()
            }

        elseif string.match(filePath, ".key.pem" .. '$') then

            return {
                fileName = string.sub(filePath, string.len(env.certLocation) + 2),
                filePath = filePath,
                fileType = "key",
                commonName = nil,
                notbefore = nil,
                notafter = nil,
                keyLength = openssl.pkey.read(fileRawContent, true, "pem"):bits()
            }

        else
            return nil
        end

    else return nil
    end
end

return certs




