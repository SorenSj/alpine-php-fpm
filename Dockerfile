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
ARG SWOOLE_VERSION="5.1.0"

# Phalcon - https://github.com/phalcon/cphalcon
ARG PHALCON_VERSION="5.3.1"

