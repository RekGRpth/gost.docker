FROM alpine
MAINTAINER RekGRpth
ADD bin /usr/local/bin
#COPY gost /usr/src/engine
CMD [ "sh" ]
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV CFLAGS="-rdynamic -fno-omit-frame-pointer" \
    CPPFLAGS="-rdynamic -fno-omit-frame-pointer" \
    HOME=/home
WORKDIR "${HOME}"
RUN exec 2>&1 \
    && set -ex \
#    && echo https://mirror.yandex.ru/mirrors/alpine/v3.11/main/ > /etc/apk/repositories \
#    && echo https://mirror.yandex.ru/mirrors/alpine/v3.11/community/ >> /etc/apk/repositories \
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
    && git clone --recursive https://github.com/RekGRpth/libexecinfo.git \
#    && git clone --recursive https://github.com/RekGRpth/musl-locales.git \
    && cd /usr/src/libexecinfo \
    && PREFIX=/usr/local make -j"$(nproc)" install \
#    && cd /usr/src/musl-locales \
#    && cmake . && make -j"$(nproc)" install \
    && cd /usr/src/engine \
    && cmake . && make -j"$(nproc)" install \
    && (strip /usr/local/bin/* /usr/local/lib/*.so /usr/lib/engines*/gost.so || true) \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --virtual .locales-rundeps \
        musl-locales \
    && apk add --no-cache --virtual .gost-rundeps \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        openssl \
        shadow \
        su-exec \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src \
    && chmod +x /usr/local/bin/docker_entrypoint.sh /usr/local/bin/update_permissions.sh \
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
    && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /etc/ssl/openssl.cnf \
    && echo done
