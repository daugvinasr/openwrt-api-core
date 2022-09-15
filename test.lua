local openssl = require 'openssl'
local csr = require 'openssl'.x509.req
local directory = "/home/studentas/Documents/uhttpd/certs"

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
    local extensions = {
        openssl.x509.extension.new_extension(
            { object = 'extendedKeyUsage', value = 'timeStamping', critical = true })
    }

    local pkey = assert(openssl.pkey.new())
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
        caCert = openssl.x509.read(caCertData, "pem")
    end

    local cert = openssl.x509.new(1, req)
    cert:extensions(extensions)
    cert:sign(caKey, caCert)
    write_file(cert_file, cert:export())

end

local ca = { { C = 'CN' }, { ST = 'a' }, { L = 'a' }, { O = 'a' }, { OU = 'a' }, { CN = 'ca' } };
local client = { { C = 'CN' }, { ST = 'a' }, { L = 'a' }, { O = 'a' }, { OU = 'a' }, { CN = 'client' } };
local server = { { C = 'CN' }, { ST = 'a' }, { L = 'a' }, { O = 'a' }, { OU = 'a' }, { CN = 'server' } };


generate_ca(ca, directory)
generate_client_server(client, directory, "client")
generate_client_server(server, directory, "server")
