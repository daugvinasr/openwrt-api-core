routes = {
    {
        path = "/login",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "login",
    },
    {
        path = "/usersOnline",
        method = "GET",
        handlerController = "MainController",
        handlerMethod = "test",
    },
    {
        path = "/fileUpload",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "fileUpload",
    },
    -- {
    --     path = "/usersOnline",
    --     method = "GET",
    --     handlerController = "MainController",
    --     handlerMethod = "usersOnline",
    --     middleware = {
    --         "checkIfTokenIsValid",
    --     }
    -- },
}

return routes
