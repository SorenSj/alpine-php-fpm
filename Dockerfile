# Dockerfile

# Use the official PHP 8.2 FPM Alpine base image
FROM php:8.2-fpm-alpine

# Add labels for better maintainability
LABEL maintainer="Søren Sjøstrøm <soren.sjostrom@hotmail.com>" \
    Description="PHP-FPM v8.2 with essential extensions on top of Alpine Linux."

# Composer - https://getcomposer.org/download/
ARG COMPOSER_VERSION="2.6.4"
ARG COMPOSER_SUM="5a39f3e2ce5ba391ee3fecb227faf21390f5b7ed5c56f14cab9e1c3048bcf8b8"

# Swoole - https://github.com/swoole/swoole-src
ARG OPENSWOOLE_VERSION="22.0.0"

# Phalcon - https://github.com/phalcon/cphalcon
ARG PHALCON_VERSION="5.3.1"

# Set environment variables for configuration and defaults
ENV APP_ENV=production \
    APP_DEBUG=false \
    APP_PORT=8000 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=10000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128 \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE=10 \
    PHP_OPCACHE_REVALIDATE_FREQ=0 \
    PHP_OPCACHE_ENABLE_CLI=1 \
    PHP_OPENSSL=1 \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=30 \
    PHP_MAX_INPUT_TIME=60 \
    PHP_POST_MAX_SIZE=100M \
    PHP_UPLOAD_MAX_FILESIZE=100M \
    PHP_MAX_FILE_UPLOADS=20 \
    PHP_SESSION_SAVE_HANDLER=files \
    PHP_SESSION_SAVE_PATH=/tmp \
    PHP_SESSION_GC_MAXLIFETIME=1440 \
    PHP_SESSION_GC_DIVISOR=100 \
    PHP_SESSION_GC_PROBABILITY=1 \
    PHP_FPM_USER=www-data \
    PHP_FPM_GROUP=www-data \
    PHP_FPM_LISTEN_MODE=0660 \
    PHP_FPM_LISTEN_OWNER=www-data \
    PHP_FPM_LISTEN_GROUP=www-data \
    PHP_FPM_PM=dynamic \
    PHP_FPM_PM_MAX_CHILDREN=5 \
    PHP_FPM_PM_START_SERVERS=2 \
    PHP_FPM_PM_MIN_SPARE_SERVERS=1 \
    PHP_FPM_PM_MAX_SPARE_SERVERS=3 \
    PHP_FPM_PM_PROCESS_IDLE_TIMEOUT=10s \
    PHP_FPM_PM_MAX_REQUESTS=500

#RUN addgroup -g 1000 -S app && \
#    adduser -u 1000 -S app -G app

# Install production dependencies
RUN set -eux && apk add --no-cache \
# Only for test/debugging
#        bash \
        c-client \
        ca-certificates \
        freetds \
        freetype \
        gettext \
        gmp \
        icu-libs \
        imagemagick \
        imap \
        libffi \
        libgmpxx \
        libintl \
        libjpeg-turbo \
        libmemcached-libs \
        libpng \
        libpq \
        librdkafka \
        libssh2 \
        libstdc++ \
        libtool \
        libxpm \
        libxslt \
        libzip \
# Only for test/debugging
#        openssh \
        rabbitmq-c \
        tidyhtml \
        tzdata \
        unixodbc \
        vips \
        yaml \
        zlib

RUN set -eux && apk add --update icu \
    && apk add --update linux-headers \
\
    && apk add --no-cache --virtual .php-deps \
        make \
\
# Install dev dependencies
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        bzip2-dev \
        cmake \
        curl-dev \
        cyrus-sasl-dev \
        freetds-dev \
        freetype-dev \
        g++ \
        gcc \
        gettext-dev \
        git \
        gmp-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        krb5-dev \
        libc-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libpng-dev \
        librdkafka-dev \
        libssh2-dev \
        libwebp-dev \
        libxml2-dev \
        libxpm-dev \
        libxslt-dev \
        libzip-dev \
        openssl-dev \
        pcre-dev \
        pcre2-dev \
        pkgconf \
        postgresql-dev \
        rabbitmq-c-dev \
        tidyhtml-dev \
        unixodbc-dev \
        vips-dev \
        yaml-dev \
        zlib-dev \
\
# Enable ffi if it exists
    && set -eux \
    && if [ -f /usr/local/etc/php/conf.d/docker-php-ext-ffi.ini ]; then \
        echo "ffi.enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-ffi.ini; \
    fi \
\
################################
# Install PHP extensions
################################
# Install gd
    && ln -s /usr/lib/$(apk --print-arch)-linux-gnu/libXpm.* /usr/lib/ \
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-xpm \
        --with-freetype \
        --enable-gd-jis-conv \
    && docker-php-ext-install -j$(nproc) gd \
    && true \
\
# Install amqp
    && pecl install -o -f amqp \
    && docker-php-ext-enable amqp \
    && true \
\
# Install apcu
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && true \
\
# Install ast
    && pecl install ast \
    && docker-php-ext-enable ast \
    && true \
\
# Install composer
    && set -eux \
    && curl -LO "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    && echo "${COMPOSER_SUM}  composer.phar" | sha256sum -c - \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && composer --version \
    && true \
\
# Install gettext
    && docker-php-ext-install -j$(nproc) gettext \
    && true \
\
# Install gmp
    && docker-php-ext-install -j$(nproc) gmp \
    && true \
\
# Install bcmath
    && docker-php-ext-install -j$(nproc) bcmath \
    && true \
