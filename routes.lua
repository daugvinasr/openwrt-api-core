routes = {
    {
        path = "/generateCA",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateCA",
    },
    {
        path = "/generateClientServer",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateClientServer",
    },
    {
        path = "/generateClientServerNotSigned",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateClientServerNotSigned",
    },
    {
        path = "/generateDH",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateDH",
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
