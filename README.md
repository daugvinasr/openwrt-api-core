## openwrt-api-core

Implementation of uhttpd using lua, while trying to add modern backend framework features

### Implemented Features:

* Controllers
* Routes
* Middleware
* Validation 
* Built-in UCI wrapper for easy config file manipulation
* Certificate generation, signing, and viewing
* JWT token login and expiration validation
* File Upload

### Controllers

To make a new controller create a file in the controllers folder.

* File MUST Start with 
`local YourControllerName = {}`
* To include methods in your controller methods MUST have a prefix `YourControllerName.functionName()`
* File MUST end with `return YourControllerName`

The usual controller response looks like this:

`return <Status Name>, <Status Code>, <Response>`

Example:

`return "OK", 200, "Configuration saved successfully"`

If you want to return data you can pass a lua table

```return "OK", 200, { certs = dataCert, reqs = dataReq, dh = dataDH, keys = dataKey }```

<!-- Controller must return a response, otherwise `Status: 500 Internal Server Error` will be returned -->

### Routes

To add a new route modify `routes.lua` file. A route with all of the options looks something like this: 
```
    {
        path = "/usersOnline",
        method = "GET",
        handlerController = "MainController",
        handlerMethod = "usersOnline",
        middleware = {
            "checkUserSpecificRules",
        }
    }
```

### Middleware

To add a new middleware modify `middleware.lua` file. Middleware functions work exactly the same way as the controller functions so the same rules apply here, but the middleware function MUST return true or false, otherwise `Status: 500 Internal Server Error` will be returned

```
function middleware.checkIfTokenIsValid(authorization)
    if authorization["Bearer"] ~= nil then
        local token = authorization["Bearer"]
        local decoded, err = jwt.decode(token, env.jwtKey, true)
        if decoded ~= nil then
            return true
        else
            return false
        end
    else
        return false
    end
end
```


### Validation

Validation can be used like this:

`validate(<Input>, <Validation Parameters>)`

Validation parameters can be stacked using pipes like this:

```
if validation.validate(text, "required|max:10|min:2") then
    return "OK", 200, "Validation passed"
else
    return "OK", 300, "Validation failed"
end
```


Available validations
* required
* max:`int`
* min:`int`
* email
* number
* string
* contains:`string`
* startsWith:`string`
* endsWith:`string`
* ipv4
* netmask
* declined
* accepted

### UCI Wrapper

Supported functions:

* loadConfig(configName)
* commit()
* revert()
* reloadConfigs()
* addTyped(sectionName, data)
* addNamed(sectionName, sectionTitle, data)
* addOption(sidOrSectionTitle, data)
* deleteSection(sidOrSectionTitle)
* deleteOption(sidOrSectionTitle, optionName)
* reorder(sidOrSectionTitle, position)
* getSections(sectionName)
* getSection(sectionName, sidOrSectionTitle)

Basic usage of config handler:

```
local configs = {
    { option = 'enabled', value = 1 },
    { option = 'use_tls_ssl', value = 0 },
    { option = 'client_enabled"', value = 0 },
    { option = 'persistence', value = 0 },
    { option = 'anonymous_access', value = 1 },
    { option = 'local_port', value = 1883 }
}

local handler = config_handler.loadConfig("mosquitto")
handler:addNamed("mqtt", "mqtt", configs)
handler:commit()
handler:reloadConfigs()
```

### Certificate Generation

Supported functions:
* generate_ca(subject, directory, name, keySize)
* generate_cert(subject, directory, name, caName, keySize, daysValid)
  - **caName** and **daysValid** can be set to `false` if you wish to not sign your certificates
* generate_dh(directory, name, keySize)

### Certificate Information

* getCertInfo(path)
  - **path** is direct path to a folder and **NOT** a file.
  - returns **certs**, **keys**, **requests** and **dh** in lua table

Output looks something like this:
```
{
	"dh": {},
	"certs": [
		{
			"commonName": "ca",
			"notafter": 1695981120,
			"filePath": "\/usr\/lib\/lua\/uhttpd\/certs\/ca.cert.pem",
			"keyLength": 512,
			"fileType": "cert",
			"fileName": "ca.cert.pem",
			"notbefore": 1664445120
		}
	],
	"keys": [
		{
			"filePath": "\/usr\/lib\/lua\/uhttpd\/certs\/ca.key.pem",
			"fileType": "key",
			"fileName": "ca.key.pem",
			"keyLength": 512
		}
	],
	"reqs": [
		{
			"commonName": "ca",
			"filePath": "\/usr\/lib\/lua\/uhttpd\/certs\/ca.req.pem",
			"fileType": "req",
			"fileName": "ca.req.pem",
			"keyLength": 512
		}
	]
}
```
### JWT Tokens

An example of JWT token usage for login can be found in `controllers/MainController.lua`

### File Upload

An example of file upload can be found in `controllers/MainController.lua`



