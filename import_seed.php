<?php
/**
 * Importe seed_bdd.sql (schéma bdd.sql) après bdd.sql + seed_admin.sql
 * Usage : php import_seed.php
 */
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/lib/db.php';

$seedFile = __DIR__ . '/api/sql/seed_bdd.sql';
if (!is_readable($seedFile)) {
    fwrite(STDERR, "Fichier introuvable : $seedFile\n");
    exit(1);
}

$sql = file_get_contents($seedFile);

try {
    $db = getDb();
    $db->exec($sql);
    echo "Seed bdd.sql importé avec succès dans " . DB_NAME . ".\n";
    echo "Login : admin@nexytal.com / password\n";
    echo "Vérification : api/sql/verify_bdd_tables.sql\n";
} catch (PDOException $e) {
    fwrite(STDERR, "Erreur import seed : " . $e->getMessage() . "\n");
    exit(1);
}
