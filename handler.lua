local access = require "kong.plugins.request-encrypt.access"
local rc4_encrypt = require "kong.plugins.request-encrypt.encrypt"
local rsa_encrypt = require "kong.plugins.request-encrypt.rsa"
local kong = kong

local RequestEncryptHandler = {
    VERSION  = "1.0.0",
    PRIORITY = 900,
}

function RequestEncryptHandler:access(conf)
    access.execute(conf)
end

function RequestEncryptHandler:header_filter(conf)
    if  kong.response.get_source() ~= "exit"
            and conf.response_enabled and kong.request.get_method() ~= "OPTIONS" then
        kong.response.clear_header("Content-Length")
        kong.response.set_header("Content-Type", "application/kndy; charset=utf-8")
    end
end

local function encrypt(secret, body, algorithm)
    if algorithm == "rc4" then
        return pcall(rc4_encrypt.encrypt, secret, body)
    end
    if algorithm == "rsa" then
        return rsa_encrypt.public_encrypt(body, secret)
    end
    return nil, nil
end


function RequestEncryptHandler:body_filter(conf)
    if kong.response.get_source() ~= "exit"
            and conf.response_enabled and kong.request.get_method() ~= "OPTIONS" then
        local body = kong.response.get_raw_body()
        if body then
            local ok, encrypt_body = encrypt(conf.secret, body, conf.algorithm)
            if ok and encrypt_body then
                kong.response.set_raw_body(encrypt_body)
            else
                kong.response.exit(200, { code = conf.fail_encrypt_status, massage = conf.fail_encrypt_message })
            end
        end
    end
end

return RequestEncryptHandler
