local json      = require 'cjson'
local openssl   = require 'openssl'
local csr       = require 'openssl'.x509.req
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

-- -----BEGIN DH PARAMETERS-----
-- MEYCQQCs8i8641u/28IHbqJ6W4q+gRDSPFQBkdvQrs4XqwuiTCDpiOse0M76eVqy
-- Kc4o/GT/7ovNF2LTRkpKV4EtCDQzAgEC
-- -----END DH PARAMETERS-----



local ca = { { C = 'LT' }, { CN = 'ca' } };
local client = { { C = 'LT' }, { CN = 'client' } };
local server = { { C = 'LT' }, { CN = 'server' } };

-- generate_ca(ca, directory)
-- generate_client_server(client, directory, "client")
-- generate_client_server(server, directory, "server")
-- print(json.encode(getData(directory)))
