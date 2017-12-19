local cjson         = require "cjson.safe"
cjson.encode_empty_table_as_object(false)
cjson.encode_sparse_array(true)
local ipairs        = ipairs
local string_find   = string.find
local string_gsub   = string.gsub
local io_open       = io.open
local pairs         = pairs
local _M            = {}


--函数没测、不一定正确
-- function _M.getip()
--     --优先获取远程地址
--     --cdn
--     --x ngx.var.http_x_forwarded_for、需要匹配
--     local pattern =  '/(\d{1,3}\.){3}\d{1,3}/'
--     local m,err   = ngx.re.match(ngx.var.http_x_forwarded_for,pattern)
--     if m then 
--         --返回第一个非内网的地址
--         for _,val in ipairs(m) do
--             if string_find(val, "192%.168%.") == nil  or string_find(val, "10%.") == nil or string_find(val, "172%.16%.") == nil then
--                 return val
--             end
--         end
--     end
--     --remote
--     return ngx.var.remote_arr
-- end


function _M.getclient()
    --http_user_agent
    local user_agent = ngx.var.http_user_agent
    if  user_agent == nil then 
        return 'unkown'
    end

    --根据不同的条件正则不同的环境
    if string_find(user_agent,"") then 
        return ""
    end
end



-- 反转义html字符 xss
function _M.html_entity_encode(data)
    local result = ""
    if data ~= nil then
        result = string_gsub(data, "<", "%&lt;")
        result = string_gsub(result, ">", "%&gt;")
        result = string_gsub(result, " ", "%&nbsp;")
        result = string_gsub(result, "&", "%&amp;")
        -- result = string.gsub(result, "%&quot;", '"')
    end
    return result
end





function _M.output(code,data,callback,msg)
    if not msg then msg = "success" end

    if not callback or not string_find(callback,"^%w+$") then
        ngx.say(cjson.encode{code = code,data = data, msg = msg})
        ngx.exit(200)
    else
        ngx.say(callback .. '(' .. cjson.encode{code = code,data = data,msg = msg} .. ')')
        ngx.exit(200)
    end
end


--ducation秒、格式化成时长
--3600-> 1:00:00
function _M.time_format(durcation)
    local math_floor = math.floor
    if durcation == nil then
        return false
    end
    local hour   = math_floor(durcation / 3600)
    local minute = math_floor((durcation - hour * 3600) / 60)
    local second = durcation - hour * 3600 - minute * 60
    if hour < 10 and hour ~= 0 then 
        hour  = '0' .. hour
    end
    if minute < 10  then
        minute = '0' .. minute
    end
    if second < 10 then
        second = '0' .. second
    end
    if hour then 
        return hour .. ':' .. minute .. ":" .. second
    else
        return minute .. ":" .. second 
    end

end






return _M



