<?php
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/lib/db.php';

$sql = file_get_contents(__DIR__ . '/patch_remove_validation.sql');

try {
    $db = getDb();
    $db->exec($sql);
    echo "Patch applied successfully.\n";
} catch (PDOException $e) {
    echo "Error applying patch: " . $e->getMessage() . "\n";
}
