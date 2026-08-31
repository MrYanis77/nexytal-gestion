<?php
/**
 * Exécute les smoke INSERT bdd.sql en CLI (sans HTTP).
 * Usage : php run_insert_tests.php
 */
define('APP_ENV', getenv('APP_ENV') ?: 'development');

require_once __DIR__ . '/api/config/config.php';
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/modules/health/insert_tests.php';

try {
    $conn = testDbConnection();
    if (!$conn['connected']) {
        fwrite(STDERR, "Connexion BDD échouée : " . ($conn['error'] ?? 'inconnue') . "\n");
        fwrite(STDERR, "Configurez api/config/.env (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD)\n");
        exit(1);
    }

    echo "Base : " . DB_NAME . " @ " . DB_HOST . "\n";
    echo str_repeat('-', 60) . "\n";

    $report = runInsertSmokeTests();
    $summary = $report['summary'];

    foreach ($report['results'] as $row) {
        $line = $row['ok']
            ? sprintf('[OK]   %-30s %s', $row['table'], $row['detail'] ?? ('id=' . ($row['id'] ?? '-')))
            : sprintf('[FAIL] %-30s %s', $row['table'], $row['error']);
        echo $line . "\n";
    }

    echo str_repeat('-', 60) . "\n";
    echo sprintf(
        "Résultat : %d OK, %d échecs / %d tests (suffix=%s)\n",
        $summary['ok'],
        $summary['failed'],
        $summary['total'],
        $report['suffix']
    );

    exit($summary['failed'] > 0 ? 1 : 0);
} catch (Throwable $e) {
    fwrite(STDERR, "Erreur : " . $e->getMessage() . "\n");
    exit(1);
}
