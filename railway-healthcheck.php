<?php
/**
 * Simple Health Check for Railway
 * 
 * This is a lightweight health check that doesn't depend on Moodle being initialized.
 * It just returns a 200 status code to indicate the web server is running.
 */

// Set content type to JSON
header('Content-Type: application/json');

// Always return success (during deployment phases)
http_response_code(200);

// Return basic health information
echo json_encode([
    'status' => 'ok',
    'message' => 'Web server is running',
    'timestamp' => time()
]);