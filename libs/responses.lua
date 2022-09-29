local responses = {}

function responses.sendInternalError(uhttpd)
    uhttpd.send("Status: 500 Internal Server Error\r\n")
    uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function responses.sendForbidden(uhttpd)
    uhttpd.send("Status: 401 Forbidden\r\n")
    uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function responses.sendNotFound(uhttpd)
    uhttpd.send("Status: 404 Not Found\r\n")
    uhttpd.send("Content-Type: application/json\r\n\r\n")
end

return responses
