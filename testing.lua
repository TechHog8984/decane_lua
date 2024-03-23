local config = require("src.config");
local protocol = require("src.protocol");

local curl_path = config.custom_curl_path == '' and "curl" or config.custom_curl_path;

local curl_help_process = io.popen(curl_path .. " -h");
local curl_help_result = curl_help_process:read();

local function clearPutMessage();
    os.execute("clear");
    print("#########__DECANE_BY_TECHHOG__#########\n");
end;

clearPutMessage();

local function err(msg)
    print("An error has occured! " .. msg);
end;

if curl_help_result ~= "Usage: curl [options...] <url>" then
    err("Failed to find curl! Ensure it is in path or enter a valid custom_curl_path in config.");
    curl_help_process:close();
    return;
end;

curl_help_process:close();

