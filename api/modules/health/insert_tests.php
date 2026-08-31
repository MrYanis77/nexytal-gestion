<?php
/**
 * modules/health/insert_tests.php - Generic insert tests for every base table.
 *
 * GET  /api/health/insert?key=XXX       -> table counts
 * GET  /api/health/insert/run?key=XXX   -> run rollbacked INSERT tests
 * POST /api/health/insert               -> idem, key in JSON body or X-Test-Key
 *
 * Tests run inside a transaction and are rolled back by default.
 */

function registerHealthInsertRoutes(Router $router): void
{
    $router->get('/api/health/insert', function () {
        if (!assertInsertDiagnosticsAccess(true) || !assertInsertDbConnection()) {
            return;
        }
        Response::success(buildInsertHealthStatus(false));
    });

    $router->get('/api/health/insert/run', function () {
        if (!assertInsertDiagnosticsAccess(true) || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });

    $router->post('/api/health/insert', function () {
        if (!assertInsertDiagnosticsAccess(true) || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });
}

function assertInsertDiagnosticsAccess(bool $requiresKey): bool
{
    if ($requiresKey) {
        return ProductionSecurity::assertInsertTestKeyConfigured() && assertInsertTestKey();
    }

    ProductionSecurity::assertDiagnosticsAllowed();
    return true;
}

function getInsertTestTables(?PDO $db = null): array
{
    $fallback = [
        'alertes_emploi',
        'blog_authors',
        'blog_categories',
        'blog_comments',
        'blog_posts',
        'blog_posts_versions',
        'blog_post_tags',
        'blog_related_posts',
        'blog_tags',
        'candidats',
        'candidatures',
        'candidatures_externes',
        'candidature_historique',
        'candidat_competences',
        'candidat_metiers_souhaites',
        'candidat_tokens',
        'career_applications',
        'career_job_offers',
        'coaches',
        'coaching_appointment_slots',
        'coaching_certifications',
        'coaching_cities',
        'coaching_client_profiles',
        'coaching_coach_client_links',
        'coaching_contact_requests',
        'coaching_contact_slots',
        'coaching_diagnostic_requests',
        'coaching_languages',
        'coaching_portal_accounts',
        'coaching_portal_password_resets',
        'coaching_portal_tokens',
        'coaching_session_bookings',
        'coaching_specialties',
        'coach_certification_links',
        'coach_language_links',
        'coach_specialty_links',
        'competences',
        'core_admin_password_resets',
        'core_admin_sessions',
        'core_admin_site_access',
        'core_admin_users',
        'core_audit_logs',
        'core_sites',
        'demandes_urgentes',
        'entreprises',
        'expertises',
        'formation_categories',
        'formation_courses',
        'formation_course_stats',
        'formation_info_blocks',
        'formation_info_points',
        'formation_jobs',
        'formation_modules',
        'formation_objectives',
        'formation_skills',
        'gdpr_consents_log',
        'gdpr_deletion_requests',
        'marketing_email_logs',
        'media_library',
        'metiers',
        'metier_competences',
        'newsletter_campaigns',
        'newsletter_events',
        'newsletter_lists',
        'newsletter_subscribers',
        'newsletter_subscriptions',
        'offres_emploi',
        'offres_favorites',
        'offre_competences',
        'portal_password_resets',
        'recrutement_scoring_config',
        'recrutement_scoring_history',
        'recruteurs',
        'recruteur_activation_tokens',
        'recruteur_sites',
        'recruteur_tokens',
        'secteurs_activite',
        'seo_metadata',
        'site_pricing',
        'system_logs',
        'trainers',
        'trainer_appointment_slots',
        'trainer_certifications',
        'trainer_certification_links',
        'trainer_cities',
        'trainer_city_links',
        'trainer_client_links',
        'trainer_client_profiles',
        'trainer_courses',
        'trainer_expertise_links',
        'trainer_languages',
        'trainer_language_links',
        'trainer_modalities',
        'trainer_portal_accounts',
        'trainer_portal_password_resets',
        'trainer_portal_tokens',
        'trainer_reviews',
        'trainer_session_bookings',
        'trainer_skills',
        'trainer_skill_links',
        'users',
        'villes',
    ];

    try {
        $db = $db ?? getDb();
        $stmt = $db->prepare(
            "SELECT TABLE_NAME
             FROM information_schema.TABLES
             WHERE TABLE_SCHEMA = DATABASE()
               AND TABLE_TYPE = 'BASE TABLE'
             ORDER BY TABLE_NAME"
        );
        $stmt->execute();
        $tables = array_map('strval', $stmt->fetchAll(PDO::FETCH_COLUMN));
        return $tables ?: $fallback;
    } catch (Throwable $e) {
        return $fallback;
    }
}

function assertInsertDbConnection(): bool
{
    $conn = testDbConnection();
    if ($conn['connected']) {
        return true;
    }
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'data' => $conn]);
    exit;
}

