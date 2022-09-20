local openssl = require 'openssl'
local csr = require 'openssl'.x509.req
local argparse = require("argparse")
-- local env = require "./uhttpd/env"
local env = require "env"


function write_file(file, data)
    local file = io.open(file, "w+")
    if file ~= nil then
        file:write(data)
        file:close()
    end
end

function generate_ca(subject, directory, name, keySize)

    local key_file = directory .. "/" .. name .. ".key.pem"
    local req_file = directory .. "/" .. name .. ".req.pem"
    local cert_file = directory .. "/" .. name .. ".cert.pem"

    local subjectFull = openssl.x509.name.new(subject)

    local pkey = openssl.pkey.new("rsa", keySize)
    write_file(key_file, pkey:export())

    local req = csr.new(subjectFull, pkey)
    write_file(req_file, req:export())

    local cert = req:to_x509(pkey)
    write_file(cert_file, cert:export())

end

function generate_client_server(subject, directory, name, caName, keySize, daysValid)

    local key_file = directory .. "/" .. name .. ".key.pem"
    local req_file = directory .. "/" .. name .. ".req.pem"
    local cert_file = directory .. "/" .. name .. ".cert.pem"

    local subjectFull = openssl.x509.name.new(subject)

    if caName ~= false and daysValid ~= false then

        local caKeyFile = io.open(directory .. "/" .. caName .. ".key.pem", "r")
        local caCertFile = io.open(directory .. "/" .. caName .. ".cert.pem", "r")

        local caKey = nil
        local caCert = nil

        if caKeyFile ~= nil and caCertFile ~= nil then

            local pkey = openssl.pkey.new("rsa", keySize)
            write_file(key_file, pkey:export())
    
            local req = csr.new(subjectFull, pkey)
            write_file(req_file, req:export())

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
        else
            print("CA key or certificate not found")
            os.exit()
        end
    else
        local pkey = openssl.pkey.new("rsa", keySize)
        write_file(key_file, pkey:export())

        local req = csr.new(subjectFull, pkey)
        write_file(req_file, req:export())
    end
end

local parser = argparse()

parser:option("--fileType", "Type of file to be generated: server, client, ca"):argname("<string>")
parser:option("--keySize", "Certificate key size"):argname("<int>")
parser:option("--cn", "Common name and file name of the certificate"):argname("<string>")
parser:option("--caFileName", "Certificate authority file (Used for signing client and server certificates)"):argname("<file>")
parser:option("--daysValid", "Days until certificate expires"):argname("<int>")

parser:option("--c", "Country Code"):argname("<string>")
parser:option("--st", "State or Province Name"):argname("<string>")
parser:option("--l", "Locality Name"):argname("<string>")
parser:option("--o", "Organization Name"):argname("<string>")
parser:option("--ou", "Organizational Unit Name"):argname("<string>")

parser:flag("--sign", "Sign the generated certificate with CA file, requires --caFileName")


local args = parser:parse()

local info = { { CN = args.cn } };

if args.c then table.insert(info, { C = args.c }) end
if args.st then table.insert(info, { ST = args.st }) end
if args.l then table.insert(info, { L = args.l }) end
if args.o then table.insert(info, { O = args.o }) end
if args.ou then table.insert(info, { OU = args.ou }) end


if args.fileType == 'client' or args.fileType == 'server' and args.keySize and args.cn then

    if args.sign == true and args.caFileName ~= nil and args.daysValid ~= nil then
        generate_client_server(info, env.certLocation, args.cn, args.caFileName, args.keySize, args.daysValid)
        os.exit()
    end

    if args.sign == nil and args.caFileName == nil and args.daysValid == nil then
        generate_client_server(info, env.certLocation, args.cn, false, args.keySize, false)
        os.exit()
    end

    print("Wrong or missing arguments")
    os.exit()

elseif args.fileType == 'ca' and args.keySize and args.cn then
    generate_ca(info, env.certLocation, args.cn)
else
    print("Wrong or missing arguments")
    os.exit()
end


-- lua cert_generation.lua --fileType ca --keySize 512 --cn ca --c LT --st a --l a --o a --ou a
-- lua cert_generation.lua --fileType ca --keySize 512 --cn ca 
-- lua cert_generation.lua --fileType client --keySize 512 --cn client --caFileName ca
-- lua cert_generation.lua --fileType server --keySize 512 --cn server --caFileName ca
