--
-- Created by IntelliJ IDEA.
-- User: LandingLX
-- Date: 2018/7/27
-- Time: 22:35
-- To change this template use File | Settings | File Templates.
--

local uri = ngx.var.uri
local mysql = require "resty.mysql"
local cjson = require "cjson"
local quote = ngx.quote_sql_str

local arg = ngx.req.get_uri_args()
for k,v in pairs(arg) do
    ngx.say("[GET] key:",k," v:",v)
end


local db,err = mysql:new()
if not db then
    ngx.say(cjson.encode({success=false,info=err}))
    return
end



local ok ,err ,errno,sqlstate = db:connect{
    host="47.254.25.109",
    port=3306,
    database="ngx_test",
    user="root",
    password = "Liuxinis1",
    max_packet_size=1024*1024
}

if not ok then
    ngx.say(cjson.encode({success=false,info=err,info2=errno}))
    return
end

local sql  = "insert into UserBase (UserEmail,UserPassword) values('123@123.com','123456')"

local res ,err,errno,sqlstate= db:query(quote(sql))

if not res then
    ngx.say(cjson.encode({success = false,info=err}))
    return
end

ngx.say(cjson.encode({success=true,info="存入成功"}))

