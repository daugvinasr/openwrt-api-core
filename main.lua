local routes = require "./uhttpd/routes"
local middleware = require "./uhttpd/middleware"
local json = require("cjson")

function logPrint(text)
   io.stderr:write(string.format("\n"))
   io.stderr:write(string.format(text .. "\n"))
   io.stderr:write(string.format("\n"))
end

function sendOk(uhttpd)
   uhttpd.send("Status: 200 OK\r\n")
   uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function sendInternalError(uhttpd)
   uhttpd.send("Status: 500 Internal Server Error\r\n")
   uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function sendForbidden(uhttpd)
   uhttpd.send("Status: 401 Forbidden\r\n")
   uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function sendNotFound(uhttpd)
   uhttpd.send("Status: 404 Not Found\r\n")
   uhttpd.send("Content-Type: application/json\r\n\r\n")
end

function getBody(uhttpd, env)
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

function getParameters(env)
   if env.QUERY_STRING ~= nil and env.QUERY_STRING ~= '' then
      local params = {}
      for k, v in string.gmatch(env.QUERY_STRING, "([^&=]+)=([^&=]+)") do
         params[k] = v
      end
      if params ~= {} then return params else return nil end
   else return nil end
end

function getAuthorization(env)
   if env.HTTP_AUTHORIZATION ~= nil and env.HTTP_AUTHORIZATION ~= '' then
      local authorization = {}
      for k, v in string.gmatch(env.HTTP_AUTHORIZATION, "([^ ]+) ([^ ]+)") do
         authorization[k] = v
      end
      if authorization ~= {} then return authorization else return nil end
   else return nil end
end

function middlewareCheck(route, authorization)
   local totalChecks = 0
   local passedChecks = 0

   for i, ware in ipairs(route.middleware) do
      totalChecks = totalChecks + 1
      local middlewareResponse
      local status, error = pcall(function() middlewareResponse = middleware[ware](authorization) end)
      if middlewareResponse and status then
         passedChecks = passedChecks + 1
      end
   end

   if totalChecks == passedChecks then return true else return false end
end

function handle_route(env, route)
   local controller = require("./uhttpd/controllers/" .. route.handlerController)
   local method = route.handlerMethod
   local params = getParameters(env)
   local body = getBody(uhttpd, env)
   local authorization = getAuthorization(env)
   local middlewareStatus = nil
   local response

   if route.middleware ~= nil then
      middlewareStatus = middlewareCheck(route, authorization)
   end

   if middlewareStatus == true or middlewareStatus == nil then
      local status, error = pcall(function() response = controller[method](params, body, authorization) end)
      if status then
         sendOk(uhttpd)
         uhttpd.send(json.encode(response))
         os.exit()
      else
         sendInternalError(uhttpd)
         os.exit()
      end
   else
      sendForbidden(uhttpd)
      os.exit()
   end
end

function handle_request(env)
   for i, route in ipairs(routes) do
      if route.method == env.REQUEST_METHOD and route.path == env.PATH_INFO then
         handle_route(env, route)
         os.exit()
      end
   end
   sendNotFound(uhttpd)
   os.exit()
end
