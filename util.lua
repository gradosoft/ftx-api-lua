local https = require("ssl.https")
local ltn12 = require("ltn12")
local cfg = require("config")
local socket = require("socket")

local util = {}

-- Get (URL, [method], [headers], [body]). Parameters "method", "headers", "body" are optional 
-- Return HTTP code, result
function util.get_url(link, method, headers, body)

	local headers = headers or {["Connection"] = "close"} --default value
	local method = method or "GET" --default value
	local body = body or ""

	https.TIMEOUT= 10

	local resp = {}
	local body, code, headers = https.request{
                url = link,
                method = method,
                headers = headers,
                source = ltn12.source.string(body),
				sink = ltn12.sink.table(resp)
				}

	return code, table.concat(resp)
end


-- Get table e.g. {year=2020, month=12, day=1, hour=0, min=0, sec=0}, return int timestamp in seconds
function util.date2ts(dt)
	--return (os.time(dt) * 1000) --milliseconds
	return (os.time(dt)) --seconds

end

-- Get int timestamp in seconds, return 2013-12-25 22:09:51
function util.ts2date(ts)
	--return(os.date('%Y-%m-%d %H:%M:%S', ts//1000)) --milliseconds
	return(os.date('%Y-%m-%d %H:%M:%S', ts))
end

-- Write message to a log file and concole
function util.log(message)
	local file = io.open(cfg.logfile, "a") -- Opens a file in append mode
	file.write(file, os.date('%d %b %H:%M:%S') .. " " ..tostring(message), '\n')	-- Appends to the last line of the file
	file.close(file)
	print(message)
end

--Read table orders from txt file and return table of open orders
function util.read_txt()
	local file = io.open(cfg.ordersfile, "r")
	local result = json.decode(file.read(file, "*a"))
	file.close(file)

	return result
end

--Save table of deals from MYORDERS to file
function util.write_txt(payload)
	local file = assert(io.open(cfg.ordersfile, "w"))
	file.write(file, json.encode(payload))
	file.close(file)
end


--Stop script on n seconds. Require luasocket. Break double Ctrl-C. Don't use CPU.
function util.sleep(sec)
    socket.sleep(sec)
end

--Get data value and return simple mooving average
--Period = number of data elements 
function util.sma(datatable)
	local sum = 0.0

	for _,v in pairs(datatable) do	
		sum = (sum + v or 0)
	end

	return tonumber(string.format("%.2f", sum/#datatable))

end

return util
