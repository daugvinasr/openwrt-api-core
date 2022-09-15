local OPENSSL_CMD = "/usr/bin/openssl"
local OPENSSL_CNF = "/etc/ssl/openssl.cnf"
local DIRECTORY = "/home/studentas/Documents/uhttpd/certs"
local LOG_FILE = "/tmp/certificates-status"
local STATUS_DIR = DIRECTORY .. "/status"
local STATUS_FILE = STATUS_DIR .. "/info"
local DEF_SUBJECT = "/C=''/ST=''/L=''/O=''/OU=''"

local defaults = {
    KEY_SIZE     = "2048",
    SIGN         = false,
    DELETE       = false,
    CA           = "",
    CA_KEY       = "",
    REQUEST_FILE = "",
    DAYS         = 3650,
    SUBJECT      = DEF_SUBJECT
}

function shellquote(value)
    return string.format("'%s'", string.gsub(value or "", "'", "'\\''"))
end

function generate_ca()
    local key_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".key.pem"
    local req_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".req.pem"
    local ret = os.execute(string.format(
        OPENSSL_CMD .. " req -config %s -nodes -subj %s -keyout %s -newkey %s -new -out %s",
        OPENSSL_CNF, shellquote(defaults.SUBJECT), shellquote(key_file),
        shellquote("rsa:" .. defaults.KEY_SIZE), shellquote(req_file)
    ))

    if defaults.SIGN == true then
        defaults.REQUEST_FILE = defaults.FILE_NAME .. ".req.pem"
        defaults.KEY_FILE = defaults.FILE_NAME .. ".key.pem"
        sign_ca()
    end
end

function sign_ca()
    local req_file  = DIRECTORY .. "/" .. defaults.REQUEST_FILE
    local key_file  = DIRECTORY .. "/" .. defaults.KEY_FILE
    local cert_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".cert.pem"
    local ret       = os.execute(string.format(
        OPENSSL_CMD .. " x509 -req -days %s -in %s -extfile %s -extensions v3_ca -signkey %s -out %s",
        shellquote(defaults.DAYS), shellquote(req_file), shellquote(OPENSSL_CNF),
        shellquote(key_file), shellquote(cert_file)
    ))
end

function generate_client_server()
    local key_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".key.pem"
    local req_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".req.pem"
    local ret
    if defaults.PASS and defaults.PASS ~= '' then
        ret = os.execute(string.format(
            OPENSSL_CMD .. " req -config %s -nodes -subj %s -keyout %s -newkey %s -new -out %s -passout %s",
            OPENSSL_CNF, shellquote(defaults.SUBJECT), shellquote(key_file), shellquote("rsa:" .. defaults.KEY_SIZE),
            shellquote(req_file), shellquote("pass:" .. defaults.PASS)
        ))
    else
        ret = os.execute(string.format(
            OPENSSL_CMD .. " req -config %s -nodes -subj %s -keyout %s -newkey %s -new -out %s",
            OPENSSL_CNF, shellquote(defaults.SUBJECT), shellquote(key_file),
            shellquote("rsa:" .. defaults.KEY_SIZE), shellquote(req_file)
        ))
    end

    if defaults.SIGN == true then
        defaults.REQUEST_FILE = defaults.FILE_NAME .. ".req.pem"
        sign_client_server()
    end
    return ret
end

function sign_client_server()
    local req_file   = DIRECTORY .. "/" .. defaults.REQUEST_FILE
    local ca_file    = DIRECTORY .. "/" .. defaults.CA
    local cakey_file = DIRECTORY .. "/" .. defaults.CA_KEY
    local cert_file  = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".cert.pem"
    local ret        = os.execute(string.format(
        OPENSSL_CMD .. " x509 -req -days %s -in %s -CA %s -CAkey %s -out %s -CAcreateserial",
        shellquote(defaults.DAYS), shellquote(req_file), shellquote(ca_file),
        shellquote(cakey_file), shellquote(cert_file)
    ))
    return ret
end

function generate_dh()
    local pem_file = DIRECTORY .. "/" .. defaults.FILE_NAME .. ".pem"
    local ret = os.execute(string.format(
        OPENSSL_CMD .. " dhparam -out %s %s", shellquote(pem_file), shellquote(defaults.KEY_SIZE)
    ))
    return ret
end

defaults.SIGN = true
defaults.DELETE = true
defaults.CA = "ca.cert.pem"
defaults.CA_KEY = "ca.key.pem"

defaults.COMMON_NAME = "ca"
defaults.FILE_NAME = 'ca'
defaults.TYPE = "ca"
defaults.SUBJECT = DEF_SUBJECT .. "/CN=ca"
generate_ca()

defaults.COMMON_NAME = "server"
defaults.FILE_NAME = 'server'
defaults.TYPE = "server"
defaults.SUBJECT = DEF_SUBJECT .. "/CN=server"
generate_client_server()

defaults.COMMON_NAME = "client"
defaults.FILE_NAME = 'client'
defaults.TYPE = "client"
defaults.SUBJECT = DEF_SUBJECT .. "/CN=client"
generate_client_server()

-- defaults.COMMON_NAME = "dh"
-- defaults.FILE_NAME = 'dh'
-- defaults.TYPE = "dh"
-- generate_dh()
