local rc4_encrypt = require "kong.plugins.request-encrypt.encrypt"
local rsa_encrypt = require "kong.plugins.request-encrypt.rsa"
local kong = kong
local find = string.find
local lower = string.lower
local sub = string.sub
local ngx_INFO = ngx.INFO
local ngx_log = ngx.log

local _M = {}

local function is_encrypt_body(content_type)
    return content_type and find(lower(content_type), "application/kndy", nil, true)
end

local function failed_and_exit(conf, message, code)
    code = code or conf.fail_encrypt_status
    message = message or conf.fail_encrypt_message
    kong.response.exit(200, { code = code, massage = message })
end

local function decrypt(secret, body, algorithm)
    if algorithm == "rc4" then
        return pcall(rc4_encrypt.decrypt, secret, body)
    end
    if algorithm == "rsa" then
        return rsa_encrypt.private_decrypt(body, secret)
    end
    return nil, nil
end

function _M.execute(conf)
    if (conf.request_enabled or conf.response_enabled)
            and kong.request.get_method() ~= "OPTIONS" then

        local body = kong.request.get_raw_body()

        if conf.request_enabled and is_encrypt_body(kong.request.get_header("Content-Type")) then
            -- 解密
            local ok, decrypt_body = decrypt(conf.secret, body, conf.algorithm)
            ngx_log(ngx_INFO, "decrypt,", ok, "---", decrypt_body, "---", conf.algorithm, "---", conf.secret, "---", body)
            if ok then
                -- 转成json
                ngx_log(ngx_INFO, "decrypt done,", conf.algorithm,"---", conf.secret, "---", decrypt_body)
                kong.service.request.set_header("Content-Type", "application/json; charset=utf-8")
                kong.service.request.set_raw_body(decrypt_body)
            else
                failed_and_exit(conf)
            end
        end
    end
end

return _M