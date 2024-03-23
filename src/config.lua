--[[
    parses the config.txt file
    supported value types:
        string (quote escapes are supported)
        number
        boolean (true/false)
    rule:
        each line represents a key-value pair
        lines start with the name of your key
        after the name, a space
        then an equals sign
        then another space
        then a value:
            if the character is a `"`, parse string
            if it's a `.` or a digit, parse number
            if it's a `t` and the following characters are `rue`, value is true
            if it's an `f` and the following characters are `alse`, value is false
        any characters after the value will cause a parse error
]]

local config_file = io.open("config.txt");
local config_contents = config_file:read("*a");
config_file:close();

local lines = {};

do
    local index = 0;
    for line in config_contents:gmatch("([^\n]+)\n?") do
        index = index + 1;
        lines[index] = line;
    end;
end;

local function parseError(msg, line_index, index)
    local output = "Failed to parse config!\n\n";
    if line_index > 1 then
        output = output .. line_index - 1 .. "    " .. lines[line_index - 1] .. '\n';
    end;
    output = output .. line_index .. "    " .. lines[line_index] .. '\n';
    output = output .. "    " .. (" "):rep(index) .. "^ " .. msg .. '\n';
    if line_index < #lines then
        output = output .. line_index + 1 .. "    " .. lines[line_index + 1] .. '\n';
    end;

    print(output);
end;

local config = setmetatable({
    custom_curl_path = ""
}, {
    __newindex = function(_, key, _)
        print("Failed to parse config! Unsupported config key '" .. key .. '\'');
    end
});

local STEP = {
    START = 1,
    FIRST_SPACE = 2,
    EQUALS_SIGN = 3,
    SECOND_SPACE = 4,

    STRING_START = 5,
    STRING = 6,
    STRING_BACKSLASH = 7,

    NUMBER_START = 8,
    NUMBER = 9,

    VALUE_END = 10
};

local number_string = nil;
for line_index, line in next, lines do
    local step = 1;
    local name, value = "", nil;
    local index = 1;
    local length = #line;

    local char = '';
    while index <= length do
        char = line:sub(index, index);
        if step == STEP.START then
            if char == ' ' then
                step = STEP.FIRST_SPACE;
            else
                name = name .. char;
            end;
        elseif step == STEP.FIRST_SPACE then
            if char == '=' then
                step = STEP.EQUALS_SIGN;
            else
                return parseError("expected equals sign after space", line_index, index);
            end;
        elseif step == STEP.EQUALS_SIGN then
            if char == ' ' then
                step = STEP.SECOND_SPACE;
            else
                return parseError("expected space after equals sign", line_index, index);
            end;
        elseif step == STEP.SECOND_SPACE then
            if char == '"' then
                step = STEP.STRING_START;
                index = index - 1;
            elseif (char == '.' and index + 1 <= length and line:sub(index + 1, index + 1):match('%d')) or char:match('%d') then
                step = STEP.NUMBER_START;
                index = index - 1;
            elseif (char == 't' and index + 3 <= length and line:sub(index, index + 3) == "true") or (char == 'f' and index + 4 <= length and line:sub(index, index + 4) == "false") then
                step = STEP.VALUE_END;
                index = index + (char == 't' and 3 or 4);
                value = char == 't';
            else
                return parseError("expected start of string, number, or true/false", line_index, index);
            end;
        elseif step == STEP.STRING_START then
            value = '';
            step = STEP.STRING;
        elseif step == STEP.STRING then
            if char == '\\' then
                step = STEP.STRING_BACKSLASH;
            elseif char == '"' then
                step = STEP.VALUE_END;
            else
                value = value .. char;
            end;
        elseif step == STEP.STRING_BACKSLASH then
            if char == '"' then
                step = STEP.STRING;
                value = value .. char;
            else
                return parseError("unsupported escape character '" .. char .. '\'', line_index, index);
            end;

        elseif step == STEP.NUMBER_START then
            number_string = '';
            if char == '.' then
                number_string = char;
            else
                index = index - 1;
            end;
            step = STEP.NUMBER;

        elseif step == STEP.NUMBER then
            if not char:match('%d') then
                return parseError("unallowed (non-digit) character '" .. char .. "' found in number", line_index, index);
            end;
            number_string = number_string .. char;

            if index == length then
                step = STEP.VALUE_END;
            end;

        elseif step == STEP.VALUE_END then
            return parseError("invalid character '" .. char .. "' after value", line_index, index);
        end;
        index = index + 1;
    end;

    if step == STEP.START then
        return parseError("expected space after name", line_index, index);
    elseif step == STEP.FIRST_SPACE then
        return parseError("expected equals sign after space", line_index, index);
    elseif step == STEP.EQUALS_SIGN then
        return parseError("expected space after equals sign", line_index, index);
    elseif step == STEP.SECOND_SPACE then
        return parseError("expected start of string or start of number", line_index, index);
    elseif step == STEP.STRING then
        return parseError("unfinished string", line_index, index);
    elseif step == STEP.VALUE_END then
        if number_string then
            value = tonumber(number_string);
            number_string = nil;
        end;
    end;

    config[name] = value;
end;

return config;