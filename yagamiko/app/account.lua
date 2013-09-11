--
-- account moudle
--

module("account",package.seeall)

local util = require("yagami.util")
local JSON = require("cjson")

function signup(req,resp)
	local args,header,bodydata = util.init_args()
	
	--ngx.log(ngx.DEBUG,util.table_print(args))
	--ngx.log(ngx.DEBUG,util.table_print(header))
	--ngx.log(ngx.DEBUG,bodydata)
	
	--local filebody = util.explode(bodydata,"\r\n\r\n")
	--ngx.log(ngx.DEBUG,util.table_print(bodydata))
	
	for key,value in pairs(bodydata) do 
		 local rowfile = util.explode(value,"\r\n\r\n")
		 --ngx.log(ngx.DEBUG,util.table_print(rowfile))
		 local file = io.open(rowfile[1], "w")
		 file:write(rowfile[2])
		 --ngx.log(ngx.DEBUG,rowfile[2])
		 file:close()
	end
	--[[
	if util.isNotNull(filebody[1]) then 
		ngx.log(ngx.DEBUG,"filename:"..util.quotv(filebody[1]))
	end
	if util.isNotNull(filebody[2]) then 
		ngx.log(ngx.DEBUG,"filebody:"..filebody[2])
	end
	--]]
	local email = args['email']
	ngx.log(ngx.DEBUG,email)
	
	ngx.status = ngx.HTTP_OK

	resp.headers['Content-Type'] = 'application/json'
    resp:writeln(JSON.encode(args))
end




