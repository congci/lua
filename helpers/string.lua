--函数只使用一次的不需要弄成局部变量、多次试用、需要弄成局部变量
local string_find  = string.find
local string_sub   = string.sub
local table_insert = table.insert
local string_gsub  = string.gsub
local type         = type
local _M = {}




--将字符串拆分成table
function _M.explode(d,p)
    local t = {}
    local ll = 0
    if(#p == 1) then 
        return p 
    end
    while true do
        l = string_find(p, d, ll + 1, true) 
        if l ~= nil then 
            table_insert( t, string_sub( p, ll, l-1 ) ) 
            ll = l + 1 
        else
            table_insert( t, string_sub( p, ll ) ) 
            break 
        end
    end
    return t
end


--批量替换
function _M.str_replace(mtable,replace,str)
   if type(mtable) == 'table' and type(replace) == 'table' then
       if #mtable ~= #replace then
           return str
        else
           for i = 1,#mtable do
            str = string_gsub(str,mtable[i],replace[i])
           end
        end
    end
    if type(mtable) == 'table' and type(replace) == 'string' then
       for i = 1,#mtable do 
        str = string_gsub(str,mtable[i],replace)
       end
    end
    if type(mtable) == 'string' and type(replace) == 'string' then
       str = string_gsub(str,mtable,replace)
    end
    return str 
end


--批量查找
function _M.str_find(str,findstr)
  local flag = false 
  if type(findstr) == 'table' then
    for key,val in ipairs(findstr) do
       if string_find(str,val) then
          flag = true
       end
       break
    end
  end
  if type(findstr) == 'string' then
       if string_find(str,val) then
          flag = true
       end
  end
  return flag
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







return _M
