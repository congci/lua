local _M = {}
local string_gsub = string.gsub

function _M.parseStaticArgs(uri,d)
    local temp = {}
    if uri then
        local t = explode(d, uri)
        for k,v in ipairs(t) do
            if k % 2 == 1 then
                temp[v] = t[k+1]
            end
        end
    end
    return temp
end

-- 简单的参数过滤
function _M.filter(string)
    local filter = {'#','%%','>','<','delete','insert','update','%*'}
    for i = 1,#filter do 
        string = string_gsub(string,filter[i],'')
    end
    return string
end

return _M