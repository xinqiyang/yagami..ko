#!/usr/bin/env lua

--
-- brand moudle
--

module("user",package.seeall)

local JSON = require("cjson")
local Mysql = require("yagami.mysql")


-- do set goods reset
-- set to hmset
function bootstrap(req,resp)
    req:read_body()
	local ok = 500
	local err
	if req.method == 'POST' then
		ok,err = post(req)
		--err = req.post_args
	elseif req.method == 'GET' then
		ok,err = get(req)
	elseif req.method == 'PUT'  then
		ok,err = put(req)
	elseif req.method == 'DELETE' then
		ok,err = delete(req)
	end
	ngx.status = ok
	resp.headers['Content-Type'] = 'application/json'
	resp:writeln(JSON.encode(err))
end


function get(req)
	local code = 404
	local retErr = ""
	local id = ""
	if req.uri_args['id'] then 
		id = req.uri_args['id']
		-- get from redis , then get from mysql
		local m = Mysql:mysql_master()
		local sql = "select * from test where id=\'"..id.."\'"
		local res,err,errno,sqlstate = m:query(sql)
		if not res then
			--logger.e("insert into test error "..err)
			code = errno
			retErr = err
		else
			code = 200
			retErr = res
		end
	end
	return code,retErr
end

--create 
function post(req)
	local code = 503
	local retErr = ""
	local resty_uuid = require("resty.uuid")
	local id = resty_uuid:gen8()
	local name = ""
	if req.post_args['name'] then
		name = req.post_args['name']..id
	end
	local password = ""
	if req.post_args['password']  then
		password = req.post_args['password']
	end
	
	local m = Mysql:mysql_master()
	local res,err,errno,sqlstate = m:query("insert into test (id,name,password) values(\'"..id.."\',\'"..name.."\',\'"..password.."\')")
	if not res then
		code = errno
		retErr = err
	else
		code = 200
		--generate cache of the instance
	end
	return code,retErr
end

-- update user info 
function put(req)

   -- update user info of the site
   -- recieve the json then save it.
   


	return 200,"PUT OK"
end


function delete(req)
	-- delete user by id 
	local code = 404
	local retErr = ""
	local id = ""
	if req.uri_args['id'] then 
		id = req.uri_args['id']
		-- get from redis , then get from mysql
		local m = Mysql:mysql_master()
		local sql = "delete from test where id=\'"..id.."\'"
		local res,err,errno,sqlstate = m:query(sql)
		if not res then
			--logger.e("insert into test error "..err)
			code = errno
			retErr = err
		else
			code = 200
			retErr = res.affected_rows
		end
	end
	return code,retErr
end


