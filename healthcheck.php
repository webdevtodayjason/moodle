<?php
/**
 * Moodle Health Check Script for Railway
 *
 * This script performs basic health checks for Moodle running on Railway.
 * It verifies:
 * - Database connectivity
 * - Moodle core functionality
 * - File system access
 *
 * Returns HTTP 200 if all checks pass, HTTP 500 if any check fails.
 */

// Security: Only allow access from Railway or with the correct token
$allowed = false;

// Check for Railway's internal health check
if (isset($_SERVER['HTTP_USER_AGENT']) && strpos($_SERVER['HTTP_USER_AGENT'], 'Railway') !== false) {
    $allowed = true;
}

// Check for health check token if defined
if (isset($_SERVER['HTTP_X_HEALTHCHECK_TOKEN']) && !empty(getenv('HEALTHCHECK_TOKEN'))) {
    if ($_SERVER['HTTP_X_HEALTHCHECK_TOKEN'] === getenv('HEALTHCHECK_TOKEN')) {
        $allowed = true;
    }
}

// Default status
$status = 'error';
$message = 'Health check failed';
$http_code = 500;

if ($allowed) {
    try {
        // Load Moodle configuration
        if (!file_exists(__DIR__ . '/config.php')) {
            throw new Exception('Moodle not installed (config.php missing)');
        }

        // Initialize Moodle environment
        define('CLI_SCRIPT', true);
        require_once(__DIR__ . '/config.php');
        require_once($CFG->dirroot . '/lib/moodlelib.php');

        // Check 1: Database connectivity
        try {
            // Test database connection with a simple query
            $dbcount = $DB->count_records('user');
            if ($dbcount === false) {
                throw new Exception('Database query failed');
            }
        } catch (Exception $e) {
            throw new Exception('Database connectivity check failed: ' . $e->getMessage());
        }

        // Check 2: File system access
        try {
            // Check dataroot directory is accessible
            if (!is_dir($CFG->dataroot) || !is_writable($CFG->dataroot)) {
                throw new Exception('Moodle data directory is not accessible or writable');
            }
            
            // Create a temporary file
            $test_file = $CFG->dataroot . '/healthcheck_test.txt';
            if (file_put_contents($test_file, 'test') === false) {
                throw new Exception('Cannot write to Moodle data directory');
            }
            
            // Delete the test file
            if (!unlink($test_file)) {
                throw new Exception('Cannot delete from Moodle data directory');
            }
        } catch (Exception $e) {
            throw new Exception('File system check failed: ' . $e->getMessage());
        }

        // Check 3: Core functionality
        try {
            // Check if the site is in maintenance mode
            if (!empty($CFG->maintenance_enabled)) {
                throw new Exception('Site is in maintenance mode');
            }

            // Verify core services are available
            if (!function_exists('get_string')) {
                throw new Exception('Core Moodle function not available');
            }
            
            // Test core string functionality
            $test_string = get_string('home');
            if (empty($test_string)) {
                throw new Exception('Core string function failed');
            }
        } catch (Exception $e) {
            throw new Exception('Core functionality check failed: ' . $e->getMessage());
        }

        // All checks passed
        $status = 'ok';
        $message = 'All health checks passed';
        $http_code = 200;
        
    } catch (Exception $e) {
        $status = 'error';
        $message = $e->getMessage();
        $http_code = 500;
    }
} else {
    // Access denied
    $status = 'error';
    $message = 'Access denied';
    $http_code = 403;
}

// Set content type to JSON
header('Content-Type: application/json');

// Set HTTP status code
http_response_code($http_code);

// Return JSON response
echo json_encode([
    'status' => $status,
    'message' => $message,
    'timestamp' => time(),
    'version' => isset($CFG->version) ? $CFG->version : 'unknown'
]);

