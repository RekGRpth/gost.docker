#!/bin/sh -eux

sed -i '/\[openssl_init\]/ a engines = engine_section' "$1"

sed -i '6i openssl_conf=openssl_def' "$1"
cat >>"$1" <<EOF

# OpenSSL default section
[openssl_def]
engines = engine_section

# Engine scetion
[engine_section]
gost = gost_section

# Engine gost section
[gost_section]
engine_id = gost
default_algorithms = ALL
CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet
EOF
