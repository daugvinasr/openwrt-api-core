local openssl = require 'openssl'
local csr = require 'openssl'.x509.req
local argparse = require("argparse")
local env = require "./uhttpd/env"
local dh = require "gen_dh_lua"
-- local env = require "env"

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

function generate_cert(subject, directory, name, caName, keySize, daysValid)

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
            cert:validat(os.time(), os.time() + 3600 * 24 * daysValid)
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

function generate_dh(directory, name, keySize)
    local path = directory .. "/" .. name .. ".dh.pem"
    local response = dh.gen_dh_file(keySize, path)
    if response ~= 0 then
        print("Error generating DH file")
        os.exit()
    end
end

local parser = argparse()

parser:option("--fileType", "Type of file to be generated: server, client, ca, dh"):argname("<string>")
parser:option("--keySize", "Certificate key size"):argname("<int>")
parser:option("--cn", "Common name and file name of the certificate"):argname("<string>")
parser:option("--caFileName", "Certificate authority file and key name (Used for signing client and server certificates)")
    :argname("<file>")
parser:option("--daysValid", "Days until certificate expires"):argname("<int>")

parser:option("--c", "Country Code"):argname("<string>")
parser:option("--st", "State or Province Name"):argname("<string>")
parser:option("--l", "Locality Name"):argname("<string>")
parser:option("--o", "Organization Name"):argname("<string>")
parser:option("--ou", "Organizational Unit Name"):argname("<string>")

local args = parser:parse()

local keySize
local cn
local caFileName
local daysValid

if args.keySize then keySize = args.keySize else keySize = 2048 end
if args.cn then cn = args.cn else cn = args.fileType .. "_teltonika" end
if args.caFileName then caFileName = args.caFileName else caFileName = false end
if args.daysValid then daysValid = args.daysValid else daysValid = false end

local info = { { CN = cn } };

if args.c then table.insert(info, { C = args.c }) end
if args.st then table.insert(info, { ST = args.st }) end
if args.l then table.insert(info, { L = args.l }) end
if args.o then table.insert(info, { O = args.o }) end
if args.ou then table.insert(info, { OU = args.ou }) end

if (args.fileType == 'client' or args.fileType == 'server') then
    generate_cert(info, env.certLocation, cn, caFileName, keySize, daysValid)
elseif (args.fileType == 'ca') then
    generate_ca(info, env.certLocation, cn, keySize)
elseif (args.fileType == 'dh') then
    generate_dh(env.certLocation, cn, keySize)
else
    print("Invalid file type")
end


-- lua cert_generation.lua --fileType ca --keySize 512 --cn ca --c LT --st a --l a --o a --ou a
-- lua cert_generation.lua --fileType ca --keySize 512 --cn ca
-- lua cert_generation.lua --fileType client --keySize 512 --cn client --caFileName ca --daysValid 365
-- lua cert_generation.lua --fileType server --keySize 512 --cn server --caFileName ca --daysValid 365
