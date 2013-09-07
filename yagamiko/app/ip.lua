#!/usr/bin/env lua

module("ip", package.seeall)

local JSON = require("cjson")
--local Redis = require("resty.redis")

--local qqwry = require("qqwry")
local util = require("yagami.util")

local  q = require("ipquery")

-- init the class 
function bootstrap(req,resp)
	req:read_body()
	local ok = 500
	local err = "System error"
	if req.method == 'GET' then
		ok,err = get(req)
	else
		
	end
	ngx.status = ok
	resp.headers['Content-Type'] = 'application/json'
	resp:writeln(JSON.encode(err))
end


-- get new ip
-- lua programming rule  
function get(req)
	-- load once 
	local code = 404
	local ret = ""
	local ip = req.uri_args['ip']
	if ip ==nil or util.isNotEmptyString(ip) == false then 
		code = 400
	else 
		local path = util.get_config("ip")
		q.load_data_file(path.ip)
		local info = q.get_ip_info(ip)
		code = 200
		ret = info
	end
	return code,ret
end
