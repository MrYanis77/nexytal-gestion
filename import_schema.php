<?php
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/lib/db.php';

$sql = file_get_contents(__DIR__ . '/schema_v2.sql');

try {
    $db = getDb();
    
    // We cannot execute multiple statements easily with a single PDO execute if it's disabled.
    // Let's try to just use exec() which might support multiple queries in MariaDB.
    $db->exec('DROP DATABASE IF EXISTS nexytal; CREATE DATABASE nexytal; USE nexytal;');
    $db->exec($sql);
    echo "Schema imported successfully.\n";
} catch (PDOException $e) {
    echo "Error importing schema: " . $e->getMessage() . "\n";
}
