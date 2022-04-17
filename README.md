### kong-plugin-request-encrypt

**kong-plugin-request-encrypt** is a kong plugin that integrates request decryption, response encryption functions. You can configure whether to enable these functions through the configuration file. 

You can use kong http api to config it to integrates yourself service encryption or decryption.

By the way, so far, it only support RC4 symmetric encryption and RSA asymmetric encryption

#### Configuration

|name|type|required|default|desc|
|---|---|---|---|---|
|fail_encrypt_status|number|no|494|code returned to the client for encryption or decryption failure|
|fail_encrypt_message|string|no|none|message returned to the client for encryption or decryption failure|
|response_enabled|boolean|no|true|Whether to enable response encryption|
|request_enabled|boolean|no|true|Whether to request decryption|
|secret|string|no|none|secret key|
|algorithm|string|no|encryption or decryption algorithm, support RC4,RSA|