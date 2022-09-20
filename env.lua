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
    }
}

return env
