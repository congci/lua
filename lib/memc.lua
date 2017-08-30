local memcached = require "resty.memcached"
local mc_config = require "conf.memc"
local cjson = require "cjson.safe"
local say = ngx.say
local os_date = os.date
local table_insert = table.insert
local ngx_ctx_bug = ngx.ctx.bug
local type = type
local _M = {}



function _M:new()
    local mem, err = memcached:new()
    if not mem then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. " failed to instantiate memc: " ..  err)
        return false
    end
    mem:set_timeout(1000)
    return mem
end

function _M:connect(memc_name)
    local mem = self:new(memc_name)
    local host = mc_config[memc_name]["host"]
    local port = mc_config[memc_name]["port"]
    local ok, err = mem:connect(host, port)
    if not ok then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. "failed to connect: " .. host .. ":" .. port .. " " .. err)
        return false
    end
    return mem
end

function _M:set_keepalive(mem)
    local _, err = mem:set_keepalive(10000, 1000)
    if err then
        mem:close()

    end
end

function _M:get(key, memc_name)
    local mem = self:connect(memc_name)
    local res, _, err = mem:get(key)
    if err then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .." failed to get: " .. err)
        return false
    end
    res = cjson.decode(res)
    self:set_keepalive(mem)
    return res
end

function _M:set(key, val, memc_name, expire, flags)
    if not val then
        return false
    end
    local mem = self:connect(memc_name)
    if not expire then
        expire = 0
    end
    if not flags then
        flags = 0
    end
    if type(val) == 'table' then
        val = cjson.encode(val)
    end
    local ok, err = mem:set(key, val, expire, flags)
    if not ok then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. " failed to set: " .. key .. " "  ..err)
        return false
    end
    self:set_keepalive(mem)
    return true
end

function _M:delete(key, memc_name)
    local mem = self:connect(memc_name)
    local ok, err = mem:delete(key)
    if not ok then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. " failed to delete: ".. key .." " ..  err)
        return false
    end
    self:set_keepalive(mem)
    return true
end




return _M
