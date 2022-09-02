local password = "3"



-- Available validations required|max:255|min:100|email|contains:train|number|startsWith:train





local function validate(text, validators)

    local parsedValidators = {}

    for k in string.gmatch(validators, '([^|]+)') do
        table.insert(parsedValidators, k)
    end

    local tv = 0
    local pv = 0
    for i, validator in ipairs(parsedValidators) do
        tv = tv + 1
        if string.sub(validator, 1, 3) == "max" then if string.len(text) <= tonumber(string.sub(validator, 5)) then pv = pv + 1 end end
        if string.sub(validator, 1, 3) == "min" then if string.len(text) >= tonumber(string.sub(validator, 5)) then pv = pv + 1 end end
        if string.sub(validator, 1, 8) == "contains" then if string.match(text, string.sub(validator, 10)) then pv = pv + 1 end end
        if string.sub(validator, 1, 10) == "startsWith" then if string.match(text, '^'..string.sub(validator, 12)) then pv = pv + 1 end end
        if string.sub(validator, 1, 8) == "endsWith" then if string.match(text, string.sub(validator, 10)..'$') then pv = pv + 1 end end
        if validator == "required" then if string.len(text) > 0 then pv = pv + 1 end end
        if validator == "email" then if string.match(text, '^[%w+%.%-_]+@[%w+%.%-_]+%.%a%a+$') then pv = pv + 1 end end
        if validator == "number" then if tonumber(text) then pv = pv + 1 end end
        if validator == "ipv4" then if string.match(text, '^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$') then pv = pv + 1 end end
    end
    if tv == pv then return true else return false end
end


print(validate(password, "required|number"))

