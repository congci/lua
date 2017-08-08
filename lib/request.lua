local _M = {}

function _M.curl(request_url, request_data, method, timeout, host, encoding)
    local timeout   = timeout or 2000
    local startTime = ngx.now()*1000
    local host      = host or "" 
    local encoding  = encoding or ""
    local method    = method or 'GET'
    local request_data = request_data or ""

    local http      = require "lib.http"
    local httpc     = http.new()
    httpc:set_timeout(timeout)

    local headers = {                                                                                           
        ["Content-Type"] = "application/x-www-form-urlencoded",                                             
    }                                                                                                     
    if host ~= nil and host ~= "" then
        headers["Host"] = host
    end
    if encoding ~= nil and encoding ~= "" then
        headers["Accept-Encoding"] = encoding
    end
    local res, err = httpc:request_uri(request_url, {
        method = method,
        body = request_data,
        headers = headers
    })
    local ok = not orr
    local code = ""
    local headers = ""
    local status = ""
    local body = ""
    if res ~= nil then
        code = res.status
        headers = res.headers
        status = res.status
        body = res.body
    end
    local endTime = ngx.now()*1000
    local useTimes = endTime - startTime
    return body,ok, code, headers, status
end
return _M