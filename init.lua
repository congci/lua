--设置共享内存
--共享内存知

local config        = ngx.shared.config
local config_data   = require "conf.shared"
local cjson         = require "cjson"


for key,val in pairs(config_data) do
    if type(val) == 'table' then
        val  = cjson.encode(val)
    end
    config:set(key,val)
end











