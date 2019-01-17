FROM alpine

MAINTAINER RekGRpth

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
    && apk add --no-cache --virtual .build-deps \
        cmake \
        findutils \
        gcc \
        git \
        make \
        musl-dev \
        openssl-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/engine.git \
    && cd /usr/src/engine \
    && cmake . \
    && make -j"$(nproc)" \
    && make -j"$(nproc)" install \
    && apk add --no-cache --virtual .gost-rundeps \
        $( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        ) \
        openssl \
        shadow \
        su-exec \
        tzdata \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src \
    && sed -i '6i openssl_conf=openssl_def' /etc/ssl/openssl.cnf \
    && echo "" >> /etc/ssl/openssl.cnf \
    && echo "# OpenSSL default section" >> /etc/ssl/openssl.cnf \
    && echo "[openssl_def]" >> /etc/ssl/openssl.cnf \
    && echo "engines = engine_section" >> /etc/ssl/openssl.cnf \
    && echo "" >> /etc/ssl/openssl.cnf \
    && echo "# Engine scetion" >> /etc/ssl/openssl.cnf \
    && echo "[engine_section]" >> /etc/ssl/openssl.cnf \
    && echo "gost = gost_section" >> /etc/ssl/openssl.cnf \
    && echo "" >> /etc/ssl/openssl.cnf \
    && echo "# Engine gost section" >> /etc/ssl/openssl.cnf \
    && echo "[gost_section]" >> /etc/ssl/openssl.cnf \
    && echo "engine_id = gost" >> /etc/ssl/openssl.cnf \
    && echo "default_algorithms = ALL" >> /etc/ssl/openssl.cnf \
    && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /etc/ssl/openssl.cnf

CMD [ "sh" ]
