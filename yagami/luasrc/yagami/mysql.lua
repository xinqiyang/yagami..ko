module("yagami.mysql",package.seeall)

local util = require("yagami.util")
local mysql = require("resty.mysql")

--set default set of mysql

local defaultSet = "mysql_set01"
local mysql_pool_size = 100

-- mysql master
function mysql_master(set)
	local db,err = mysql:new()
	if not db then 
		--logger.e("mysql master can not new:"..err)
		return nil 
	end
	
	if set == nil or util.isNotEmptyString(set) == false then 
	    set = defaultSet
	end
	
	local t_set = util.get_config(set)
	db:set_timeout(t_set.timeout) -- 1 second
	
	local ok,err,errno,sqlstate = db:connect {
		host = t_set.master,
		port = tonumber(t_set.masterport),
		database = t_set.database,
		user = t_set.username,
		password = t_set.password,
		max_packet_size = t_set.max_packet_size
	}
	
	if not ok then 
		ngx.log(ngx.ERR,"failed to connect:"..err.." errno:"..errno.."  "..sqlstate)
		return nil
	end
	return db
end

--mysql slave 
function mysql_slave(set)
	local db,err = mysql:new()
	if not db then 
		ngx.log(ngx.ERR,"mysql master can not new:"..err)
		return nil 
	end
	
	if set == nil or util.isNotEmptyString(set) == false then 
	    set = defaultSet
	end
	
	local t_set = util.get_config(set)
	db:set_timeout(t_set.timeout) -- 1 second
	local slavehost,slaveport = util.splitSlave(t_set.slave)
	local ok,err,errno,sqlstate = db:connect {
		host = slavehost,
		port = tonumber(slaveport),
		database = t_set.database,
		user = t_set.username,
		password = t_set.password,
		max_packet_size = t_set.max_packet_size
	}
	
	if not ok then 
		ngx.log(ngx.ERR,"failed to connect:"..err.." errno:"..errno.."  "..sqlstate)
		return nil
	end
	
	return db
end
