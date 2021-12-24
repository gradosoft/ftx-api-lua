local json = require("json")
local sha = require("sha2")
local util = require("util")
local cfg = require("config")

local api = {}

api.api_key = "Place-your-APIKEY-from-FTX-here"
api.api_secret = "Place-your-APISECRET-from-FTX-here"
api.tax_rate = 0.07
api.base_url = "https://ftx.com/api"


-- Symbol info. Fill global MARKETS. Return count of items
function api.get_markets()

    MARKETS = {} --clear all
    local item = {}
    local count = 0
    local link = api.base_url.."/markets"

    local code, res = util.get_url(link)
    if code ~= 200 then
        util.log("Func get_markets Error: ".. (code or ""))
        return 0
    end

    local data = json.decode(res)

    for _, v in pairs(data["result"]) do

        --For futures only uncomment condition
        if --[[v.type == "future" and --]] v.enabled == true and v.restricted == false then

            local name = v.name
            local base = v.underlying
            local sizeinc = v.sizeIncrement
            local priceinc = v.priceIncrement

            item = {base, sizeinc, priceinc}
            MARKETS[name] = item
            count = count + 1
        end
    end

    return count
end

-- Get("BTC-0924", "1h", 1621256100, 1621269900) Return[{unixtime(UTC in sec), open, high, low, close, volume}]
function api.get_history(market_name, timeframe, start_time, end_time)
    local result = {}
    local item = {}
    local resolution = api.get_resolution(timeframe)
    local link = api.base_url.."/markets/"..market_name.."/candles?resolution="..resolution.."&limit=1000&start_time="..start_time.."&end_time="..end_time

    local code, res = util.get_url(link)
    if code ~= 200 then
        util.log("Func get_history Error: ".. (code or ""))
        return 0
    end

    local data = json.decode(res)

    for _, v in pairs(data["result"]) do
        item = {math.floor(v.time/1000), v.open, v.high, v.low, v.close, v.volume}
        table.insert(result, item)
    end

    return result
end

-- Convert timeframe to resolution 
function api.get_resolution(timeframe)
    
    local resolution = 0

    if timeframe == "1d" then
        resolution = 86400
    elseif timeframe == "4h" then
        resolution = 14400
    elseif timeframe == "1h" then
        resolution = 3600
    elseif timeframe == "15m" then
        resolution = 900
    elseif timeframe == "5m" then
        resolution = 300
    elseif timeframe == "1m" then
        resolution = 60
    elseif timeframe == "15s" then
        resolution = 15
    end

    return resolution
end


