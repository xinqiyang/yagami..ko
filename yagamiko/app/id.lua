#!/usr/bin/env lua

module("id",package.seeall)

local resty_uuid = require("resty.uuid")

-- do set goods reset
-- set to hmset
function bootstrap(req,resp)
	req:read_body()
	local ok = 500
	local err = "System error"
	if req.method == 'GET' then
		ok,err = get(req)
	else
		
	end
	ngx.status = ok
	resp.headers['Content-Type'] = 'text/plain'
	resp:writeln(err)
end


-- if params is l and l = 20 then return 20
function get(req)
	local id = ""
	--for debug 
	--id = getmysqlid()
	if req.uri_args['l'] then
		id = resty_uuid:gen20()
	else
		id = resty_uuid:gen8()
	end
	return 200,id
end

-- TODO　add mysql return primary key
-- local mysql auto generate id for business system
-- generate then return the id of the table  
function getmysqlid()
	local Mysql = require("yagami.mysql")
	local m = Mysql:mysql_master()
	local time = ngx.time()
	-- return the id of the table 
	local sql = "insert into id (create_at) values(\""..time.."\")"
	local res,err,errno,sqlstate = m:query(sql)
	if not res then 
		ngx.log(ngx.ERR,"generate id error")
	end
	return res
end

