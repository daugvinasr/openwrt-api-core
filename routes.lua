routes = {
    {
        path = "/login",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "login",
    },
    {
        path = "/fileUpload",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "fileUpload",
    },
    {
        path = "/usersOnline",
        method = "GET",
        handlerController = "MainController",
        handlerMethod = "usersOnline",
        middleware = {
            "checkRoleSpecificRules",
        }
    },
    {
        path = "/usersOnline",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "usersOnline",
        middleware = {
            "checkRoleSpecificRules",
        }
    }
}

return routes
