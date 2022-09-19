local openssl_pkey = require "resty.openssl.pkey"
local gsub = string.gsub

local _M = { _VERSION = '1.0' }

--公钥加密
function _M.public_encrypt(msg, publicKey)
    local key = gsub(publicKey, "\\n", "\n")
    local pub = openssl_pkey.new(key)

    local chunkSize = 2048 / 8 - 11;
    local cipher_txt = ''
    for i = 1, #msg, chunkSize do
        local sub_msg = msg:sub(i, i + chunkSize - 1)
        local sub_cipher_txt, err = pub:encrypt(sub_msg)
        if err then
            return nil, nil
        end
        cipher_txt = cipher_txt .. sub_cipher_txt
    end
    return 1, cipher_txt
end

--私钥解密
function _M.private_decrypt(msg, privateKey)
    local key = gsub(privateKey, "\\n", "\n")

    local pri = openssl_pkey.new(key)

    local chunkSize = 2048 / 8;
    local decrypted = ''
    for i = 1, #msg, chunkSize do
        local sub_msg = msg:sub(i, i + chunkSize - 1)
        local sub_decrypted_txt, err = pri:decrypt(sub_msg)
        if err then
            return nil, nil
        end
        decrypted = decrypted .. sub_decrypted_txt
    end
    return 1, decrypted
end

return _M
