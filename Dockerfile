# =============================================================================
# Pinakes - Library Management System
# PHP-FPM Alpine image (pairs with nginx:alpine + mariadb in docker-compose)
# =============================================================================

FROM php:8.2-fpm-alpine

# Runtime libs + build deps → compile extensions → remove build deps in one layer
RUN apk add --no-cache \
        curl \
        icu-libs \
        libzip \
        freetype \
        libjpeg-turbo \
        libpng \
        libwebp \
        oniguruma \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        icu-dev \
        libzip-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        oniguruma-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo_mysql \
        mbstring \
        zip \
        gd \
        intl \
        opcache \
    && apk del .build-deps

# PHP production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php-custom.ini $PHP_INI_DIR/conf.d/99-pinakes.ini
COPY php-fpm-www.conf /usr/local/etc/php-fpm.d/zz-pinakes.conf

# Application code — tarball avoids pulling in git + its dependencies
WORKDIR /var/www/pinakes
ARG PINAKES_REF=main
ADD https://github.com/fabiodalez-dev/Pinakes/archive/${PINAKES_REF}.tar.gz /tmp/pinakes.tar.gz
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN tar xzf /tmp/pinakes.tar.gz --strip-components=1 -C . \
    && rm /tmp/pinakes.tar.gz \
    && rm -rf .github .coderabbit.yaml \
    && composer install --no-dev --no-interaction --optimize-autoloader \
    && rm /usr/bin/composer

# Preserve bundled plugins so the entrypoint can seed a bind-mounted plugins directory
RUN cp -r storage/plugins /var/www/pinakes-plugins-seed

# Writable directories with correct ownership
RUN mkdir -p \
        storage/backups \
        storage/cache \
        storage/calendar \
        storage/logs \
        storage/plugins \
        storage/sessions \
        storage/tmp \
        storage/uploads \
        public/uploads \
    && chown -R www-data:www-data . \
    && chmod -R 755 storage public/uploads

# Entrypoint handles .env generation and DB readiness check
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