-- Price diffirens between price of two actives
-- Get("BTC-1231", "BTC-0924" price type(open, close, hight, low), "1d", 1621256100, 1621269900) 
-- Return table: [{futures1_futures2, date in string, price type, module of price difference, {unixtime(UTC in sec)}]
-- Return result as {["min"]=90.56, ["max"]=345,67, ["avg"]=215.52, ["range"]={table_diff}}
function api.price_diff(futures1, futures2, price_type, timeframe, start_time, end_time)
    local result = {}
    local tbl = {}
    local item = {}
    local name, date = ""
    local diff = 0.0

    local table1 = api.get_history(futures1, timeframe, start_time, end_time)
    local table2 = api.get_history(futures2, timeframe, start_time, end_time)

    for i = 1, #table1 do
        for j = 1, #table2 do
            if table1[i][1] == table2[j][1] then
                
                name = futures1.."_"..futures2
                date = util.ts2date(table1[i][1])
                if price_type == "open" then
                    diff = math.abs(table1[i][2] - table2[j][2]) --unsigned value
                elseif price_type == "high" then
                    diff = math.abs(table1[i][3] - table2[j][3])
                elseif price_type == "low" then
                    diff = math.abs(table1[i][4] - table2[j][4])
                elseif price_type == "close" then
                    diff = math.abs(table1[i][5] - table2[j][5])
                end

                item = {name, date, price_type, diff, table1[i][1]}
                table.insert(tbl, item)
            end
        end
    end

    --Calculate max, min ,avg
    local min = tbl[1][4]
    local max = 0.0
    local sum = 0.0

    for _,v in pairs(tbl) do
        if v[4] > max then
            max = v[4] 
        elseif v[4] < min then
            min = v[4]
        end
        sum = sum + v[4]
    end

    result["range"] = tbl
    result["avg"] = tonumber(string.format("%.2f", sum/#tbl))
    --Change border by 10%
    result["max"] = max -- - (max/100*10) 
    result["min"] = min -- + (min/100*10)

    return result
end


--For Excel graphics. Get("table_name", "1d", 1, 5, 4). Create csv file (date, value, sma5) 
function api.to_excel(datatable, timeframe, col_name, col_datetime, col_value)
    local datetime = ""
    local value = 0.0
    local file_name = datatable[1][col_name].."."..os.date('%m-%d', datatable[1][col_datetime]).."."..os.date('%m-%d', datatable[#datatable][col_datetime])..".csv"
    local sma_data = {}
    local sma_value = 0.0

    local file = io.open(file_name, "w") -- Opens a file in write mode
    file.write(file, "Date;Value;SMA", '\n')    -- Appends to the last line of the file

    for i = 1, #datatable do
        
        if timeframe == "1d" or timeframe == "1w" then
            datetime = os.date('%m-%d', datatable[i][col_datetime])
        elseif timeframe == "1h" or timeframe == "4h" then
            datetime = os.date('%d-%H:%M', datatable[i][col_datetime])
        elseif timeframe == "30m" or timeframe == "15m" or timeframe == "5m" or timeframe == "1m" then
            datetime = os.date('%H:%M', datatable[i][col_datetime])
        end

  
        --SMA period = 25
        for j=1, 10 do
            if datatable[i-j] == nil then
                sma_data[j] = nil
            else
                sma_data[j] = datatable[i-j][col_value]
            end
        end

        --Replace fisrt nil on first value
        sma_value = (util.sma(sma_data) or datatable[i][col_value])
    
        --Replace "." to "," 
        sma_value = string.gsub(sma_value, "%.", ",")
        value = string.gsub(datatable[i][col_value], "%.", ",")

        file.write(file, datetime..";"..value..";"..sma_value, '\n')    -- Appends to the last line of the file
        
    end

    file.close(file)

    print("File "..file_name.." write successfully\n")

end

function api.get_wallet()
    local link = api.base_url.."/wallet/balances"
    local method = "GET"
    local ts = os.time() * 1000 
    local payload = ts.."GET/api".."/wallet/balances"
    local sign = sha.hmac(sha.sha256, api.api_secret, payload)
    local headers = {["FTX-KEY"] = api.api_key, ["FTX-SIGN"] = sign, ["FTX-TS"] = ts}

    local code, res = util.get_url(link, method, headers)
    if code ~= 200 then
        util.log("Func get_wallet Error: ".. (code or ""))
        print(res)
        return 0
    end
    
    return json.decode(res) 
end

--("BTC-PERP", "buy/sell", "limit/market", "30500.55", "0.001")
function api.set_order(sym, side, type, price, size)
    local link = api.base_url.."/orders"
    local method = "POST"
    local ts = os.time() * 1000 
    --local body = [[{"market": "BTC-PERP", "side": "buy", "type": "limit", "price": 30500, "size": 0.001}]]
    local body = string.format('{"market": "%s", "side": "%s", "type": "%s", "price": %s, "size": %s}', sym, side, type, price, size)
    local payload = ts..'POST/api'..'/orders'..body
    local sign = sha.hmac(sha.sha256, api.api_secret, payload)
    local headers = {["FTX-KEY"] = api.api_key, ["FTX-SIGN"] = sign, ["FTX-TS"] = ts, ["Content-Type"] = "application/json", ["Content-Length"] = string.len(body)}

    local code, res = util.get_url(link, method, headers, body)
    if code ~= 200 then
        util.log("Func set_order Error: ".. (code or ""))
        print(res)
        return 0
    end
    
    return json.decode(res) 
end

--Get ("BTC-PERP") as optional parameter and return all open orders or open orders BTC-PERP only.
function api.open_order(sym)
    local link = ""
    local payload = ""
    local ts = os.time() * 1000 
    local method = "GET"

    if sym == nil or sym == "" then
        link = api.base_url.."/orders"
        payload = ts.."GET/api".."/orders"
    else
        link = api.base_url.."/orders?market="..sym
        payload = ts.."GET/api".."/orders?market="..sym
    end

    local sign = sha.hmac(sha.sha256, api.api_secret, payload)
    local headers = {["FTX-KEY"] = api.api_key, ["FTX-SIGN"] = sign, ["FTX-TS"] = ts}

    local code, res = util.get_url(link, method, headers)
    if code ~= 200 then
        util.log("Func open_orders Error: ".. (code or ""))
        print(res)
        return 0
    end
    
    return json.decode(res) 

end

--Get ("one/all/cond", [9596912]). "one" - cancel ONE open order by ID, "all" - cancel ALL orders, ID don't needed, "cond" - cancel open trigger order.
-- Return true/false
function api.cancel_order(type, id)
    local link = ""
    local payload = ""    
    local ts = os.time() * 1000 
    local method = "DELETE"

    if type == "one" then    
        link = api.base_url.."/orders/"..id
        payload = ts.."DELETE/api".."/orders/"..id
    elseif type == "all" then
        link = api.base_url.."/orders"
        payload = ts.."DELETE/api".."/orders"
    elseif type =="cond" then
        link = api.base_url.."/conditional_orders/"..id
        payload = ts.."DELETE/api".."/conditional_orders/"..id
    end
    
    local sign = sha.hmac(sha.sha256, api.api_secret, payload)
    local headers = {["FTX-KEY"] = api.api_key, ["FTX-SIGN"] = sign, ["FTX-TS"] = ts}

    local code, res = util.get_url(link, method, headers)
    if code ~= 200 then
        util.log("Function cancel_order Error: ".. (code or ""))
        print(res)
        return 0
    end
    
    return json.decode(res) 
end

--Get e.g. "BTC-0924", return last bid and ask price
function api.bidask_price(sym)
    local link = api.base_url.."/futures/"..sym

    local code, res = util.get_url(link)
    if code ~= 200 then
        util.log("Func bidask_price Error: ".. (code or ""))
        return 0
    end

    local data = json.decode(res)
    local bid = data["result"]["bid"]
    local ask = data["result"]["ask"]

    return bid, ask
end

return api
