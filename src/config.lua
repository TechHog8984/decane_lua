local config_file = io.open("config.txt");
local config_contents = config_file:read("*a");

local config = {
    custom_curl_path = ""
};

for line in config_contents:gmatch("([^\n]+)\n?") do
    local step = 1;
    local name, value = "", nil;
    local index = 1;
    local length = #line;

    local char = '';
    while index < length do
        char = line:sub(index, index);
        if step == 1 then
            if char == ' ' then
            elseif char == '=' then
                step = 2;
            else
                name = name .. char;
            end;
        elseif step == 2 then
            if char == ' ' then
                step = 3;
            else
                error("expected space after equal sign");
            end;
        end;
        index = index + 1;
    end;

    print(name);
end;