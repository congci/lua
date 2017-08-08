local _M = {
    --mms
    mmsApi   = "http://i.api.letv.com",
    videoinfo = "/mms/inner/video/get?"








}


--香港特殊处理

if ngx.var.arg_region == 'hk' then
    _M.mmsApi   = "http://i.api.letv.com"
    _M.videoinfo = "/mms/inner/video/get?"
end



return _M




