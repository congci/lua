local _M = {}
local table_insert = table.insert

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

--表中元素个数、一般用不到
function _M.count(tname)
    local count = 0
    for key,val in pairs(tname) do
        count = count + 1
    end
    return count
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

--是否为空
function _M.empty(key)
    if type(key) == 'table' then
        return next(key) == nil
    end
    if key == nil or tostring(key) == '' or tonumber(key) == 0 or type(key) == 'userdata' then
        return true
    end
    return false
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


function _M.table_values(metatable)
    if metatable == nil or type(metatable) ~= 'table' then return {} end
    local metatable_values = {}
    for _, v in pairs( metatable ) do
            table_insert(metatable_values, v )
    end

    return  metatable_values
end


return _M
