local json          = require("cjson")

local math_floor    = math.floor
local string_char   = string.char
local string_byte   = string.byte
local string_rep    = string.rep
local string_sub    = string.sub
local debug_getinfo = debug.getinfo

local vars = require("yagami.vars")
module('yagami.util', package.seeall)

function read_all(filename)
	local file = io.open(filename, "r")
	local data = ((file and file:read("*a")) or nil)
	if file then
		file:close()
	end
	return data
end


function setup_app_env(ygm_home, app_name, app_path, global)
	global['YAGAMI_HOME']=ygm_home
	global['YAGAMI_APP']=appname
	global['YAGAMI_APP_PATH']=app_path

	package.path = ygm_home .. '/lualibs/?.lua;' .. package.path
	package.path = app_path .. '/service/?.lua;' .. package.path
	package.path = app_path .. '/logic/?.lua;' .. package.path

	local request=require("yagami.request")
	local response=require("yagami.response")

	global['YAGAMI_MODULES']={}
	global['YAGAMI_MODULES']['request']=request
	global['YAGAMI_MODULES']['response']=response
end

--load var from lua file
function loadvars(file)
	local env = setmetatable({}, {__index=_G})
	assert(pcall(setfenv(assert(loadfile(file)), env)))
	setmetatable(env, nil)
	return env
end

--get configuration setting
function get_config(key, default)
	if key == nil then return nil end
	local issub, subname = is_subapp(3)

	if not issub then -- main app
		local ret = ngx.var[key]
		if ret then return ret end
		local app_conf=vars.get(ngx.ctx.YAGAMI_APP_NAME,"APP_CONFIG")
		return app_conf[key] or default
	end

	-- sub app
	if not subname then return default end
	local subapps=vars.get(ngx.ctx.YAGAMI_APP_NAME,"APP_CONFIG").subapps or {}
	local subconfig=subapps[subname].config or {}
	return subconfig[key] or default

end

function _strify(o, tab, act, logged)
	local v = tostring(o)
	if logged[o] then return v end
	if string_sub(v,0,6) == "table:" then
		logged[o] = true
		act = "\n" .. string_rep("|    ",tab) .. "{ [".. tostring(o) .. ", "
		act = act .. table_real_length(o) .." item(s)]"
		for k, v in pairs(o) do
			act = act .."\n" .. string_rep("|    ", tab)
			act = act .. "|   *".. k .. "\t=>\t" .. _strify(v, tab+1, act, logged)
		end
		act = act .. "\n" .. string_rep("|    ",tab) .. "}"
		return act
	else
		return v
	end
end

function strify(o) return _strify(o, 1, "", {}) end

function table_print(t)
	local s1="\n* Table String:"
	local s2="\n* End Table"
	return s1 .. strify(t) .. s2
end

