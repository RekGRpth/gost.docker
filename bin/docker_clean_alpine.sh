#!/bin/sh -eux

cd /
apk add --no-cache --virtual .gost-rundeps \
    busybox-extras \
    busybox-suid \
    ca-certificates \
    musl-locales \
    shadow \
    su-exec \
    tzdata \
    $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
;
find /usr/local/bin -type f -exec strip '{}' \;
find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;
strip /usr/lib/engines*/gost.so*
apk del --no-cache .build-deps
sed -i '6i openssl_conf=openssl_def' /etc/ssl1.1/openssl.cnf
cat >>/etc/ssl1.1/openssl.cnf <<EOF

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
