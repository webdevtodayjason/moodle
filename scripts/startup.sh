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
    
    # Debug: Print environment variables
    echo "RAILWAY_STATIC_URL: ${RAILWAY_STATIC_URL}"
    echo "RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN}"
    echo "RAILWAY_URL: ${RAILWAY_URL}"
    
    php /var/www/html/scripts/setup-config.php
    
    if [ -f /var/www/html/config.php ]; then
        echo "Config file created successfully"
        chown www-data:www-data /var/www/html/config.php
    else
        echo "ERROR: Failed to create config.php"
    fi
else
    echo "Existing config.php found, skipping configuration"
fi

# Start Apache in foreground
echo "Starting Apache web server..."
apache2-foreground