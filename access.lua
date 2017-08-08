-- 权限限制、白名单黑名单、检测参数合法性等
--mysql注入、xss\csrf、ddos

--检测参数合法性 
local arguments   = ngx.req.get_uri_args()
local arr        = require "star.array"
local string_find = string.find
local filter      = {'%%','>','<','delete','insert','update','%*','\'','"'}




-- mysql 注入 1、过滤 2、直接返回错误
-- 只是返回错误、过滤还没实现

for key,val in pairs(arguments) do
    for a,b in pairs(filter) do 
      	if string_find(val,b) then
      	    ngx.say('{"data" : "error","msg" : "bad request"}')
            ngx.exit(200)
    	  end
    end
end


--xss\csrf 转换字符串,csrf最好的方式其实是设置令牌，但是接口不适合、
--ddos 设置黑名单，可以比nginx更细腻的控制 --这样获取ip并不是很准，需要些获取ip函数

local black_ip = {
  '10.154.238.107'
}

if arr.in_array(ngx.var.remote_addr,black_ip) then
  ngx.say('{"data" : "error","msg" : "bad request"}')
  ngx.exit(200)
end








