local rules = {
    user = { disallowedMethods = { "POST", "PUT" } },
    admin = { disallowedMethods = {} }
}

env = {
    jwtKey = "0276d10e-b59f-4aa3-9fe6-7c4429cbeb4f",
    logins = {
        {
            username = "petras",
            password = "petras",
            rules = rules["user"],
        },
        {
            username = "povilas",
            password = "povilas",
            rules = rules["admin"],
        }
    }
}

return env
