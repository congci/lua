local _M = {}

-- 根据时间字符串取得时间戳
function _M.convertedTimestamp(timeStr)
    local result = ""
    -- timeStr formate: yyyy-mm-dd hh:mm:ss
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local runyear, runmonth, runday, runhour, runminute, runseconds = timeStr:match(pattern)
    local result = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
    return result
end

-- 根据时间戳取得周信息
function _M.getWeekName(timestamp)
    local result = ""
    local weekNames = {
        ['0'] = '日',
        ['1'] = '一',
        ['2'] = '二',
        ['3'] = '三',
        ['4'] = '四',
        ['5'] = '五',
        ['6'] = '六',
    }
    result = weekNames[os.date("%w", timestamp)]
    return result
end


return _M