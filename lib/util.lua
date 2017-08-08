local cjson         = require "cjson"
local ipairs        = ipairs
local setmetatable  = setmetatable
local shared        = ngx.shared
local string_find   = string.find
local string_sub    = string.sub
local string_gsub   = string.gsub
local io_open       = io.open
local table_insert  = table.insert
local pairs         = pairs
local _M            = {}








function _M.getip()
  
end







--日志
function _M.log(path,filename,content)
    local file = io_open(path.."/"..filename,"a+")
    file:write(content.."\n")
    file:close()
end


-- 根据时间字符串取得时间戳
function _M.convertedTimestamp(timeStr)
    local result = ""
    -- timeStr formate: yyyy-mm-dd hh:mm:ss
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local runyear, runmonth, runday, runhour, runminute, runseconds = timeStr:match(pattern)
    local result = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})

    return result
end

-- 根据时间戳取得周信息
function _M.getWeekName(timestamp)
    local result = ""
    local weekNames = {
        ['0'] = '日',
        ['1'] = '一',
        ['2'] = '二',
        ['3'] = '三',
        ['4'] = '四',
        ['5'] = '五',
        ['6'] = '六',
    }
    result = weekNames[os.date("%w", timestamp)]

    return result
end

--表中元素个数
function _M.count(tname)
    local count = 0
    for key,val in pairs(tname) do
        count = count + 1
    end
    return count
end

--两个数组表合并 json转换的时候，数组依旧转换为数组（对项目而言）
function _M.merge(dest, src)
    -- todo return {}
    if type(dest) ~= 'table' or type(src) ~= 'table' then return {} end
    local i = 1
    for k, v in pairs(src) do
        if type(k) == 'string' then
        dest[k] = v
        else
        dest[#dest + i] = v --只才数组元素最后开始，所以用#
        i = i + 1
        end
    end
    return dest
end

function _M.slice(tOld,start,tend)
    local tnew = {}
    for i = 1,tend - start + 1 do
        tnew[i] = tOld[i+start]
    end
    return tnew
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

function _M.output(code,data,callback)
    if not callback or not string_find(callback,"^%w+$") then
      ngx.say(cjson.encode{code = code,data = data})
    else
      ngx.say(callback .. '(' .. cjson.encode{code = code,data = data} .. ')')
    end
end

--简单映射路由
function _M.map(match,fun)
    local params = {string_find(ngx.var.document_root,key)}
    if params[1] ~= nil and fun ~=nil then 
        fun(params)
    end
end

-- 简单的参数过滤
function _M.filter(string)
    local filter = {'#','%%','>','<','delete','insert','update','%*'}
    for i = 1,#filter do 
        string = string_gsub(string,filter[i],'')
    end
    return string
end

--检验是否在数组里
--strict 如果是严格模式，如果类型不同，不相等
function _M.in_array(key,mtable,strict)
    local flag = false
    for key,val in pairs(mtable) do
        if strict then
            if val == key then
                flag = true
            end
        else
            if tostring(val) == tostring(key) then
                flag = true
            end
        end
    end
    return flag
end

function _M.key(mtable)
    if type(mtable) ~= 'table' then
      return false
    end
    for key,val in pairs(mtable) do
        return key
    end
end

-- get table keys , like php array_keys
-- return table
function _M.table_keys(metatable)
    if type(metatable) ~= 'table' then
            return {}
    end

    local metatable_keys = {}
    for k , v in pairs(metatable) do table_insert(metatable_keys,k) end
    return metatable_keys
end

function _M.empty(key)
    if type(key) == 'table' then
        return next(key) == nil
    end
    if key == nil or tostring(key) == '' or tonumber(key) == 0 or type(key) == 'userdata' then
        return true
    end

    return false
end

-- trim todo 加强 \r\n \t 等
-- 不优，需要优化/改写
function _M.metatrim(str,delimiter,direction)
    local str = str
    if str == nil or type(str) ~= 'string' then return '' end
    if delimiter == nil then local delimiter = ' ' end

    local pos_begin = nil
    if direction == 'left' then
        pos_begin,_ = string_find(str,delimiter,1)
    elseif direction == 'right' then
        pos_begin,_ = string_find(str,delimiter,-1)
    else
        return str
    end

    if pos_begin == 1 then
        str = string_sub(str,2,-1)
        return _M.metatrim(str,delimiter,direction)
    elseif pos_begin == #str then
        str =  string_sub(str,1,-2)
        return _M.metatrim(str,delimiter,direction)
    else 
        return str
    end
end

function _M.ltrim(str,delimiter)
    return _M.metatrim(str,delimiter,'left')
end

function _M.rtrim(str,delimiter)
    return _M.metatrim(str,delimiter,'right')
end

function _M.trim(str,delimiter)
    local lstr = _M.ltrim(str,delimiter)
    return _M.rtrim(lstr,delimiter)
end

function _M.table_values(metatable)
    if metatable == nil or type(metatable) ~= 'table' then return {} end

    local metatable_values = {}
    for _, v in pairs( metatable ) do
            table_insert(metatable_values, v )
    end

    return  metatable_values
end

return _M



