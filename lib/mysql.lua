local mysql         = require "resty.mysql"
local util          = require "lib.util"
local mysql_config  = require "conf.mysql"
local say           = ngx.say
local debug         = false
local _M            = {}


local function showError(...)
    if debug then
        say("failed to : ", ...)
    end
end

--实例化
local db, err = mysql:new()
if not db then
    showError(err)
    return false
end

--连接

function _M.connect(self,mysql_name)
    local ok, err, errno, sqlstate = db:connect{
        host = mysql_config[mysql_name]["host"],
        port = mysql_config[mysql_name]["port"],
        user = mysql_config[mysql_name]["user"],
        database = mysql_config[mysql_name]['database'],
        password = mysql_config[mysql_name]["password"],
        max_packet_size = 1024 * 1024 
    }
    if not ok then
        showError(err)
        return false
    end
end


function _M.query(self,sql,mysql_name)
    self:connect(mysql_name)
    local res, err, errno, sqlstate = db:query(sql)
    if not res then
        showError("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return false
    end
    return res
end

function _M:sql()
     

end

function _M:select(sql,mysql_name)
    self:connect(mysql_name)
    local res, err, errno, sqlstate = db:query(sql)
    if not res then
        showError("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return false
    end
   local data = {}
   for i, row in ipairs(res) do 
       data[i] = row 
    end  
return data
end

function _M:sql(sql)
    local mtype = util.explode(" ",sql)
    if mtype[1] == 'select' then 
        return self:select()
    
    end
end




return _M