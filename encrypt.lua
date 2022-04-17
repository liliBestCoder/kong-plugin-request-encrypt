local bit = require "bit"
local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function(arr_n, rec_n) return {} end
end

local _M = {}

-- rc4 symmetric encryption algorithm implementation,
--
-- @string key The key used for symmetric encryption
-- @string data Data that requires symmetric encryption
-- @return string Symmetric encrypted data
local function rc4(key, data)
    local key_len, schedule, data_len, switch_index = key:len(), new_tab(256, 0), data:len(), 0
    local key_bytes, secret_stream, first, second = new_tab(key_len, 0), new_tab(data_len, 0), 0, 0
    for i = 0, 255 do schedule[i] = i end
    for i = 1, key_len do key_bytes[i - 1] = key:byte(i, i) end
    for i = 0, 255 do
        switch_index = (switch_index + schedule[i] + key_bytes[i % key_len]) % 256
        schedule[i], schedule[switch_index] = schedule[switch_index], schedule[i]
    end

    for n = 1, data_len do
        first = (first + 1) % 256
        second = (second + schedule[first]) % 256
        schedule[first], schedule[second] = schedule[second], schedule[first]
        secret_stream[n] = schedule[(schedule[first] + schedule[second]) % 256]
    end

    local cipher = new_tab(data_len, 0)
    for i = 1, data_len do cipher[i] = string.char(bit.bxor(secret_stream[i], data:byte(i, i))) end

    return table.concat(cipher)
end

_M.encrypt = rc4
_M.decrypt = rc4

return _M