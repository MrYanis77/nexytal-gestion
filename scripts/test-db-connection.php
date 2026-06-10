<?php
/**
 * Teste la connexion MySQL Ionos avec la même config que l'API.
 * Usage : php scripts/test-db-connection.php
 */

require_once __DIR__ . '/../api/config/config.php';

$password = resolveDbPassword();
$dsn = sprintf(
    'mysql:host=%s;port=%d;dbname=%s;charset=%s',
    DB_HOST,
    DB_PORT,
    DB_NAME,
    DB_CHARSET
);

echo "Host: " . DB_HOST . PHP_EOL;
echo "Database: " . DB_NAME . PHP_EOL;
echo "User: " . DB_USER . PHP_EOL;
echo "Password length: " . strlen($password) . PHP_EOL;
echo "Password source: " . (env('DB_PASSWORD', env('DB_PASS', '')) !== '' ? 'env' : 'fallback') . PHP_EOL;

try {
    $pdo = new PDO($dsn, DB_USER, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    $count = (int) $pdo->query('SELECT COUNT(*) FROM core_sites')->fetchColumn();
    echo "OK — connected, core_sites count: {$count}" . PHP_EOL;
    exit(0);
} catch (PDOException $e) {
    echo "FAIL — " . $e->getMessage() . PHP_EOL;
    echo "→ Réinitialisez le mot de passe dans Ionos (dbu977482), testez dans phpMyAdmin, puis mettez à jour api/config/.env" . PHP_EOL;
    exit(1);
}
