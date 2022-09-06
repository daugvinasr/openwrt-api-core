local validation = {}

-- Available validations : required|max:255|min:100|email|
--      |contains:train|number|startsWith:train|endsWith:train|netmask|declined|accepted

function validation.validate(text, validators)
    local tv = 0 -- total validations
    local pv = 0 -- passed validations

    for validator in string.gmatch(validators, '([^|]+)') do

        tv = tv + 1
        local rule, ruleArg = string.match(validator, "([^:]+):([^:]+)")

        local switch = {
            ["max"] = function()
                if max(text, ruleArg) then pv = pv + 1 end
            end,
            ["min"] = function()
                if min(text, ruleArg) then pv = pv + 1 end
            end,
            ["contains"] = function()
                if contains(text, ruleArg) then pv = pv + 1 end
            end,
            ["startsWith"] = function()
                if startsWith(text, ruleArg) then pv = pv + 1 end
            end,
            ["endsWith"] = function()
                if endsWith(text, ruleArg) then pv = pv + 1 end
            end,
            ["required"] = function()
                if required(text) then pv = pv + 1 end
            end,
            ["email"] = function()
                if email(text) then pv = pv + 1 end
            end,
            ["number"] = function()
                if number(text) then pv = pv + 1 end
            end,
            ["ipv4"] = function()
                if ipv4(text) then pv = pv + 1 end
            end,
            ["netmask"] = function()
                if ipv4(text) then pv = pv + 1 end
            end,
            ["string"] = function()
                if isString(text) then pv = pv + 1 end
            end,
            ["declined"] = function()
                if declined(text) then pv = pv + 1 end
            end,
            ["accepted"] = function()
                if accepted(text) then pv = pv + 1 end
            end
        }

        local f
        -- checking if the rule can be split into two parts (rule:arg)
        -- if not then it is a simple rule without args
        if rule ~= nil and ruleArg ~= nil then f = switch[rule] else f = switch[validator]
            if (f) then f() else return false end
            -- if a single rule did not pass the validation stop the validation
            if tv ~= pv then return false end
        end
    end

    if tv == pv then return true else return false end
end

function max(text, ruleArg)
    if tonumber(ruleArg) then
        return string.len(text) <= tonumber(ruleArg)
    else
        return false
    end
end

function min(text, ruleArg)
    if tonumber(ruleArg) then
        return string.len(text) >= tonumber(ruleArg)
    else
        return false
    end
end

function contains(text, ruleArg)
    return string.match(text, ruleArg)
end

function startsWith(text, ruleArg)
    return string.match(text, '^' .. ruleArg)
end

function endsWith(text, ruleArg)
    return string.match(text, ruleArg .. '$')
end

function required(text)
    return string.len(text) > 0
end

function isString(text)
    return type(text) == "string"
end

function email(text)
    return string.match(text, '^[%w+%.%-_]+@[%w+%.%-_]+%.%a%a+$')
end

function number(text)
    return tonumber(text)
end

function ipv4(text)
    local function isInRange(number)
        if tonumber(number) > -1 and tonumber(number) < 256 then return true
        else return false end
    end

    -- if text matches the ipv4 format and each part is in valid ipv4 range
    if string.match(text, '^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$') then
        local a, b, c, d = string.match(text, "([^.]+).([^.]+).([^.]+).([^.]+)")
        if isInRange(a) and isInRange(b) and isInRange(c) and isInRange(d) then return true
        else return false end
    else return false end
end

function declined(text)
    if text == "no" or text == "off" or text == 0 or text == false then
        return true
    else
        return false
    end
end

function accepted(text)
    if text == "yes" or text == "on" or text == 1 or text == true then
        return true
    else
        return false
    end
end

return validation
