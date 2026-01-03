FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    nodejs \
    npm \
    git \
    curl \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    postgresql-dev \
    icu-dev \
    zip \
    unzip

# Create necessary directories and set correct permissions
RUN mkdir -p /var/log/supervisor /var/run /var/log/nginx \
    && chown -R www-data:www-data /var/log/supervisor \
    && chmod 777 /var/run

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# Install intl extension separately to ensure proper configuration
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Install Node dependencies and build assets
RUN npm install && npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && php artisan config:cache || true \
    && php artisan route:cache || true

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy and set up startup script
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose port
EXPOSE 80

# Start using startup script
CMD ["/usr/local/bin/startup.sh"]
