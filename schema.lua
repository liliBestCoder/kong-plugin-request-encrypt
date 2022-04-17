local typedefs = require "kong.db.schema.typedefs"

return {
    name = "request-encrypt",
    fields = {
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { fail_encrypt_status = { type = "number", default = 494 } },
                { fail_encrypt_message = { type = "string" } },
                { response_enabled = { type = "boolean", default = true } },
                { request_enabled = { type = "boolean", default = true } },
                { secret = { type = "string"} },
                { algorithm = { type = "string", default = "rc4"} }
            }
        }
        }
    }
}
