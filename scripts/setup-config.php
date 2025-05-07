<?php
// Automatic Moodle config setup for Railway deployments

// Parse the DATABASE_URL environment variable
$dbUrl = getenv('DATABASE_URL');
if (!$dbUrl) {
    die("ERROR: DATABASE_URL environment variable is not set\n");
}

// Format: postgres://username:password@hostname:port/database
$pattern = '/postgres:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/';
if (!preg_match($pattern, $dbUrl, $matches)) {
    die("ERROR: Invalid DATABASE_URL format\n");
}

$dbUser = $matches[1];
$dbPass = $matches[2];
$dbHost = $matches[3];
$dbPort = $matches[4];
$dbName = $matches[5];

// Determine site URL - always use HTTPS for Railway deployments
if (getenv('RAILWAY_STATIC_URL')) {
    $siteUrl = getenv('RAILWAY_STATIC_URL');
} elseif (getenv('RAILWAY_PUBLIC_DOMAIN')) {
    $siteUrl = 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN');
} elseif (getenv('RAILWAY_URL')) {
    // Ensure Railway URL uses https
    $railwayUrl = getenv('RAILWAY_URL');
    if (strpos($railwayUrl, 'http://') === 0) {
        $railwayUrl = 'https://' . substr($railwayUrl, 7);
    }
    $siteUrl = $railwayUrl;
} else {
    $siteUrl = 'https://localhost';
}

// Ensure site URL ends without a trailing slash
$siteUrl = rtrim($siteUrl, '/');

// Create the config.php file
$configContent = <<<EOT
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '$dbHost';
\$CFG->dbname    = '$dbName';
\$CFG->dbuser    = '$dbUser';
\$CFG->dbpass    = '$dbPass';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '$dbPort',
);

\$CFG->wwwroot   = '$siteUrl';
\$CFG->dataroot  = '/moodledata';
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

// Security
\$CFG->passwordpolicy = 0;

// Force HTTPS for all URLs
\$CFG->sslproxy = true;  // Trust the proxy to handle SSL

// Set slasharguments (needed for CSS to load properly)
\$CFG->slasharguments = true;

require_once(__DIR__ . '/lib/setup.php');
EOT;

// Write the config file
$configPath = __DIR__ . '/config.php';
file_put_contents($configPath, $configContent);
chmod($configPath, 0644);

echo "Moodle config.php created successfully.\n";