function assertInsertTestKey(): bool
{
    $expected = defined('INSERT_TEST_KEY') ? INSERT_TEST_KEY : '';
    if ($expected === '') {
        Response::forbidden('INSERT_TEST_KEY non configuree dans api/config/.env');
        return false;
    }

    $provided = $_GET['key']
        ?? $_SERVER['HTTP_X_TEST_KEY']
        ?? (Router::getJsonBody()['key'] ?? null);

    if (defined('APP_ENV') && APP_ENV === 'production' && hash_equals(ProductionSecurity::DEFAULT_INSERT_TEST_KEY, $expected)) {
        Response::forbidden('INSERT_TEST_KEY par defaut interdite en production');
        return false;
    }

    if (!is_string($provided) || !hash_equals($expected, $provided)) {
        Response::forbidden('Cle invalide - utilisez ?key=VOTRE_CLE ou header X-Test-Key');
        return false;
    }
    return true;
}

function buildInsertHealthStatus(bool $afterRun): array
{
    $db = getDb();
    $tables = getInsertTestTables($db);
    $counts = [];

    foreach ($tables as $table) {
        try {
            $counts[$table] = (int) $db->query('SELECT COUNT(*) FROM ' . quoteIdent($table))->fetchColumn();
        } catch (PDOException $e) {
            $counts[$table] = null;
        }
    }

    $sites = $counts['core_sites'] ?? 0;
    $withData = count(array_filter($counts, fn ($c) => $c !== null && $c > 0));
    $empty = count(array_filter($counts, fn ($c) => $c === 0));
    $missingTables = count(array_filter($counts, fn ($c) => $c === null));

    return [
        'status' => $missingTables > 0 ? 'error' : 'ok',
        'schema' => 'current_database',
        'mode' => 'rollback_insert_test',
        'time' => date('Y-m-d H:i:s'),
        'database' => DB_NAME,
        'sites_count' => $sites,
        'tables_total' => count($tables),
        'tables_with_data' => $withData,
        'tables_empty' => $empty,
        'tables_missing' => $missingTables,
        'tables' => $counts,
        'run_url' => '/api/health/insert/run?key=VOTRE_INSERT_TEST_KEY',
        'hint' => $afterRun
            ? 'Tests INSERT termines et rollbackes - consultez results[]'
            : 'Lancez /api/health/insert/run avec INSERT_TEST_KEY pour tester toutes les tables',
    ];
}

function runInsertSmokeTests(): array
{
    $db = getDb();
    $suffix = substr(bin2hex(random_bytes(4)), 0, 8);
    $tables = getInsertTestTables($db);
    $results = [];

    $db->beginTransaction();
    $foreignKeyChecksChanged = false;

    try {
        $db->exec('SET FOREIGN_KEY_CHECKS=0');
        $foreignKeyChecksChanged = true;

        foreach ($tables as $table) {
            $results[] = runSingleTableInsertTest($db, $table, $suffix);
        }
    } finally {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        if ($foreignKeyChecksChanged) {
            $db->exec('SET FOREIGN_KEY_CHECKS=1');
        }
    }

    $passed = count(array_filter($results, fn ($r) => $r['ok']));
    $failed = count($results) - $passed;
    $testedTables = array_unique(array_column($results, 'table'));
    $status = buildInsertHealthStatus(true);

    return [
        'status' => $failed === 0 ? 'ok' : 'error',
        'schema' => 'current_database',
        'mode' => 'rollback_insert_test',
        'foreign_key_checks' => 'disabled during rollbacked test transaction',
        'suffix' => $suffix,
        'summary' => [
            'ok' => $passed,
            'failed' => $failed,
            'total' => count($results),
            'tables_all' => count($tables),
            'tables_tested' => count($testedTables),
        ],
        'not_tested' => array_values(array_diff($tables, $testedTables)),
        'results' => $results,
        'tables' => $status['tables'],
        'time' => date('Y-m-d H:i:s'),
    ];
}

function runSingleTableInsertTest(PDO $db, string $table, string $suffix): array
{
    try {
        $columns = getInsertableColumns($db, $table);
        $names = [];
        $placeholders = [];
        $params = [];

        foreach ($columns as $column) {
            $name = (string) $column['COLUMN_NAME'];
            $names[] = quoteIdent($name);
            $placeholder = ':c' . count($params);
            $placeholders[] = $placeholder;
            $params[$placeholder] = buildInsertValue($table, $column, $suffix);
        }

        if ($names === []) {
            $sql = 'INSERT INTO ' . quoteIdent($table) . ' () VALUES ()';
        } else {
            $sql = 'INSERT INTO ' . quoteIdent($table)
                . ' (' . implode(', ', $names) . ') VALUES (' . implode(', ', $placeholders) . ')';
        }

        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $id = (int) $db->lastInsertId();

        return [
            'table' => $table,
            'ok' => true,
            'id' => $id > 0 ? $id : null,
            'columns' => count($columns),
            'detail' => 'insert ok, rolled back',
        ];
    } catch (Throwable $e) {
        return [
            'table' => $table,
            'ok' => false,
            'error' => $e->getMessage(),
        ];
    }
}

