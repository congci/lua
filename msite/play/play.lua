local _M = {}
local base   = require "base.data"
local config = require "conf.common"
local util   = require "star.util"

local Api = require "conf.global"


function _M.getVideoInfo(vid,platform)
	local platform = platform or 'msite'
	local token    = ngx.md5(vid .. platform .. config.mmsKey)
	local url      = Api._mmsApi .. '/mms/inner/video/get?id='.. vid ..'&type=1&vmode=0&token='.. token ..'&platform=' .. platform
	local targu    = {urlorsql = url} 
	local data     = base:getData(targu)
	return data['data']
    
end



function _M:dynamic()
	local vid = ngx.var.arg_vid
    local data =  _M.getVideoInfo(vid)
    util.output(200,data)
end

return _M