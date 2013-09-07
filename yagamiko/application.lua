--
-- application configuration
--
-- var in this file can be got by "yagami.util.get_config(key)"
--

debug={
    on=false,
    to="response", -- "ngx.log"
}

-- system version
version={
    name = "freeflare",
    logo = "./images/logo.png",
    icon = "./images/icon.png",
    url = "http://www.freeflare.com",
	version="1.0.0",
	iphone="1.0.1",
	android="1.0.2",
	web="1.0.1",	
	mis="1.0.0",
}

mysql_set01 = {
	master= "127.0.0.1",
	masterport= 3306,
    database="luatest",
    username="luatest",
    password="sdTndfQfMa99Qa8L",
	slave="127.0.0.1:3306 127.0.0.1:3306",
	timeout=1000,
	max_packet_size = 1024*1024
}

-- redis cluster  
redis_set01 = {
	master= "127.0.0.1",
	masterport=6379,
	slave="127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379",
	timeout=3000,
}

redis_set02 = {
	master= "127.0.0.1",
	masterport="6379",
	slave="127.0.0.1:6380 slave02:6381 slave03:6383",
	timeout="3000",
}

-------------------

redis_stat = {
	master= "127.0.0.1",
	masterport="3306",
	slave="127.0.0.1:6380",
}


logger = {
    file = "nginx_runtime/logs/yagamiko.log",
    level = "DEBUG",
}

config={
    templates="templates",
    
}

-- ipconnection select
-- TODO need to change 
ip = {
	ip="/freeflare/trunk/foundation/server/lua/yagamiko/conf/ip/qqwry.dat",	
}


weedfs = {
	master = "http://127.0.0.1:9333/dir/assign",
	volume = "http://127.0.0.1:9331/",
	tmplocal = "/tmp/fscache/freeflare/upload/",
}


subapps={
    -- subapp_name = {path="/path/to/another/yagamiapp", config={}},
}


