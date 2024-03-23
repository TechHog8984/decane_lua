local serializer = require("src.serializer");
local serialize = serializer.serialize;

local protocol = {};

local CLASS = {

};

local SEND_PAYLOAD_TYPE = {
    CREATE_CLASS = 1
};

function protocol.createClass(class_name, args)
    return string.char(SEND_PAYLOAD_TYPE.CREATE_CLASS) .. CLASS[class_name] .. '\1' .. serialize(args);
end;

return protocol;