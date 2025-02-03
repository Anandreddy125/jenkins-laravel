# Set the base image to PHP with Apache
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev zip git && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy the Laravel project files into the container
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Set the Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Expose the port Apache runs on
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
