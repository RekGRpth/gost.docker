FROM alpine:edge
MAINTAINER RekGRpth
ADD entrypoint.sh /
CMD [ "sh" ]
ENTRYPOINT [ "/entrypoint.sh" ]
ENV HOME=/home
WORKDIR "${HOME}"
RUN set -ex \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        cmake \
        findutils \
        gcc \
        gettext-dev \
        git \
        libintl \
        make \
        musl-dev \
        openssl-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/engine.git \
    && git clone --recursive https://github.com/RekGRpth/musl-locales.git \
    && cd /usr/src/musl-locales \
    && cmake . && make -j"$(nproc)" install \
    && cd /usr/src/engine \
    && cmake . && make -j"$(nproc)" install \
    && (strip /usr/local/bin/* /usr/local/lib/*.so /usr/lib/engines*/gost.so || true) \
    && apk add --no-cache --virtual .gost-rundeps \
        ca-certificates \
        openssl \
        shadow \
        su-exec \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src \
    && chmod +x /entrypoint.sh \
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
