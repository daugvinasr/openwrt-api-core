local validation = {}

-- Available validations : required|max:255|min:100|email|
--      |contains:train|number|startsWith:train|endsWith:train|netmask|declined|accepted

function validation.validate(text, validators)
    local tv = 0 -- total validations
    local pv = 0 -- passed validations

    for validator in string.gmatch(validators, '([^|]+)') do
        tv = tv + 1
        local rule, ruleArg = string.match(validator, "([^:]+):([^:]+)")

        if rule ~= nil and ruleArg ~= nil then
            if rule == "max" then if max(text, ruleArg) then pv = pv + 1 end
            elseif rule == "min" then if min(text, ruleArg) then pv = pv + 1 end
            elseif rule == "contains" then if contains(text, ruleArg) then pv = pv + 1 end
            elseif rule == "startsWith" then if startsWith(text, ruleArg) then pv = pv + 1 end
            elseif rule == "endsWith" then if endsWith(text, ruleArg) then pv = pv + 1 end
            end
        else
            if validator == "required" then if required(text) then pv = pv + 1 end
            elseif validator == "email" then if email(text) then pv = pv + 1 end
            elseif validator == "number" then if number(text) then pv = pv + 1 end
            elseif validator == "ipv4" then if ipv4(text) then pv = pv + 1 end
            elseif validator == "netmask" then if ipv4(text) then pv = pv + 1 end
            elseif validator == "string" then if isString(text) then pv = pv + 1 end
            elseif validator == "declined" then if declined(text) then pv = pv + 1 end
            elseif validator == "accepted" then if accepted(text) then pv = pv + 1 end
            end
        end

        if tv ~= pv then return false end
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
        if tonumber(number) > -1 and tonumber(number) < 257 then return true
        else return false end
    end

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
