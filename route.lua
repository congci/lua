local route        = {}
local route_data   = require "conf.route"
local string_find  = string.find


--循环定位
local function _location(data,path)
    for _,val in ipairs(data) do
        local params = {string_find(path,val['url'])}
        if string_find(path,val['url']) ~= nil then
            local argu = {}   
            for i=1,#params-2 do
                local k = val['params'][i]
                argu[k] = params[i+2]
            end 
            return val['mob'],val['action'],argu
        end
    end  
    return false
end

--默认路径、
function route:_dynamicMatch(path)
    local str      = require "star.string"
    local m_string = string.sub(path,2)
    local wpath    = str.explode("/",m_string)
    local end_index = #wpath
    local platform = ngx.var.arg_playform
    if platform then
        return platform .. '.' .. table.concat(wpath, ".",1,end_index-1),wpath[end_index] 
    end
    return table.concat(wpath, ".",1,end_index-1),wpath[end_index]  
end

-- mob,action,params
function route:match(path)
    local platform = ngx.var.arg_playform
    if platform then
        local mob,action,params = _location(route_data[platform],path)
        if not mob then 
            return false
        end
        return platform .. '.' .. mob,action,params
    end
    --如果没有platfrom，则循环，默认取第一个符合的
	for key,value in pairs(route_data) do
        local mob,action,params = _location(value,path)
        if mob then
            return key .. '.' .. mob,action,params
        end
    end
    return self:_dynamicMatch(path)
end

--简单映射路由
function route.map(fun,match,mod)
    local path = ngx.var.document_uri
    if string_find(path,match) == nil then
        return false
    end  
    local params = {string_find(path,match)}
    if fun == nil then 
        return false
    end
    if mod == nil or match == nil then  
        mod = string.gsub(string.sub(path,2),'/','%.')
    end
    local _r = require(mod)
    _r[fun](params)
end


return route



--[[
1、路由
2、支持配置正则路由
3、默认模块路由
4、支持伪静态
5、支持不同项目路径相同、根据platform来选择

路由配置的文件格式为

return {
    msite = {
        {
            url        = "api/dynamic",
            mob        = "play.play",
            action     = "dynamic",
            params     =　{"vid"}  --做接口的时候一般不需要、一般是做页面伪静态的时候需要
        },
    pc   = {
        {
            url        = "api/play",
            mob        = "play.play",
            action     = "play"
        }
    }


        
    }
    


}
]]