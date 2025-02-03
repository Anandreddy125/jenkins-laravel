# Use official PHP with Apache image
FROM php:8.1-apache

# Set working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    git \
    unzip \
    curl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug

# Fix Apache ServerName issue to avoid warnings
RUN echo "ServerName 127.0.0.1" > /etc/apache2/conf-available/fqdn.conf && \
    a2enconf fqdn

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy Laravel project files into the container
COPY . .

# Install Laravel dependencies (without dev dependencies for production)
RUN composer install --no-dev --optimize-autoloader

# Set correct permissions for storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Set Apache document root to the Laravel public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf

# Enable Apache mod_rewrite for Laravel
RUN a2enmod rewrite

# Expose the Apache port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
