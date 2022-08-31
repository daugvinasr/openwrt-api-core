## uhttpd

while inotifywait -r -e modify,create,delete,move ./uhttpd; do
    sshpass -p admin01 rsync -avz /home/studentas/Documents/uhttpd root@192.168.1.1:/root/ --delete
done

while inotifywait -r -e modify,create,delete,move ./uhttpd; do
    /etc/init.d/uhttpd restart
done

logread -f

local json = require("cjson")

data = {}
data["name"] = "piotras123213213213"
data["age"] = "100"


function logPrint(text)
    io.stderr:write(string.format(text .. "\n"))
end

function getResponse(uhttpd, env)
    local len = tonumber(env.CONTENT_LENGTH) or 0
    if len > 0 then
        local rlen, rbuf = uhttpd.recv(4096)
        if rlen >= 0 then
            len = len - rlen
            return rbuf
        end
    end
    
    return nil
end

function handle_request(env)
    if env.REQUEST_METHOD == 'GET' then
        uhttpd.send("Status: 200 OK\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send(json.encode(data))

    elseif env.REQUEST_METHOD == 'POST' then
        uhttpd.send("Status: 200 OK\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send("Got a POST request" .. "\n")
        logPrint(getResponse(uhttpd, env))
    else
        uhttpd.send("Status: 404 Not Found\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send("Can't handle this request.")
    end
end


local routes = require "routes"


function writeImports()
    if routes ~= nil then
        local imports = {}
        for i, route in ipairs(routes) do
            local exists = false
            for _, import in ipairs(imports) do
                if route.handlerController == import then
                    exists = true
                end
            end
            if not exists then
                table.insert(imports, route.handlerController)
                file:write(route.handlerController .. " = require(\"" ..
                    '/root/uhttpd/controllers/' .. route.handlerController .. "\")\n")
            end
        end
        file:write("\n")
    end
end

function writeStatements(route)
    -- print(route.path, route.method, route.handlerController, route.handlerMethod)
        
    if route.method == "GET" then
        file:write("   if env.REQUEST_METHOD == '"..route.method.."' and env.REQUEST_URI == '" ..'/lua'..route.path .. "' then\n")
        file:write("      local status, error = pcall(function() "..route.handlerController..'.'..route.handlerMethod..'()'.." end)"..'\n')
        file:write([[      uhttpd.send("Status: 200 OK\r\n")]].."\n")
        file:write([[      uhttpd.send("Content-Type: text/plain\r\n\r\n")]].."\n")
        file:write([[      uhttpd.send(]]..route.handlerController..'.'..route.handlerMethod..'())'.."\n")
        file:write("   end\n")
    end
            
    if route.method == "POST" then
        file:write("   if env.REQUEST_METHOD == '"..route.method.."' and env.REQUEST_URI == '" ..'/lua'..route.path .. "' then\n")
        file:write([[      uhttpd.send("Status: 200 OK\r\n")]].."\n")
        file:write([[      uhttpd.send("Content-Type: text/plain\r\n\r\n")]].."\n")
        file:write([[      uhttpd.send(]]..route.handlerController..'.'..route.handlerMethod..'())'.."\n")
        file:write("   end\n")
    end

end

file = io.open("main.lua", "w+")
if file ~= nil then
    local content = file:read("*a")
    writeImports()

    file:write("function handle_request(env)\n")

    for i, route in ipairs(routes) do
        writeStatements(route)
    end

    file:write("end\n")
end

