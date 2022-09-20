routes = {
    {
        path = "/generateCerts",
        method = "GET",
        handlerController = "MainController",
        handlerMethod = "generateCerts",
    },
    {
        path = "/availableCerts",
        method = "GET",
        handlerController = "MainController",
        handlerMethod = "availableCerts",
    },
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
            "checkUserSpecificRules",
        }
    },
    {
        path = "/usersOnline",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "usersOnline",
        middleware = {
            "checkUserSpecificRules",
        }
    }
}

return routes
