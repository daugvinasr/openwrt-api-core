routes = {
    {
        path = "/register",
        method = "POST",
        handlerController = "AuthController",
        handlerMethod = "register"
    },
    {
        path = "/login",
        method = "POST",
        handlerController = "AuthController",
        handlerMethod = "login",
        middleware = {
            "checkIfTokenIsValid",
        }
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
    {
        path = "/usersOffline",
        method = "GET",
        handlerController = "AuthController",
        handlerMethod = "usersOffline"
    },
    {
        path = "/updatePeopleOnline",
        method = "POST",
        handlerController = "AuthController",
        handlerMethod = "updatePeopleOnline"
    }
}

return routes
