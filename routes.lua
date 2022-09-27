routes = {
    {
        path = "/mqttInit",
        method = "POST",
        handlerController = "BrokerController",
        handlerMethod = "mqttInit",
    },
    {
        path = "/generateCA",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateCA",
    },
    {
        path = "/generateCert",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateCert",
    },
    {
        path = "/generateCertNotSigned",
        method = "POST",
        handlerController = "MainController",
        handlerMethod = "generateCertNotSigned",
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
