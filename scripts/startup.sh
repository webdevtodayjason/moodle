#!/bin/bash
set -e

echo "Starting Moodle initialization..."

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Parse DATABASE_URL environment variable
if [ -z "$DATABASE_URL" ]; then
    log "ERROR: DATABASE_URL environment variable is not set"
    exit 1
fi

# Extract database connection details from DATABASE_URL
# Format: postgres://username:password@hostname:port/database
DB_URL=${DATABASE_URL#*//}
DB_USER=${DB_URL%%:*}
DB_URL=${DB_URL#*:}
DB_PASSWORD=${DB_URL%%@*}
DB_URL=${DB_URL#*@}
DB_HOST=${DB_URL%%:*}
DB_URL=${DB_URL#*:}
DB_PORT=${DB_URL%%/*}
DB_NAME=${DB_URL#*/}

# Remove query parameters if present
DB_NAME=${DB_NAME%%\?*}

log "Extracted database connection details:"
log "Host: $DB_HOST, Port: $DB_PORT, Database: $DB_NAME, User: $DB_USER"

# Determine Railway URL
if [ -n "$RAILWAY_STATIC_URL" ]; then
    SITE_URL="$RAILWAY_STATIC_URL"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SITE_URL="https://$RAILWAY_PUBLIC_DOMAIN"
else
    SITE_URL=${RAILWAY_URL:-"http://localhost"}
fi

log "Site URL: $SITE_URL"

# Set default admin credentials if not provided
ADMIN_USER=${MOODLE_ADMIN_USER:-"admin"}
ADMIN_PASSWORD=${MOODLE_ADMIN_PASSWORD:-"Admin123!"}
SITE_NAME=${MOODLE_SITE_NAME:-"Moodle LMS"}
SITE_SHORTNAME=${MOODLE_SITE_SHORTNAME:-"Moodle"}

# Wait for database to be available
log "Waiting for database connection..."
export PGPASSWORD=$DB_PASSWORD
until psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c '\l' > /dev/null 2>&1; do
    log "PostgreSQL is unavailable - waiting..."
    sleep 2
done
log "Database is available!"

# Check if the database exists, if not create it
if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    log "Creating database $DB_NAME..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;"
    
    # Grant privileges
    log "Granting privileges to $DB_USER on $DB_NAME..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO $DB_USER;"
    log "Database setup completed!"
else
    log "Database $DB_NAME already exists."
fi

# Check if Moodle config.php exists
if [ ! -f "/var/www/html/config.php" ]; then
    log "Moodle config.php not found. Creating configuration..."
    
    # Create config.php file
    cat > /var/www/html/config.php << EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '$DB_HOST';
\$CFG->dbname    = '$DB_NAME';
\$CFG->dbuser    = '$DB_USER';
\$CFG->dbpass    = '$DB_PASSWORD';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '$DB_PORT',
);

\$CFG->wwwroot   = '$SITE_URL';
\$CFG->dataroot  = '/data/moodledata';
\$CFG->directorypermissions = 02777;
\$CFG->admin = 'admin';

// Prevent session timeouts
\$CFG->sessiontimeout = 60 * 60 * 8; // 8 hours

// Performance optimization
\$CFG->cachejs = true;
\$CFG->enablestats = false;
\$CFG->debug = 0;
\$CFG->debugdisplay = 0;

// Set timezone
date_default_timezone_set('UTC');

require_once(__DIR__ . '/lib/setup.php');
EOF

    # Set proper ownership for config.php
    chown www-data:www-data /var/www/html/config.php
    chmod 640 /var/www/html/config.php
    
    log "Running Moodle installation..."
    # Run the Moodle CLI installation
    sudo -u www-data php /var/www/html/admin/cli/install.php \
        --chmod=2777 \
        --lang=en \
        --dbtype=pgsql \
        --dbhost=$DB_HOST \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbport=$DB_PORT \
        --prefix=mdl_ \
        --wwwroot=$SITE_URL \
        --dataroot=/data/moodledata \
        --fullname="$SITE_NAME" \
        --shortname="$SITE_SHORTNAME" \
        --adminuser=$ADMIN_USER \
        --adminpass=$ADMIN_PASSWORD \
        --adminemail="admin@example.com" \
        --agree-license \
        --non-interactive \
        --allow-unstable
    
    log "Moodle installation completed!"
else
    log "Moodle already installed. Skipping installation."
fi

# Setup Moodle cron job
log "Setting up Moodle cron job..."
echo "* * * * * /usr/local/bin/php /var/www/html/admin/cli/cron.php > /dev/null 2>&1" > /etc/cron.d/moodle
chmod 0644 /etc/cron.d/moodle

# Create the cron log file and adjust permissions
touch /var/log/moodle-cron.log
chown www-data:www-data /var/log/moodle-cron.log

# Create any required directories and set permissions
log "Setting up directory permissions..."
mkdir -p /data/moodledata
chown -R www-data:www-data /data/moodledata /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /data/moodledata

# Create supervisor log directory if it doesn't exist
mkdir -p /var/log/supervisor

# Start Supervisor (which starts Apache and cron)
log "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

