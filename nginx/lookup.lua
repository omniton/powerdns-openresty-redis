
local function return_result(records)
    local i, rec
    ngx.say('{"result":[')
    for i, rec in ipairs(records) do
        if i ~= 1 then ngx.say(',') end
        ngx.print(rec)
    end
    ngx.say(']}')
end

local function error_result(msg, status)
    ngx.status = status
    ngx.say('{"result":false, "error":"', msg, '"}')
    ngx.log(ngx.ERR, msg)
    ngx.exit(ngx.status)
end

local redis = require "resty.redis"
local res, err, key, i, records, rec_type, match

-- connect to redis
redis = redis:new()
redis:set_timeout(100)
if ngx.var.redis_host and ngx.var.redis_port then
    res, err = redis:connect(ngx.var.redis_host, ngx.var.redis_port)
elseif ngx.var.redis_unix then
    res, err = redis:connect(ngx.var.redis_unix)
end
if not res then error_result('failed redis connect', 500) end

-- select db
if ngx.var.redis_db then redis:select(ngx.var.redis_db) end

-- get all keys matched name/*
rec_type = string.upper(ngx.var.rec_type)
if rec_type == 'ANY' then
    match = ngx.var.name .. '/*'
    if match:sub(1,1) == '*' then match = '\\' .. match end
    res, err = redis:keys(match)
    if not res[1] then error_result('record not found', 404) end

    records = {}
    for i, key in ipairs(res) do
        for i, rec in ipairs(redis:lrange(key, 0, 1000)) do
            table.insert(records, rec)
        end
    end
    return_result(records)
    return
end

-- get records for key name/type
records, err = redis:lrange(ngx.var.name .. "/" .. rec_type, 0, 1000)
if not records[1] then error_result('record not found', 404) end
return_result(records)
