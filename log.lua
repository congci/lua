--日志记录放到log_by_lua_file   这个阶段异步执行 
--依赖 ngx.ctx 是个table
--记录日志的文件可能有多个、用二维key来区分、比如ngx.ctx.api = {} ngx.ctx.time = {} 分别记录到相应的文件
--二维key需要在入口文件里先设置 比如ng.ctx.api    请求级别
--适合异步发送到日志服务器


local os_date = os.date
local io_open = io.open
local table_concat = table.concat


local LOG_FILE = {
   api  = "/letv/logs/lua_api_request_api.log.".. os_date("%Y-%m-%d"),
   none = "/letv/logs/lua_api_request_none.log.".. os_date("%Y-%m-%d"),
   time = "/letv/logs/lua_api_request_time.log.".. os_date("%Y-%m-%d")
}


--原理就是 ngx.ctx 和 LOG_FILE 的键一一对应，当然也可以单写

for key,val in pairs(LOG_FILE) do
	if next(ngx.ctx[key]) ~= nil then 
	    local str = table_concat(ngx.ctx[key],'\n')
	    local f = assert(io_open(val,'a+'))
        f:write(str .. '\n')
        f:close()
    end
end
