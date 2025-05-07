#!/bin/bash
set -e

echo "Starting Moodle initialization..."

# Create moodledata directory with proper permissions
mkdir -p /moodledata
chown -R www-data:www-data /moodledata
chmod -R 777 /moodledata

# Create config.php if it doesn't exist
if [ ! -f /var/www/html/config.php ]; then
    echo "Creating Moodle config.php..."
    cd /var/www/html
    php /var/www/html/scripts/setup-config.php
    chown www-data:www-data /var/www/html/config.php
fi

# Start Apache in foreground
echo "Starting Apache web server..."
apache2-foreground