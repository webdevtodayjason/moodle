FROM php:8.2-apache

# Install dependencies and PHP extensions required by Moodle
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    zlib1g-dev \
    libsodium-dev \
    libcurl4-openssl-dev \
    unzip \
    cron \
    supervisor \
    vim \
    git \
    libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Moodle
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    intl \
    pgsql \
    mysqli \
    zip \
    soap \
    mbstring \
    gd \
    opcache \
    xsl \
    curl \
    dom \
    xml \
    xmlreader \
    fileinfo \
    sodium \
    exif

# Enable the PDO PostgreSQL extension
RUN docker-php-ext-install pdo_pgsql

# Enable Apache modules
RUN a2enmod rewrite \
    && a2enmod headers \
    && a2enmod expires \
    && a2enmod ssl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set recommended PHP.ini settings
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'upload_max_filesize=256M'; \
    echo 'post_max_size=256M'; \
    echo 'memory_limit=512M'; \
    echo 'max_execution_time=600'; \
    echo 'max_input_vars=5000'; \
    echo 'date.timezone=UTC'; \
} > /usr/local/etc/php/conf.d/moodle-recommended.ini

# Setup document root
WORKDIR /var/www/html

# Setup document root permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Copy moodle codebase
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Install Moodle dependencies
RUN composer install --no-dev --optimize-autoloader

# Create directory for persistent storage
RUN mkdir -p /moodledata \
    && chown -R www-data:www-data /moodledata \
    && chmod -R 777 /moodledata

# Setup supervisor to manage cron
COPY infra/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure Apache
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Create startup script directly in the image
RUN echo '#!/bin/bash' > /usr/local/bin/startup.sh && \
    echo 'set -e' >> /usr/local/bin/startup.sh && \
    echo 'echo "Starting Moodle initialization..."' >> /usr/local/bin/startup.sh && \
    echo 'mkdir -p /moodledata' >> /usr/local/bin/startup.sh && \
    echo 'chown -R www-data:www-data /moodledata' >> /usr/local/bin/startup.sh && \
    echo 'chmod -R 777 /moodledata' >> /usr/local/bin/startup.sh && \
    echo 'apache2-foreground' >> /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/startup.sh && \
    ls -la /usr/local/bin/startup.sh

# Expose Apache
EXPOSE 80

# Entrypoint
CMD ["/usr/local/bin/startup.sh"]

