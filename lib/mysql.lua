local mysql = require "resty.mysql"
local strs = require "builder.string"
local mysql_config = require "conf.mysql"
local os_date = os.date
local table_insert = table.insert
local ngx_ctx_bug = ngx.ctx.bug
local _M = {}



--实例化
function _M:new()
    local db, err = mysql:new()
    if not db then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. " failed to instantiate mysql: ".. err)
        return false
    end
    db:set_timeout(1000)
    return db
end

function _M:connect(mysql_name)
    local db = self:new()
    local host = mysql_config[mysql_name]['master']["host"]
    local port = mysql_config[mysql_name]['master']["port"]
    local ok, err, _, sqlstate = db:connect {
        host = host,
        port = port,
        user = mysql_config[mysql_name]['master']["user"],
        database = mysql_config[mysql_name]['master']['database'],
        password = mysql_config[mysql_name]['master']["password"],
        max_packet_size = 1024 * 1024
    }
    if not ok then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .." failed to connect: " ..  err .. " " .. host.. " ".. port .. " " .. sqlstate)
        return false
    end
    return db
end



function _M:query(sql, mysql_name)
    local db = self:connect(mysql_name)
    local res, err, errno, sqlstate = db:query(sql)
    if not res then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .." bad result: " ..  err .. ": " ..  errno .. ": " .. sqlstate)
        return false
    end
    self:set_keepalive(db)
    return res
end


--查询所有和全部
function _M:select(sql, mysql_name)
    local db = self:connect(mysql_name)
    local res, err, errno, sqlstate = db:query(sql)
    if not res then
        table_insert(ngx_ctx_bug,os_date("%Y-%m-%d %H:%M:%S") .. "bad result: " .. err ..": ".. errno.. ": ".. sqlstate)
        return false
    end
    self:set_keepalive(db)
    return res
end

function _M:set_keepalive(db)
    local _, err = db:set_keepalive(10000, 1000)
    if err then
        db:close()
    end
end

--暂时只查全部
function _M:sql(sql, mysql_name)
    local mtype = strs.explode(" ", sql)
    if mtype[1] == 'select' then
        return self:select(sql, mysql_name)
    end
end




return _M