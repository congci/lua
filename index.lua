ngx.header.content_type = "text/html;charset=utf-8"

--调试引入、上线后需要注释掉
require "star.func" 

--日志记录初始化--
ngx.ctx.api  = {}
ngx.ctx.time = {}
ngx.ctx.none = {}
--end----






local document_uri      = ngx.var.document_uri        --路径
local route             = require "route";            --路由模块

--[[
--node express框架的风格模式、感觉这个才是最简单的
route.map("dynamic","/api/dynamic",'msite.play.play')
route.map("dynamic","msite/play/play")
route.map("play","/apipc/dynamic",'pc.play.play')
ngx.exit(200)
]]
--下面是走路由配置文件
local mob,action,params = route:match(document_uri);  --获取模块、方法、参数

--保护模式执行
local status,err     = pcall(function()
	local controller = require(mob)
	controller[action](params)
    end
    )
if status then
else
    if ngx.var.arg_debug ~=nil then
    ngx.say(err)
    else
    --ngx.redirect('');
    ngx.say('{"code":"404","msd" : "bad request"}')
    ngx.exit(200)
    end
end

