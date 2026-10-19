local ffi = require("ffi")
local sodium = ffi.load("lib/libsodium")

ffi.cdef[[
    int sodium_init(void);

    void randombytes_buf(void *buf, size_t size);

    int crypto_aead_xchacha20poly1305_ietf_encrypt(
        unsigned char *c,
        unsigned long long *clen_p,
        const unsigned char *m,
        unsigned long long mlen,
        const unsigned char *ad,
        unsigned long long adlen,
        const unsigned char *nsec,
        const unsigned char *npub,
        const unsigned char *k
    );

    int crypto_aead_xchacha20poly1305_ietf_decrypt(
        unsigned char *m,
        unsigned long long *mlen_p,
        unsigned char *nsec,
        const unsigned char *c,
        unsigned long long clen,
        const unsigned char *ad,
        unsigned long long adlen,
        const unsigned char *npub,
        const unsigned char *k
    );
]]

assert(sodium.sodium_init() >= 0, "libsodium initialization failed.")

local KEY_SIZE = 32
local NONCE_SIZE = 24
local TAG_SIZE = 16
local FORMAT = "SV01"

---@class crypto
local crypto = {
    key = "cb01a1976dac35db3c81c83bcfc479fd"
}
crypto.__index = crypto

--- Encrypts the string.
---@param data string String to encrypt.
---@param key string|nil Key used to encrypt the string. Default is crypto.key.
---@return string|nil encrypted Encrypted string.
function crypto:encrypt(data, key)
    if not key then key = self.key end
    if #key ~= KEY_SIZE then 
        game.error(string.format("Failed to encrypt the string: Key size must be %i.", KEY_SIZE)) 
        return
    end

    local nonce = ffi.new("unsigned char[?]", NONCE_SIZE)
    sodium.randombytes_buf(nonce, NONCE_SIZE)

    local output = ffi.new(
        "unsigned char[?]",
        #data + TAG_SIZE
    )

    local output_len = ffi.new("unsigned long long[1]")

    local result = sodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
        output,
        output_len,
        ffi.cast("const unsigned char *", data),
        #data,
        nil,
        0,
        nil,
        nonce,
        key
    )

    if result ~= 0 then game.error("Failed to encrypt the string: Encryption failed.") return end

    return FORMAT..ffi.string(nonce, NONCE_SIZE)..ffi.string(output, tonumber(output_len[0]))
end

--- Decrypts the string.
---@param data string String to decrypt.
---@param key string|nil Key used to decrypt the string. Default is crypto.key.
---@return string|nil decrypted 
function crypto:decrypt(data, key)
    if not key then key = self.key end
    if #key ~= KEY_SIZE then game.error(string.format("Failed to encrypt the string: Key size must be %i.", KEY_SIZE)) return end

    if #data < 4 + NONCE_SIZE + TAG_SIZE then
        game.error("Failed to decrypt the string: Invalid size.")
        return
    end

    if data:sub(1, 4) ~= FORMAT then
        game.error("Failed to decrypt the string: Unsupported format.")
        return
    end

    local nonce = data:sub(5, 4 + NONCE_SIZE)
    local ciphertext = data:sub(5 + NONCE_SIZE)

    local output = ffi.new(
        "unsigned char[?]",
        #ciphertext - TAG_SIZE
    )

    local output_len = ffi.new("unsigned long long[1]")

    local result = sodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
        output,
        output_len,
        nil,
        ffi.cast("const unsigned char *", ciphertext),
        #ciphertext,
        nil,
        0,
        ffi.cast("const unsigned char *", nonce),
        key
    )

    if result ~= 0 then
        game.error("Failed to decrypt the string: Decryption failed.")
        return
    end

    return ffi.string(output, tonumber(output_len[0]))
end

return crypto