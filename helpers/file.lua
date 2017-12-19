local io_open = io.open


--文件是否存在
function _M.file_exists(filename)
    local file = assert(io_open(path,"a+"))
    if file then file:close() end
    return file ~= nil
end

function _M.write(path,content)
	if path == nil then
        return false
	end
    local file = assert(io_open(path,"a+"))
    file:write(content.."\n")
    file:close()
end

--不能读大文件
function _M.read(path)
	if path == nil then
        return false
	end
    local file = assert(io_open(path,'r'))
    file:read("*a")
    file:close();
end
return _M