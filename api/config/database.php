<?php
/**
 * config/database.php — Connexion PDO unique à bdd_nexytal
 * 
 * Singleton PDO (utf8mb4, errmode exception, fetch assoc).
 * Helpers : getDb(), getSiteId($slug), getSiteIdFromDomain($domain)
 */

require_once __DIR__ . '/config.php';

/**
 * Retourne l'instance PDO unique (singleton)
 */
function getDb(): PDO
{
    static $pdo = null;

    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            DB_HOST,
            DB_PORT,
            DB_NAME,
            DB_CHARSET
        );

        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
        ];

        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            error_log('PDO connection failed [' . DB_HOST . '/' . DB_NAME . ']: ' . $e->getMessage());

            if (APP_ENV === 'development') {
                throw $e;
            }

            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error'   => 'Database connection failed',
                'hint'    => 'Vérifiez DB_HOST, DB_NAME, DB_USER, DB_PASS dans api/config/.env ou config.local.php',
            ]);
            exit;
        }
    }

    return $pdo;
}

/**
 * Teste la connexion PDO sans interrompre la requête (diagnostic /health/db).
 *
 * @return array{connected:bool,host:string,database:string,user:string,detail?:string,config_sources?:array}
 */
function testDbConnection(): array
{
    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=%s',
        DB_HOST,
        DB_PORT,
        DB_NAME,
        DB_CHARSET
    );

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
    ];

    $sources = [
        'env_file'     => $GLOBALS['_env_loaded_files'] ?? [],
        'config_local' => is_readable(__DIR__ . '/config.local.php'),
    ];

    try {
        $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        $stmt = $pdo->query('SELECT DATABASE() AS db_name');
        $row = $stmt->fetch();

        return [
            'connected'       => true,
            'host'            => DB_HOST,
            'database'        => $row['db_name'] ?? DB_NAME,
            'user'            => DB_USER,
            'config_sources'  => $sources,
        ];
    } catch (PDOException $e) {
        error_log('PDO test connection failed [' . DB_HOST . '/' . DB_NAME . ']: ' . $e->getMessage());

        return [
            'connected'      => false,
            'host'           => DB_HOST,
            'database'       => DB_NAME,
            'user'           => DB_USER,
            'detail'         => $e->getMessage(),
            'config_sources' => $sources,
        ];
    }
}

/**
 * Récupère le site_id à partir du slug du site
 * Utilise un cache statique pour éviter les requêtes répétées.
 */
function getSiteId(string $slug): ?int
{
    static $cache = [];

    if (isset($cache[$slug])) {
        return $cache[$slug];
    }

    $db = getDb();
    $stmt = $db->prepare('SELECT id FROM core_sites WHERE slug = :slug AND is_active = 1 LIMIT 1');
    $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
    $stmt->execute();
    $row = $stmt->fetch();

    if ($row) {
        $cache[$slug] = (int) $row['id'];
        return $cache[$slug];
    }

    return null;
}

/**
 * Récupère le site_id à partir du domaine
 * Utilisé par les routes publiques pour identifier le site appelant.
 */
function getSiteIdFromDomain(string $domain): ?int
{
    static $cache = [];

    $domain = strtolower(trim($domain));

    if (isset($cache[$domain])) {
        return $cache[$domain];
    }

    $db = getDb();
    $stmt = $db->prepare('SELECT id FROM core_sites WHERE domain = :domain AND is_active = 1 LIMIT 1');
    $stmt->bindParam(':domain', $domain, PDO::PARAM_STR);
    $stmt->execute();
    $row = $stmt->fetch();

    if ($row) {
        $cache[$domain] = (int) $row['id'];
        return $cache[$domain];
    }

    return null;
}

/**
 * Récupère tous les sites actifs
 */
function getAllSites(): array
{
    $db = getDb();
    $stmt = $db->query('SELECT id, name, slug, domain FROM core_sites WHERE is_active = 1 ORDER BY id');
    return $stmt->fetchAll();
}
