local memcached    = require "resty.memcached"
local mc_config    = require "conf.memc"
local cjson        = require "cjson"
local say          = ngx.say
local debug        = false
local _M           = {}

local function showError(...)
    if debug then
        say("failed to : ", ...)
    end
end

local memc, err = memcached:new()
if not memc then
    showError("failed to instantiate memc: ", err)
    return false
end
memc:set_timeout(1000)
memc:set_keepalive(10000,1024) 


function _M:connect(memc_name)
    local host = mc_config[memc_name]["host"]
    local port = mc_config[memc_name]["port"]
    local ok, err = memc:connect(host, port)
    if not ok then
        showError("failed to connect: "..host..":"..port, err)
        return false
    end
end

function _M:get(key,memc_name)
    self:connect(memc_name)    
    local res, flags, err = memc:get(key)
    if err then
        showError("failed to get: ", err)
        return false
    end
    if not res then
        showError(key," not found")
        return false
    end
    if type(res) == 'table' then
        res = cjson.decode(res)
    end
    return res
end

function _M:set(key,val,memc_name,expire,flags)
    if not val then
        return false
    end
    self:connect(memc_name)    
    if not expire then
        expire = 0
    end
    if not flags then
        flags = 0
    end
    if type(val) == 'table' then
        val = cjson.encode(val)
    end
    local ok, err = memc:set(key, val, expire, flags)
    if not ok then
        showError("failed to set:",key, err)
        return false
    end
    return true
end

function _M:delete(key,memc_name)
    self:connect(memc_name)
    local ok, err = memc:delete(key, val)
    if not ok then
        showError("failed to delete:",key, err)
        return false
    end
    return true
end




return _M
