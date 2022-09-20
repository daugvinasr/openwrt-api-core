local openssl = require 'openssl'
local env = require "./uhttpd/env"


local certs = {}

function certs.getCertInfo(filePath)
    local file = io.open(filePath, "r")
    if file ~= nil then
        local fileRawContent = file:read("*all")
        file:close()

        if string.match(filePath, ".cert.pem" .. '$') then

            local contentObj = openssl.x509.read(fileRawContent)
            local contentObjName = contentObj:subject()

            return {
                fileName = string.sub(filePath, string.len(env.certLocation) + 2),
                filePath = filePath,
                fileType = "cert",
                country = contentObjName:info()[1]['C'],
                commonName = contentObjName:info()[2]['CN'],
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
                country = contentObjName:info()[1]['C'],
                commonName = contentObjName:info()[2]['CN'],
                notbefore = nil,
                notafter = nil,
                keyLength = contentObj:public():bits()
            }

        elseif string.match(filePath, ".key.pem" .. '$') then

            return {
                fileName = string.sub(filePath, string.len(env.certLocation) + 2),
                filePath = filePath,
                fileType = "key",
                country = nil,
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




