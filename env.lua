env = {
    jwtKey = "0276d10e-b59f-4aa3-9fe6-7c4429cbeb4f",
    certLocation = "/usr/lib/lua/uhttpd/certs",
    logins = {
        {
            username = "petras",
            password = "petras",
            rules = "noPOST|noPUT|noDELETE",
        },
        {
            username = "povilas",
            password = "povilas",
        }
    },
    mqttOptions = {
        "enabled",
        "local_port",
        "acl_file_path",
        "password_file",
        "use_tls_ssl",
        "tls_type",
        "use_remote_tls",
        "use_bridge_login",
        "remote_username",
        "remote_password",
        "remote_clientid",
        "client_enabled",
        "connection_name",
        "remote_addr",
        "remote_port",
        "ca_file",
        "cert_file",
        "key_file",
        "tls_version",
        "psk",
        "identity",
        "bridge_cafile",
        "bridge_certfile",
        "bridge_keyfile",
        "bridge_tls_version",
        "bridge_insecure",
        "bridge_protocol_version",
        "try_private",
        "cleansession",
        "persistence",
        "anonymous_access"
    }
}

return env
