--
-- account moudle
--

module("account",package.seeall)


local JSON = require("cjson")

function signup(req,resp)
	ngx.status = ngx.HTTP_OK
	local err = "signup ok"
	resp.headers['Content-Type'] = 'application/json'
    resp:writeln(JSON.encode(err))
end




