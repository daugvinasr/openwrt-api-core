routes = {
    {
        path = "/login",
        method = "POST",
        handlerController = "AuthController",
        handlerMethod = "login",
    },
    {
        path = "/usersOnline",
        method = "GET",
        handlerController = "AuthController",
        handlerMethod = "usersOnline",
        middleware = {
            "checkIfTokenIsValid",
        }
    },
}

return routes
