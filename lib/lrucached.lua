-- lrucache 是worker级别的，意味着works很多的话会非常消耗内存,数据冗余很大
-- 适合热点
-- 直接从进程里取缓存，相比memcached和redis减少了socket消耗 而且可以直接存储table 减少了cpu消耗

local _M = {}
local lrucache = require "resty.lrucache"

local c = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

function _M.get(key)
    local data = c:get(key)
    if type(data) == 'table' then
        data = cjson.decode(data)
    end
    return data
end

function _M.set(key,data,expire)
    if type(data) == 'table' then
        data = cjson.encode(data)
    end
    c:set(key,data,expire)
end

function _M.delete(key)
return c:delete(key)
end

return _M
