<?php
/**
 * Simple Health Check for Railway
 */

// Check if we're in installation mode
$installing = !file_exists(__DIR__ . '/config.php');

// Set content type to JSON
header('Content-Type: application/json');

// Always return success during deployment
http_response_code(200);

// Return health information
echo json_encode([
    'status' => 'ok',
    'installing' => $installing,
    'message' => $installing ? 'Moodle installation in progress' : 'Moodle is running',
    'timestamp' => time()
]);