function getInsertableColumns(PDO $db, string $table): array
{
    $stmt = $db->prepare(
        "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT,
                CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, EXTRA
         FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE()
           AND TABLE_NAME = :table
         ORDER BY ORDINAL_POSITION"
    );
    $stmt->execute([':table' => $table]);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_values(array_filter($columns, function (array $column): bool {
        $extra = strtolower((string) ($column['EXTRA'] ?? ''));
        if (str_contains($extra, 'auto_increment')) {
            return false;
        }
        if (str_contains($extra, 'generated')) {
            return false;
        }
        return true;
    }));
}

function buildInsertValue(string $table, array $column, string $suffix): mixed
{
    $name = strtolower((string) $column['COLUMN_NAME']);
    $type = strtolower((string) $column['DATA_TYPE']);
    $columnType = strtolower((string) $column['COLUMN_TYPE']);
    $maxLength = isset($column['CHARACTER_MAXIMUM_LENGTH']) ? (int) $column['CHARACTER_MAXIMUM_LENGTH'] : 0;

    if ($type === 'enum') {
        return fitValue(parseFirstEnumValue($columnType) ?? 'test', $maxLength);
    }
    if ($type === 'set') {
        return fitValue(parseFirstEnumValue($columnType) ?? '', $maxLength);
    }
    if ($type === 'json') {
        return json_encode(['test' => true, 'suffix' => $suffix], JSON_UNESCAPED_UNICODE);
    }
    if (in_array($type, ['tinyint', 'smallint', 'mediumint', 'int', 'integer', 'bigint'], true)) {
        if (str_contains($name, 'count') || str_contains($name, 'sort') || str_contains($name, 'order')) {
            return 0;
        }
        if (str_starts_with($name, 'is_') || str_starts_with($name, 'has_') || str_contains($name, 'active') || str_contains($name, 'enabled') || str_contains($name, 'consent') || str_contains($name, 'featured') || str_contains($name, 'urgent') || str_contains($name, 'valide')) {
            return 1;
        }
        return 1;
    }
    if (in_array($type, ['decimal', 'float', 'double', 'real'], true)) {
        return 1.23;
    }
    if ($type === 'year') {
        return 2026;
    }
    if ($type === 'date') {
        return date('Y-m-d');
    }
    if (in_array($type, ['datetime', 'timestamp'], true)) {
        return date('Y-m-d H:i:s');
    }
    if ($type === 'time') {
        return '10:00:00';
    }
    if (in_array($type, ['binary', 'varbinary', 'blob', 'tinyblob', 'mediumblob', 'longblob'], true)) {
        return 'x';
    }

    if (str_contains($name, 'email')) {
        return fitValue("test.$table.$suffix@example.test", $maxLength);
    }
    if (str_contains($name, 'password_hash')) {
        return fitValue('$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', $maxLength);
    }
    if (str_contains($name, 'token_hash')) {
        return fitValue(hash('sha256', "$table|$name|$suffix"), $maxLength);
    }
    if ($name === 'id' || str_ends_with($name, '_id')) {
        return fitValue('1', $maxLength);
    }
    if (str_contains($name, 'slug') || str_contains($name, 'code') || str_contains($name, 'reference')) {
        return fitValue("test-$suffix", $maxLength);
    }
    if (str_contains($name, 'url') || str_contains($name, 'path')) {
        return fitValue("/test-$suffix", $maxLength);
    }
    if (str_contains($name, 'phone') || str_contains($name, 'telephone')) {
        return fitValue('0600000000', $maxLength);
    }
    if (str_contains($name, 'ip_address')) {
        return fitValue('127.0.0.1', $maxLength);
    }
    if (str_contains($name, 'user_agent')) {
        return fitValue('InsertTest/1.0', $maxLength);
    }
    if (str_contains($name, 'status') || str_contains($name, 'statut')) {
        return fitValue('test', $maxLength);
    }
    if (str_contains($name, 'role')) {
        return fitValue('test', $maxLength);
    }

    return fitValue("test-$suffix", $maxLength);
}

function parseFirstEnumValue(string $columnType): ?string
{
    if (!preg_match("/^\\w+\\((.*)\\)$/", $columnType, $matches)) {
        return null;
    }
    if (preg_match("/'((?:[^'\\\\]|\\\\.)*)'/", $matches[1], $value)) {
        return stripcslashes($value[1]);
    }
    return null;
}

function fitValue(string $value, int $maxLength): string
{
    if ($maxLength > 0 && strlen($value) > $maxLength) {
        return substr($value, 0, $maxLength);
    }
    return $value;
}

function quoteIdent(string $identifier): string
{
    return '`' . str_replace('`', '``', $identifier) . '`';
}