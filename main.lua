local util = require("util")
local api = require("api")
local json = require("json")
local cfg = require("config")


-- [{Name Markets: {Base Active string, SizeIncrement float, PriceIncrement float}}]
MARKETS = {}

--Table by open orders
MYORDERS = {}

print("Hello! I'm FTX API example Bot!\n")


--local start_time = util.date2ts({year=2021, month=7, day=27, hour=03, min=00, sec=0})
--local end_time = util.date2ts({year=2021, month=7, day=26, hour=03, min=00, sec=0})
local end_time = os.time() --Current Time
local start_time = end_time - 86400 -- 14400 = 4h, 86400 = 1d

print("--------------------------------------")
print("function api.get_markets get symbol info. Fill global MARKETS. Return count of items")
print("Description on https://docs.ftx.com/#get-markets")
print("Press the Enter for continue or CTRL-C for Exit.")
io.read()

local count = api.get_markets()
print(json.encode(MARKETS))
print(count)

print("--------------------------------------")
print("function api.get_history Get e.g.('BTC-PERP', '1h', 1621256100, 1621269900)") 
print("Return [{unixtime(UTC in sec), open, high, low, close, volume}]")
print("Description on https://docs.ftx.com/#get-historical-prices")
print("Press the Enter for continue or CTRL-C for Exit.")
io.read()

local history = api.get_history("BTC-PERP", "1h", 1621256100, 1621269900)
print(json.encode(history))

print("--------------------------------------")
print("function api.get_wallet return wallet balances")
print("Description on https://docs.ftx.com/#wallet")
print("Requires authentication.")
if #api.api_key ~= 40 and #api.api_secret ~= 40 then
    print("Sorry, you should set the variables APIKEY and APISECRET from FTX...")     
    print("API for wallet doesn't work.")
    print("Press the Enter for continue or CTRL-C for Exit.")
    io.read()
else
    local wallet = api.get_wallet()
    print(json.encode(wallet))
end

print("--------------------------------------")
print("function api.set_order set buy/sell order")
print("Description on https://docs.ftx.com/#place-order")
print("Requires authentication.")
if #api.api_key ~= 40 and #api.api_secret ~= 40 then
    print("Sorry, you should set the variables APIKEY and APISECRET from FTX...")     
    print("API for set orders doesn't work.")
    print("Press the Enter for continue or CTRL-C for Exit.")
    io.read()
else
    local order = api.set_order("BTC-PERP", "buy", "limit", 30555.21, 0.0001)
    print(json.encode(order))
end

print("--------------------------------------")
print("function api.open_order get all open orders by active")
print("Get e.g. 'BTC-PERP' as optional parameter and return all open orders or open orders BTC-PERP only")
print("Description on https://docs.ftx.com/#get-open-orders")
print("Requires authentication.")
if #api.api_key ~= 40 and #api.api_secret ~= 40 then
    print("Sorry, you should set the variables APIKEY and APISECRET from FTX...")     
    print("API for open orders doesn't work.")
    print("Press the Enter for continue or CTRL-C for Exit.")
    io.read()
else
    local orders = api.open_order("BTC-PERP")
    print(json.encode(orders))
end

print("--------------------------------------")
print("function api.cancel_order cancel open orders by ID")
print("function set_order return order ID")
print("Description on https://docs.ftx.com/#cancel-order")
print("Requires authentication.")
if #api.api_key ~= 40 and #api.api_secret ~= 40 then
    print("Sorry, you should set the variables APIKEY and APISECRET from FTX...")     
    print("API for cancel orders doesn't work.")
    print("Press the Enter for continue or CTRL-C for Exit.")
    io.read()
else
    local cancel = api.open_order("Place-number-of-ID-here")
    print(json.encode(cancel))
end



--[[
MYORDERS = {
    [12345] = {"BTC-0924", "buy", 31555.00, 0.001},
    [67890] = {"BTC-1231", "sell", 31687.56, 0.001}
}
--]]

--util.write_txt(MYORDERS)

--[[
local tbl1 = util.read_txt()

for k,v in pairs(tbl1) do
    print(k, json.encode(v))
end
--]]



