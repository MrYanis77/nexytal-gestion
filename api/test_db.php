<?php
require __DIR__ . '/config/database.php';
$db = getDb();
$stmt = $db->query('SHOW COLUMNS FROM recrutement_contract_types');
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
echo "\nSECTORS\n";
$stmt = $db->query('SHOW COLUMNS FROM recrutement_sectors');
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
