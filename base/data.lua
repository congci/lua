--扩展了架构、可以单独用缓存和请求、在控制器里更加的灵活、暂时去掉lrucache缓存

local memcached    = require "lib.memc"
-- local lrucache     = require "lib.lrucached"
local mysql        = require "lib.mysql"
local request      = require "lib.request"
local cjson        = require "cjson.safe"
local str          = require 'star.string'
local arr          = require "star.array"
local config       = require "conf.common"
local table_insert = table.insert
local os_date      = os.date
local empty        = arr.empty
local time         = ngx.time
local random       = math.random

--定义现在时间
local nowTime      = time() 

local _M           = {}


--缓存顺序lrucache --> localcache  -->  cbase -->  mysql/第三方接口

function _M:getData(targu)
    local targu           = targu or {}
    local urlorsql        = targu.urlorsql
    local prefix          = targu.prefix or ''
    local callback        = targu.callback
    local usecbase        = targu.usecbase or true   -- cbase缓存
    local localcache      = targu.localcache
    local expire          = targu.expire or 600
    local issql           = targu.issql or false
    local db              = targu.db or '_db'
    local downgrade       = targu.downgrade or {}
    local mq_tag          = targu.mq_tag or ''
    local models_source   = targu.model_source or ''
    -- local ishot           = targu.ishot or nil
    local key = prefix .. ngx.md5(urlorsql)

    -- 缓存
    local data = {}
    if ngx.var.arg_flush then 
        if uselocalcache and config.localcache ~= false then
            data = self:getlocalcache(key)
            if data then
                return data
            end
        end
         -- 远程cbase缓存
        if usecbase and config.cbase ~= false then  
            data = self:getcbase(key)
             if data then
                return data
            end
        end
    end
    --请求
    local result = {}
    local begin_time = time()
    if issql then
        data = mysql:sql(urlorsql,db)
    else
        data = request.curl(urlorsql)
        res_data = cjson.decode(data)
        --全球化特殊处理
        if empty(res_data.data) or res_data.data == nil or data == 'null' then
            data = self:defaultDta(urlorsql)
            res_data = cjson.decode(data)
        end
    end
    local end_time  = time()

    --处理和存储
    if res_data ~= nil then
        if callback ~= nil then
            res_data = callback(res_data) -- 回调函数调用的时候,不支持直接self
        end
        --更新缓存
        result['data'] = data
        result['cbase_time'] = nowTime + expire
        result['local_time'] = nowTime + 300 + random(1,300)
        -- result['lru_time'] = time + lrucache_expire
        self:setcache(urlorsql,result,expire)
    end
    --ngx.ctx记录日志 在日志阶段执行
    local use_times = end_time - begin_time
    table_insert(ngx.ctx.time,os_date("%Y-%m-%d %H:%M:%S") .. " " .. urlorsql .. " " .. use_times)
    if data == nil or next(res_data) == nil then
        table_insert(ngx.ctx.none,os_date("%Y-%m-%d %H:%M:%S") .. " " .. urlorsql .. " " .. use_times)
    end
    return res_data
end

--清除缓存
function _M.clearcache(key)
    -- lrucache.delete(key)
    memcached.delete(key,'cbase')
    memcached.delete(key,'localcache')
end

--获取lrucache进程内缓存
function _M:getlrucache(key,expire)
    local data = lrucache:get(key)
    if data then
        if not empty(data) and data['lru_time'] > nowTime then
            return data['data']
        end
    end
    return false    
end

--获取本地memcached缓存
function _M:getlocalcache(key,expire)
    local data = memcached:get(key,'localcache')
    if data then
        if  data['local_time'] > nowTime then
            return data['data']
        else
            memcached:get(key,data,'localcache')
        end
    end
    return false
end

--获取远程cbase缓存
function _M:getcbase(key,expire)
    local data = memcached:get(key,'localcache')
    if data then
        if  data['cbase_time'] > nowTime then
            return data['data']
        else
            memcached:get(key,data,'localcache')
        end
    end
    return false
end

--设置缓存
function _M:setcache(key,data,expire)
    local localexpire = 300 + random(1,300)
    -- lrucache:set(key,data,'localcache',300)
    memcached:set(key,data,'localcache',localexpire)
    memcached:set(key,data,'cbase',expire)
end

--全球化默认数据、特殊处理
function _M:defaultDta(url)
    local lang_arr = {'lang=en_us','lang=zh_hk','lang=en'}
    --在香港和印度、如果没有数据、则取默认数据
    if ngx.var.lang ~= 'zh_cn' and (ngx.var.region == 'en' or ngx.var.region == 'hi') then
        str.str_replace(lang_arr,'lang=zh_cn',url)
        return request.curl(url)
    end
    if ngx.var.lang == 'en_us' and ngx.var.region == 'hk' then
        str.str_replace(lang_arr,'lang=zh_hk',url)
        return request.curl(url)
    end
    return false
end

return _M