\
# Install bz2
    && docker-php-ext-install -j$(nproc) bz2 \
    && true \
\
# Install exif
    && docker-php-ext-install -j$(nproc) exif \
    && true \
\
# Install imap
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl --with-imap \
    && docker-php-ext-install -j$(nproc) imap \
    && true \
\
# Install imagick
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && true \
\
# Install intl
    && docker-php-ext-install -j$(nproc) intl \
    && true \
\
# Install igbinary and memcached
     # Install igbinary (memcached's deps)
     && pecl install igbinary \
     # Install memcached
     && (pecl install --nobuild memcached \
        && cd "$(pecl config-get temp_dir)/memcached" \
        && phpize \
        && ./configure --enable-memcached-igbinary \
        && make -j$(nproc) \
        && make install \
        && cd /tmp/) \
    && docker-php-ext-enable igbinary memcached \
    && true \
\
# Install ldap
#    && docker-php-ext-configure ldap \
#    && docker-php-ext-install ldap \
#    && true \
#\
# Install mongodb
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && true \
\
# Install mysqli
    && docker-php-ext-install -j$(nproc) mysqli \
    && true \
\
# Install oauth
    && pecl install oauth \
    && docker-php-ext-enable oauth \
    && true \
\
# Install opcache
    && docker-php-ext-install -j$(nproc) opcache \
    && true \
\
# Install openswoole
    && docker-php-ext-install sockets \
    && docker-php-source extract \
    && mkdir /usr/src/php/ext/openswoole \
    && curl -sfL https://github.com/openswoole/swoole-src/archive/v${OPENSWOOLE_VERSION}.tar.gz -o swoole.tar.gz \
    && tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/openswoole \
    && docker-php-ext-configure openswoole \
        --enable-http2 \
        --enable-mysqlnd \
        --enable-openssl \
        --enable-sockets --enable-hook-curl \
    && docker-php-ext-install -j$(nproc) --ini-name zzz-docker-php-ext-openswoole.ini openswoole \
    && docker-php-ext-enable openswoole \
    && true \
\
# Install pdo_mysql
    && docker-php-ext-configure pdo_mysql --with-zlib-dir=/usr \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && true \
\
# Install pdo_dblib
    && docker-php-ext-install -j$(nproc) pdo_dblib \
    && true \
\
# Install pcntl
    && docker-php-ext-install -j$(nproc) pcntl \
    && true \
\
# Install phalcon
    && git clone --depth=1 --branch=v${PHALCON_VERSION} https://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build \
    && sh ./install \
    && docker-php-ext-enable phalcon \
    && true \
\
# Install pdo_pgsql
    && docker-php-ext-install -j$(nproc) pdo_pgsql \
    && true \
\
# Install pgsql
    && docker-php-ext-install -j$(nproc) pgsql \
    && true \
\
# ONLY 64-bit targets
    && if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "aarch64" ]; then \
    # Install sqlsrv
        pecl install sqlsrv; \
        docker-php-ext-enable sqlsrv; \
        true; \
    # Install pdo_sqlsrv
        pecl install pdo_sqlsrv; \
        docker-php-ext-enable pdo_sqlsrv; \
        true; \
    fi \
\
# Install psr
    && pecl install psr \
    && docker-php-ext-enable psr \
    && true \
\
# Install redis
    && pecl install redis \
    && docker-php-ext-enable redis \
    && true \
\
# Install rdkafka
    && pecl install rdkafka \
    && docker-php-ext-enable rdkafka \
    && true \
\
# Install soap
    && docker-php-ext-install -j$(nproc) soap \
    && true \
\
# Install ssh2
    && pecl install ssh2-1.3.1 \
    && docker-php-ext-enable ssh2 \
    && true \
\
# Install tidy
    && docker-php-ext-install -j$(nproc) tidy \
    && true \
\
# Install uploadprogress
    && pecl install uploadprogress \
    && docker-php-ext-enable uploadprogress \
    && true \
\
# Install xsl
    && docker-php-ext-install -j$(nproc) xsl \
    && true \
\
# Install xdebug
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && true \
\
# Install yaml
    && pecl install yaml \
    && docker-php-ext-enable yaml \
    && true \
\
# Install vips
    && pecl install vips \
    && docker-php-ext-enable vips \
    && true \
\
# Install zip
    && docker-php-ext-configure zip --with-zip \
    && docker-php-ext-install -j$(nproc) zip \
    && true \
\
# Make a cleanup
    && apk del .build-deps \
    && docker-php-source delete \
    && rm -f swoole.tar.gz $HOME/.composer/*-old.phar \
    && rm -rf /usr/share/php8 \
    && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* \
    && true \
\
    && set -eux \
# Fix php.ini settings for enabled extensions
    && chmod +x "$(php -r 'echo ini_get("extension_dir");')"/* \
    && true \
\
# Shrink binaries
    && (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true)

# Set the working directory
WORKDIR /var/www/html

VOLUME /var/www/html

# Copy the application code to the container
COPY . /var/www/html

# Install application dependencies
# RUN composer install --no-dev --optimize-autoloader

# Copy util scripts
COPY envsubst.sh /envsubst.sh
COPY entrypoint.sh /entrypoint.sh
#
ENTRYPOINT ["/entrypoint.sh"]
#        
# Expose the port on which your application will run
EXPOSE ${APP_PORT}
# Expose the default RabbitMQ port
EXPOSE ${RABBITMQ_PORT}
#
# Start the PHP-FPM server
CMD ["php-fpm", "index.php"]