function table_real_length(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function is_subapp(__call_frame_level)
	if not __call_frame_level then __call_frame_level = 2 end
	local caller = debug_getinfo(__call_frame_level,'S').source
	local main_app = ngx.var.YAGAMI_APP_PATH

	local is_mainapp = (main_app == (string_sub(caller, 2, #main_app+1)))
	if is_mainapp then return false, nil end -- main app

	local subapps = vars.get(ngx.ctx.YAGAMI_APP_NAME, "APP_CONFIG").subapps or {}
	for k, v in pairs(subapps) do
		local spath = v.path
		local is_this_subapp = (spath == (string_sub(caller, 2, #spath+1)))
		if is_this_subapp then return true, k end -- sub app
	end

	return false, nil -- not main/sub app, maybe call in yagami!
end

function parseNetInt(bytes)
	local a, b, c, d = string_byte(bytes, 1, 4)
	return a * 256 ^ 3 + b * 256 ^ 2 + c * 256 + d
end

function toNetInt(n)
	-- NOTE: for little endian machine only!!!
	local d = n % 256
	n = math_floor(n / 256)
	local c = n % 256
	n = math_floor(n / 256)
	local b = n % 256
	n = math_floor(n / 256)
	local a = n
	return string_char(a) .. string_char(b) .. string_char(c) .. string_char(d)
end

function write_jsonresponse(sock, s)
	if type(s) == 'table' then
		s = json.encode(s)
	end
	local l = toNetInt(#s)
	sock:send(l .. s)
end

function read_jsonresponse(sock)
	local r, err = sock:receive(4)
	if not r then
		ngx.log(ngx.ERR,'Error when receiving from socket: %s', err)
		return
	end
	local len = parseNetInt(r)
	data, err = sock:receive(len)
	if not data then
		ngx.log(ngx.ERR,'Error when receiving from socket: %s', err)
		return
	end
	return json.decode(data)
end


--------------------------------
function map(func, t)
	local new_t = {}
	for i,v in ipairs(t) do
		table_insert(new_t, func(v, i))
	end
	return new_t
end

function timestamp()
	return ngx.time()
end

function isNull(v)
	return (v==nil or v==ngx.null)
end

function isNotNull(v)
	return not isNull(v)
end

function isNotEmptyString(...)
	local args = {...}
	local v = nil
	for i=1,table.maxn(args) do
		v = args[i]
		if v==nil or v==ngx.null or type(v)~='string' or string.len(v)==0 then
			return false
		end
	end
	return true
end

--explode then random return one
function splitString(inputstr,sep)
	if sep == nil then
		sep = "%s"
	end

	t = {}; i=1
	for str in string.gmatch(inputstr,"([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


function splitSlave(inputstr,sep)
	if sep == nil then
		sep = "%s"
	end

	t = {}; r ={}; i=1
	for str in string.gmatch(inputstr,"([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	local one = 1

	if i>1 then
		math.randomseed(os.time())
		one = math.random(1,i-1)
	end

	z=1
	for str in string.gmatch(t[one],"([^:]+)") do
		r[z] = str
		z = z+1
	end
	return r[1],r[2]
end



-- traceback function , log debug
function traceback()
	ngx.log(ngx.ERR,require("debug").traceback())
end

function table_print(t)
	local s1="\n* Table String:"
	local s2="\n* End Table"
	ngx.log(ngx.DEBUG,s1 .. strify(t) .. s2)
end


-- add by xinqiyang

--urlencode
function urlencode(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end

--urldecode
function urldecode(str)
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)",
	function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end


function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

-- Table

function table_index(t, value)
	if type(t) ~= 'table' then return nil end
	for i,v in ipairs(t) do
		if v==value then
			return i
		end
	end

	return nil
end

function table_sub(t, s, e)
	local t_count = #t

	if s<0 then
		s = t_count + s + 1
	end

	if e<0 then
		e = t_count + e + 1
	end

	if s<=0 or s>t_count or e<=0 then
		return nil
	end

	e = math_min(t_count, e)

	local new_t = {}
	for i=s,e,1 do
		table_insert(new_t, t[i])
	end

	return new_t
end

function table_extend(t, t1)
	for _,v in ipairs(t1) do
		table_insert(t, v)
	end
	return t
end

function table_merge(t1, t2)
	local new_t = {}
	for i,v in ipairs(t1) do
		table_insert(new_t, v)
	end
	for i,v in ipairs(t2) do
		table_insert(new_t, v)
	end
	return new_t
end

function table_update(t1, t2)
	for k,v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

function table_rm_value(t, value)
	local idx = table_index(t, value)
	if idx then
		table_remove(t, idx)
	end
	return idx
end

function table_contains_value(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function table_contains_key(t, element)
	return t[element]~=nil
end

function table_count(t, value)
	local count = 0
	for _,v in ipairs(t) do
		if v==value then
			count = count + 1
		end
	end
	return count
end

function table_real_length(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count
end

function table_empty(t)
	if not t then return true end
	if type(t)=='table' and #t<=0 then return true end
	return false
end

function table_unique(t)
	local n_t1 = {}
	local n_t2 = {}
	for k,v in ipairs(t) do
		if n_t1[v] == nil then
			n_t1[v] = v
			table.insert(n_t2, v)
		end
	end
	return n_t2
end

function table_excepted(t1, t2)
	local ret = {}
	for _,v1 in ipairs(t1) do
		local finded = false
		for _,v2 in ipairs(t2) do
			if type(v2) == type(v1) and v1==v2 then
				finded = true
				break
			end
		end
		if not finded then
			table.insert(ret,v1)
		end
	end
	return ret
end


-- String

function trim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

function string_index(str, substr)
	local order_by_index = string_find(str, substr, 1, true)
	return order_by_index
end

function string_rindex(str, substr)
	return string_match(str, '.*()'..substr)
end

function string_startswith(str, substr)
	return string_index(str, substr)==1
end

function string_endswith(str, substr)
	return string_rindex(str, substr)==(string_len(str)-string_len(substr)+1)
end

function dirpath(str)
	local last_slash_index = string_rindex(str, "/")
	if last_slash_index then
		return string_sub(str, 1, last_slash_index-1)
	end
	return nil
end



-- Int

function int(value, default)
	local int_value = default

	local value_type = type(value)
	if value_type=='number' then
		int_value = value
	elseif value_type=='string' then
		int_value = tonumber(value)
		if not int_value then int_value = default end
	end

	return int_value
end

function basen(n, b)
	if not b or b==10 then
		return tostring(n)
	end

	if b<=1 then return nil end

	local digits = "0123456789abcdefghijklmnopqrstuvwxyz"

	local t = {}

	local sign = nil
	if n < 0 then
		sign = "-"
		n = -n
	end

	n = math_floor(n)
	repeat
		local d = (n % b) + 1
		n = math_floor(n / b)
		table_insert(t, 1, digits:sub(d,d))
	until n == 0

	if sign then
		return sign .. table_concat(t)
	end

	return table_concat(t)
end

function base10to36(i)
	if type(i)=='string' then i=tonumber(i) end
	-- if type(i)~='number' then return nil end
	return basen(i, 36)
end

function base36to10(s)
	return tonumber(s, 36)
end


function get_one_uri_arg(arg)
	if type(arg)=='table' then
		if #arg>=1 then
			arg = arg[1]
		else
			arg = ''
		end
	end

	if type(arg)~='string' then arg='' end

	return arg
end

-- get quoatation mask string value 
function quotv(_str)
	return string.gsub(string.match(_str,'(".-")'),'"','')
end

function explode ( _str,seperator )
	local pos, arr = 0, {}
	for st, sp in function() return string.find( _str, seperator, pos, true ) end do
		table.insert( arr, string.sub( _str, pos, st-1 ) )
		pos = sp + 1
	end
	table.insert( arr, string.sub( _str, pos ) )
	return arr
end

--
-- get init args 
-- thank you for author of method
-- http://blog.csdn.net/cfeibiao/article/details/8315302
-- get filebody from request then explite filed name and file body
--[[
for key,value in pairs(bodydata) do 
		 local rowfile = util.explode(value,"\r\n\r\n")
		 local file = io.open(rowfile[1], "w")
		 file:write(rowfile[2])
		 file:close()
end
--]]	
function init_args()
	local args = {}
	local file_body = {}
	local receive_headers = ngx.req.get_headers()
	local request_method = ngx.var.request_method
	--ngx.log(ngx.DEBUG,"XXXXXXXXXXXXXXXXX method:"..request_method)
	if "GET" == request_method then
		args = ngx.req.get_uri_args()
	elseif "POST" == request_method then
		ngx.req.read_body()
		if string.sub(receive_headers["content-type"],1,20) == "multipart/form-data;" then-- if is multipart/form-data form
			content_type = receive_headers["content-type"]
			body_data = ngx.req.get_body_data()--body_data request body not string
			-- request body size > nginx config is client_body_buffer_size， buffer content to disk，client_body_buffer_size default is 8k or 16k
			if not body_data then
				local datafile = ngx.req.get_body_file()
				if not datafile then
					error_code = 1
					error_msg = "no request body found"
				else
					local fh, err = io.open(datafile, "r")
					if not fh then
						error_code = 2
						error_msg = "failed to open " .. tostring(datafile) .. "for reading: " .. tostring(err)
					else
						fh:seek("set")
						body_data = fh:read("*a")
						fh:close()
						if body_data == "" then
							error_code = 3
							error_msg = "request body is empty"
						end
					end
				end
			end
			-- get body content
			if not error_code then
				local boundary = "--" .. string.sub(receive_headers["content-type"],31)
				local body_data_table = explode(tostring(body_data),boundary)
				local first_string = table.remove(body_data_table,1)
				local last_string = table.remove(body_data_table)
				for i,v in ipairs(body_data_table) do
					local start_pos,end_pos,capture,capture2 = string.find(v,'Content%-Disposition: form%-data; name="(.+)"; filename="(.*)"')
					if not start_pos then  --common param
						local t = explode(v,"\r\n\r\n")
						
						local temp_param_name = string.match(t[1],'(".-")')
						temp_param_name = string.gsub(temp_param_name,'"','')
						
						local temp_param_value = string.sub(t[2],1,-3)
						args[temp_param_name] = temp_param_value
					else
						local bd = explode(v,"\r\n\r\n")
						table.insert(file_body,capture.."\r\n\r\n"..string.sub(bd[2],0,-3))
					end
				end
			end
		else
			args = ngx.req.get_post_args()
		end
	elseif "HEAD" == request_method then
		ngx.log(ngx.DEBUG,"*****get head method start**********")
		ngx.log(ngx.DEBUG,table_print(ngx.var))
		ngx.log(ngx.DEBUG,ngx.var.CONTENT_LENGTH) --content_length
		ngx.log(ngx.DEBUG,"*****get head method**********")
	end
	-- TODO　remove other keys , example : app_key,app_secret
	-- print request code 
	local uri         = ngx.var.REQUEST_URI
    ngx.log(ngx.DEBUG,"\n************** "..request_method.." "..uri.."   ***********")
	ngx.log(ngx.DEBUG,table_print(args))
	ngx.log(ngx.DEBUG,table_print(receive_headers))
	ngx.log(ngx.DEBUG,table_print(file_body))
	return args,receive_headers,file_body
end


--
-- get init args 
-- thank you for author of method
-- http://blog.csdn.net/cfeibiao/article/details/8315302
--
function init_args_simple()
	local args = {}
	local receive_headers = ngx.req.get_headers()
	local request_method = ngx.var.request_method
	--ngx.log(ngx.DEBUG,"XXXXXXXXXXXXXXXXX method:"..request_method)
	if "GET" == request_method then
		args = ngx.req.get_uri_args()
	elseif "POST" == request_method then
		ngx.req.read_body()
		if string.sub(receive_headers["content-type"],1,20) == "multipart/form-data;" then
			content_type = receive_headers["content-type"]
			body_data = ngx.req.get_body_data()--body_data request body not string
			
			if not body_data then
				local datafile = ngx.req.get_body_file()
				if not datafile then
					error_code = 1
					error_msg = "no request body found"
				else
					local fh, err = io.open(datafile, "r")
					if not fh then
						error_code = 2
						error_msg = "failed to open " .. tostring(datafile) .. "for reading: " .. tostring(err)
					else
						fh:seek("set")
						body_data = fh:read("*a")
						fh:close()
						if body_data == "" then
							error_code = 3
							error_msg = "request body is empty"
						end
					end
				end
			end
			if not error_code then
				local boundary = "--" .. string.sub(receive_headers["content-type"],31)
				local body_data_table = explode(tostring(body_data),boundary)
				local first_string = table.remove(body_data_table,1)
				local last_string = table.remove(body_data_table)
				for i,v in ipairs(body_data_table) do
					local start_pos,end_pos,capture,capture2 = string.find(v,'Content%-Disposition: form%-data; name="(.+)"; filename="(.*)"')
					if not start_pos then  --common param
						local t = explode(v,"\r\n\r\n")
						local temp_param_name = string.match(t[1],'(".-")')
						temp_param_name = string.gsub(temp_param_name,'"','')
						local temp_param_value = string.sub(t[2],1,-3)
						args[temp_param_name] = temp_param_value
					end
				end
			end
		else
			args = ngx.req.get_post_args()
		end
	elseif "HEAD" == request_method then
		ngx.log(ngx.DEBUG,"*****get head method start**********")
		ngx.log(ngx.DEBUG,table_print(ngx.var))
		ngx.log(ngx.DEBUG,ngx.var.CONTENT_LENGTH) --content_length
		ngx.log(ngx.DEBUG,"*****get head method**********")
	end

	local uri         = ngx.var.REQUEST_URI
    ngx.log(ngx.DEBUG,"\n************** "..request_method.." "..uri.."   ***********")
	ngx.log(ngx.DEBUG,table_print(args))
	ngx.log(ngx.DEBUG,table_print(receive_headers))
	return args,receive_headers
end

-- get args json
-- support args of get/post by json
function init_args_json()
	local receive_headers = ngx.req.get_headers()
	if "POST" == request_method then
		ngx.req.read_body()
	end
	local body = ngx.req.get_body_data()
	return receive_headers,body
end

--
-- get init args 
-- thank you for author of method
-- http://blog.csdn.net/cfeibiao/article/details/8315302
--
function init_args_request()
	local args = {}
	local receive_headers = ngx.req.get_headers()
	local request_method = ngx.var.request_method
	
	if "GET" == request_method then
		args = ngx.req.get_uri_args()
	elseif "POST" == request_method then
		ngx.req.read_body()
		if string.sub(receive_headers["content-type"],1,20) == "multipart/form-data;" then-- if is multipart/form-data form
			content_type = receive_headers["content-type"]
			body_data = ngx.req.get_body_data()--body_data request body not string
			-- request body size > nginx config is client_body_buffer_size， buffer content to disk，client_body_buffer_size default is 8k or 16k
			if not body_data then
				local datafile = ngx.req.get_body_file()
				if not datafile then
					error_code = 1
					error_msg = "no request body found"
				else
					local fh, err = io.open(datafile, "r")
					if not fh then
						error_code = 2
						error_msg = "failed to open " .. tostring(datafile) .. "for reading: " .. tostring(err)
					else
						fh:seek("set")
						body_data = fh:read("*a")
						fh:close()
						if body_data == "" then
							error_code = 3
							error_msg = "request body is empty"
						end
					end
				end
			end
			local new_body_data = {}
			-- get body content
			if not error_code then
				local boundary = "--" .. string.sub(receive_headers["content-type"],31)
				local body_data_table = explode(tostring(body_data),boundary)
				local first_string = table.remove(body_data_table,1)
				local last_string = table.remove(body_data_table)
				for i,v in ipairs(body_data_table) do
					local start_pos,end_pos,capture,capture2 = string.find(v,'Content%-Disposition: form%-data; name="(.+)"; filename="(.*)"')
					if not start_pos then  --common param
						local t = explode(v,"\r\n\r\n")
						local temp_param_name = string.match(t[1],'(".-")')
						temp_param_name = string.gsub(temp_param_name,'"','')
						local temp_param_value = string.sub(t[2],1,-3)
						args[temp_param_name] = temp_param_value
					else
						table.insert(new_body_data,v)
					end
				end
				table.insert(new_body_data,1,first_string)
				table.insert(new_body_data,last_string)
				body_data = new_body_data
				body_data = table.concat(new_body_data,boundary)--body_data  is http request body ,not a common string
			end
		else
			args = ngx.req.get_post_args()
		end
	elseif "HEAD" == request_method then
		ngx.log(ngx.DEBUG,"*****get head method start**********")
		ngx.log(ngx.DEBUG,table_print(ngx.var))
		ngx.log(ngx.DEBUG,ngx.var.CONTENT_LENGTH) --content_length
		ngx.log(ngx.DEBUG,"*****get head method**********")
	end
	-- TODO　remove other keys , example : app_key,app_secret
	-- print request code 
	local uri         = ngx.var.REQUEST_URI
    ngx.log(ngx.DEBUG,"\n************** "..request_method.." "..uri.."   ***********")
	ngx.log(ngx.DEBUG,table_print(args))
	ngx.log(ngx.DEBUG,table_print(receive_headers))
	ngx.log(ngx.DEBUG,table_print(body_data))	
	return args,receive_headers,body_data
end

--validate the 
function validate(str,rule)
	
	return false;
end






