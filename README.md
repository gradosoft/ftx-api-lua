## Lua example code for FTX API

Don't forget get API KEY from https://ftx.com and write to api.lua module(api.api_key and api.api_secret)

Module sha2.lua - is original source code by Egor Skriptunoff
Source Code : https://github.com/Egor-Skriptunoff/pure_lua_SHA
MIT License

#Installation
Requirements lua, lua-socket, lua-sec, lua-json

OpenSuse:
```
sudo zypper install lua53-luarocks
sudo zypper install gcc
sudo zypper install lua53-devel
sudo luarocks install luajson
```

Windows 10. 
Install WSL
Install Ubuntu 20.04
```
sudo apt install lua5.3 liblua5.3-0 liblua5.3-dev
sudo apt install luarocks
sudo apt install libssl-dev 
luarocks install --local luajson
luarocks install --local luasec
echo 'eval $(luarocks path --bin)' >> ~/.bashrc
```

MacOS
Go to https://brew.sh
Install brew
```
brew install lua luarocks
luarocks install --local luajson
brew install openssl
luarocks install luasec CRYPTO_INCDIR=/usr/local/opt/openssl/include/ OPENSSL+DIR=/usr/local/opt/openssl/ --local
echo 'eval $(luarocks path --bin)' >> ~/.zshrc
```


#Descritpion

api.lua contains functions for cryptocurrency exchange FTX [https://ftx.com]
main.lua contains example code for FTX API.

Function api.get_markets() get symbol info. Fill global MARKETS. Return count of items.
Description on https://docs.ftx.com/#get-markets
```
MARKETS = {}
local count = api.get_markets()
print(json.encode(MARKETS))
print(count)
```

Function api.get_history Get e.g.('BTC-PERP', '1h', 1621256100, 1621269900)
Return [{unixtime(UTC in sec), open, high, low, close, volume}]
Description on https://docs.ftx.com/#get-historical-prices
```
local end_time = os.time() -- Current Time
local start_time = end_time - 86400 -- 1d
local history = api.get_history("BTC-PERP", "1h", start_time, end_time)
print(json.encode(history))
```

Function api.get_wallet return wallet balances.
Description on https://docs.ftx.com/#wallet
Requires authentication.
```
local wallet = api.get_wallet()
print(json.encode(wallet))
```

Function api.set_order set buy/sell order.
Description on https://docs.ftx.com/#place-order
Requires authentication.
```
local order = api.set_order("BTC-PERP", "buy", "limit", 30555.21, 0.001)
print(json.encode(order))
```

Function api.open_order get all open orders by active.
Get e.g. 'BTC-PERP' as optional parameter and return all open orders or open orders BTC-PERP only.
Description on https://docs.ftx.com/#get-open-orders
Requires authentication.
```
local open = api.open_order("BTC-PERP")
print(json.encode(open))
```

Function api.cancel_order cancel open orders by ID
Function set_order return order ID
Description on https://docs.ftx.com/#cancel-order
Requires authentication.
```
local cancel = api.open_order("Place-number-of-ID-here")
print(json.encode(cancel))
```
