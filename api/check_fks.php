<?php
require __DIR__ . '/config/database.php';
$db = getDb();
try {
    $stmt = $db->query("
        SELECT 
            TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
        FROM
            INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE
            REFERENCED_TABLE_SCHEMA = DATABASE() AND
            TABLE_NAME IN ('offres_emploi', 'entreprises', 'metiers', 'offre_competences', 'metier_competences');
    ");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
} catch(Exception $e) {
    echo $e->getMessage();
}
