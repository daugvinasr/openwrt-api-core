local openssl = require 'openssl'
local csr = require 'openssl'.x509.req
local env = require "./uhttpd/env"

function write_file(file, data)
    local file = io.open(file, "w+")
    if file ~= nil then
        file:write(data)
        file:close()
    end
end

function generate_ca(subject, directory)

    local key_file = directory .. "/" .. "ca" .. ".key.pem"
    local req_file = directory .. "/" .. "ca" .. ".req.pem"
    local cert_file = directory .. "/" .. "ca" .. ".cert.pem"

    local subjectFull = openssl.x509.name.new(subject)

    local pkey = openssl.pkey.new()
    write_file(key_file, pkey:export())

    local req = csr.new(subjectFull, pkey)
    write_file(req_file, req:export())

    local cert = req:to_x509(pkey)
    write_file(cert_file, cert:export())

end

function generate_client_server(subject, directory, name)

    local key_file = directory .. "/" .. name .. ".key.pem"
    local req_file = directory .. "/" .. name .. ".req.pem"
    local cert_file = directory .. "/" .. name .. ".cert.pem"

    local subjectFull = openssl.x509.name.new(subject)

    local pkey = openssl.pkey.new()
    write_file(key_file, pkey:export())

    local req = csr.new(subjectFull, pkey)
    write_file(req_file, req:export())


    local caKeyFile = io.open(directory .. "/ca.key.pem", "r")
    local caCertFile = io.open(directory .. "/ca.cert.pem", "r")

    local caKey = nil
    local caCert = nil

    if caKeyFile ~= nil and caCertFile ~= nil then
        local caKeyData = caKeyFile:read("*all")
        local caCertData = caCertFile:read("*all")
        caKeyFile:close()
        caCertFile:close()

        caKey = openssl.pkey.read(caKeyData, true, "pem")
        caCert = openssl.x509.read(caCertData)

        local cert = openssl.x509.new(req)
        cert:validat(os.time(), os.time() + 3600 * 24 * 365)
        cert:sign(caKey, caCert)
        write_file(cert_file, cert:export())
    end

end

local ca = { { C = 'LT' }, { CN = 'ca' } };
local client = { { C = 'LT' }, { CN = 'client' } };
local server = { { C = 'LT' }, { CN = 'server' } };

generate_ca(ca, env.certLocation)
generate_client_server(client, env.certLocation, "client")
generate_client_server(server, env.certLocation, "server")
