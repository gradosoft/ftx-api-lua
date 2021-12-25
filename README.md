# Lua example code for FTX API

Don't forget to get API KEY from https://ftx.com and add values to api.lua module (api.api_key and api.api_secret)</br>

Module sha2.lua - is original source code by Egor Skriptunoff</br>
Source Code : https://github.com/Egor-Skriptunoff/pure_lua_SHA</br>
MIT License

## Installation
Requirements **lua, lua-socket, lua-sec, lua-json**

OpenSuse:
```
sudo zypper install lua53-luarocks
sudo zypper install gcc
sudo zypper install lua53-devel
sudo luarocks install luajson
```

Windows 10: Install WSL. Then install Ubuntu 20.04.</br>
```
sudo apt install lua5.3 liblua5.3-0 liblua5.3-dev
sudo apt install luarocks
sudo apt install libssl-dev 
luarocks install --local luajson
luarocks install --local luasec
echo 'eval $(luarocks path --bin)' >> ~/.bashrc
```

MacOS: Go to https://brew.sh, then install brew.</br>
```
brew install lua luarocks
luarocks install --local luajson
brew install openssl
luarocks install luasec CRYPTO_INCDIR=/usr/local/opt/openssl/include/ OPENSSL+DIR=/usr/local/opt/openssl/ --local
echo 'eval $(luarocks path --bin)' >> ~/.zshrc
```


## Descritpion

api.lua contains functions for cryptocurrency exchange [FTX](https://ftx.com)</br>
main.lua contains example code for FTX API.</br>

Function **api.get_markets()** get symbol info. Fill global MARKETS. Return count of items.</br>
Description on https://docs.ftx.com/#get-markets
```lua
local api = require("api")
MARKETS = {}
local count = api.get_markets()
print(json.encode(MARKETS))
print(count)
```

Function **api.get_history()** Get e.g.('BTC-PERP', '1h', 1621256100, 1621269900)</br>
Return [{unixtime(UTC in sec), open, high, low, close, volume}]</br>
Description on https://docs.ftx.com/#get-historical-prices
```lua
local api = require("api")
local end_time = os.time() -- Current Time
local start_time = end_time - 86400 -- 1d
local history = api.get_history("BTC-PERP", "1h", start_time, end_time)
print(json.encode(history))
```

Function **api.get_wallet()** return wallet balances.</br>
Description on https://docs.ftx.com/#wallet</br>
Requires authentication.
```lua
local api = require("api")
local wallet = api.get_wallet()
print(json.encode(wallet))
```

Function **api.set_order(...)** set buy/sell order.</br>
Description on https://docs.ftx.com/#place-order</br>
Requires authentication.
```lua
local api = require("api")
local order = api.set_order("BTC-PERP", "buy", "limit", 30555.21, 0.001)
print(json.encode(order))
```

Function **api.open_order(...)** get all open orders by active.</br>
Get e.g. 'BTC-PERP' as optional parameter and return all open orders or open orders BTC-PERP only.</br>
Description on https://docs.ftx.com/#get-open-orders</br>
Requires authentication.
```lua
local api = require("api")
local open = api.open_order("BTC-PERP")
print(json.encode(open))
```

Function **api.cancel_order(...)** cancel open orders by ID</br>
Function set_order return order ID</br>
Description on https://docs.ftx.com/#cancel-order</br>
Requires authentication.
```lua
local api = require("api")
local cancel = api.open_order("Place-number-of-ID-here")
print(json.encode(cancel))
```
