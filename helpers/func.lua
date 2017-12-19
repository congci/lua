-----------------------------------------------------------------------------------
-- common function
-- date: 2016-07-12
-- author: NLence<wangchuanbo@le.com>
-- version:1.0
-----------------------------------------------------------------------------------

--local functions = {}

-- debug打印table，当然可以打印所有的类型
-- todo 不能打印nil,nil开头的多个值
-- notice!!! 多值打印的时候nil不能打印出来,eg {20, nil, 'nlence'}
function pr(...)
    local params = {...}
    if type(params) == 'table' and next(params) ~= nil then
        for k,v in pairs(params) do
            if type(v) == 'talbe' then
                print_r(v)
                ngx.say('---------------------------------------------------')
            else
                ngx.say('<pre>')
                ngx.say(tostring(k) ..'  => ' .. tostring(v))
                ngx.say('---------------------------------------------------')
                ngx.say('</pre>')
            end
        end
    else
            ngx.say(params)
    end
end

-- 单值打印
function p(p)
    if type(p) == 'table' then
        print_r(p)
    else
        ngx.say(p)
    end
end

function print_r( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if print_r_cache[tostring(t)] then
            ngx.say(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)] =  true
            if type(t) == "table" then
                -- todo table中有nil,不会被打印
                for pos,val in pairs(t) do
                    if type(val) == "table" then
                        ngx.say(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        ngx.say(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif type(val) == "string" then
                        ngx.say(indent.."["..pos..'] => "'..val..'"')
                    else
                        ngx.say(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                ngx.say(indent..tostring(t))
            end
        end
    end
    ngx.say('<pre>')
    if (type(t) == "table") then
        ngx.say(tostring(t).." {")
        sub_print_r(t,"  ")
        ngx.say("}")
    else
        sub_print_r(t,"  ")
    end
    ngx.say('</pre>')
end

-- 快速退出
function die( msg )
    if msg ~= nil and msg ~= '' then
        if type(msg) == 'table' then
            p(msg)
        else
            ngx.say(msg)
        end
    end
    ngx.exit(200)
end
--return functions