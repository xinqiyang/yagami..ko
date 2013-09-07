--
-- goods moudle
--

module("goods",package.seeall)


local JSON = require("cjson")
local resty_uuid = require("resty.uuid")


-- do set goods reset 
-- set to hmset
function bootstrap(req,resp)
	req:read_body()
	local ok = 404
	local err = "System error"
	if req.method == 'POST' then 
		ok,err = post(req)
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


-- goods entity
-- field name,imgid,desc,price,tag
-- 
function post(req)
	local code = 200
	local id = resty_uuid:gen8();
	-- param check 


	-- req.uri_args['name']

	
	-- write to redis

	
	-- return result 

	return code,id
end


function get(req)

	-- get simple 

	-- get list 

	-- get 

	return 200,"GET OK"
end 




function put(req)





	return 200,"PUT OK"
end


function delete(req) 





	return 200,"DELETE OK"
end


