<?php
/**
 * modules/health/insert_tests.php — Tests d'insertion BDD (comme /api/health/db)
 *
 * GET  /api/health/insert       → comptages tables (lecture seule)
 * GET  /api/health/insert/run?key=XXX → exécute les smoke INSERT
 * POST /api/health/insert       → idem (clé : ?key=, header X-Test-Key, ou body {"key":"..."})
 *
 * Clé : INSERT_TEST_KEY dans api/config/.env (défaut dev : nexytal-insert-test)
 */

function registerHealthInsertRoutes(Router $router): void
{
    $router->get('/api/health/insert', function () {
        $conn = testDbConnection();
        if (!$conn['connected']) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error'   => 'Database connection failed',
                'data'    => array_merge($conn, [
                    'hint' => 'Corrigez DB_PASSWORD dans api/config/.env (Ionos → Bases de données → dbs15772578)',
                ]),
            ]);
            exit;
        }
        Response::success(buildInsertHealthStatus(false));
    });

    $router->get('/api/health/insert/run', function () {
        if (!assertInsertTestKey() || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });

    $router->post('/api/health/insert', function () {
        if (!assertInsertTestKey() || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });
}

function assertInsertDbConnection(): bool
{
    $conn = testDbConnection();
    if ($conn['connected']) {
        return true;
    }
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error'   => 'Database connection failed',
        'data'    => $conn,
    ]);
    exit;
}

function assertInsertTestKey(): bool
{
    $expected = defined('INSERT_TEST_KEY') ? INSERT_TEST_KEY : '';
    if ($expected === '') {
        Response::forbidden('INSERT_TEST_KEY non configurée dans api/config/.env');
        return false;
    }

    $provided = $_GET['key']
        ?? $_SERVER['HTTP_X_TEST_KEY']
        ?? (Router::getJsonBody()['key'] ?? null);

    if (!is_string($provided) || !hash_equals($expected, $provided)) {
        Response::forbidden('Clé invalide — utilisez ?key=VOTRE_CLE ou header X-Test-Key');
        return false;
    }
    return true;
}

function buildInsertHealthStatus(bool $afterRun): array
{
    $db = getDb();
    $tables = [
        'core_sites',
        'formation_categories',
        'formation_courses',
        'recrutement_offers',
        'blog_posts',
        'coaching_coaches',
        'marketing_newsletter_subs',
        'gdpr_deletion_requests',
        'coaching_diagnostic_requests',
        'seo_metadata',
    ];

    $counts = [];
    foreach ($tables as $table) {
        try {
            $counts[$table] = (int) $db->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
        } catch (\PDOException $e) {
            $counts[$table] = null;
        }
    }

    $sites = $counts['core_sites'] ?? 0;

    return [
        'status'      => $sites >= 1 ? 'ok' : 'warning',
        'time'        => date('Y-m-d H:i:s'),
        'database'    => DB_NAME,
        'sites_count' => $sites,
        'tables'      => $counts,
        'run_url'     => '/api/health/insert/run?key=VOTRE_INSERT_TEST_KEY',
        'hint'        => $sites < 1
            ? 'Importez bdd_nexytal_inserts.sql dans ' . DB_NAME
            : ($afterRun ? 'Smoke INSERT terminé' : 'GET run ou POST avec clé INSERT_TEST_KEY pour tester les INSERT'),
    ];
}

function runInsertSmokeTests(): array
{
    $db = getDb();
    $suffix = substr(bin2hex(random_bytes(4)), 0, 8);
    $results = [];
    $ctx = [];

    $ok = function (string $table, ?int $id = null, ?string $detail = null) use (&$results) {
        $results[] = ['table' => $table, 'ok' => true, 'id' => $id, 'detail' => $detail];
    };
    $ko = function (string $table, string $error) use (&$results) {
        $results[] = ['table' => $table, 'ok' => false, 'error' => $error];
    };

    // ── 1. formation_categories ─────────────────────────────────────────────
    try {
        $slug = "health-cat-$suffix";
        $stmt = $db->prepare(
            'INSERT INTO formation_categories (site_id, name, slug, is_active, created_at)
             VALUES (1, :name, :slug, 1, NOW())'
        );
        $name = "Health cat $suffix";
        $stmt->execute([':name' => $name, ':slug' => $slug]);
        $ctx['formCatId'] = (int) $db->lastInsertId();
        $ok('formation_categories', $ctx['formCatId']);
    } catch (\Throwable $e) {
        $ko('formation_categories', $e->getMessage());
    }

    // ── 2. formation_courses ──────────────────────────────────────────────────
    if (!empty($ctx['formCatId'])) {
        try {
            $slug = "health-form-$suffix";
            $stmt = $db->prepare(
                'INSERT INTO formation_courses
                 (site_id, category_id, title, slug, presentation_text, status, created_at)
                 VALUES (1, :cat, :title, :slug, :pres, :status, NOW())'
            );
            $stmt->execute([
                ':cat'    => $ctx['formCatId'],
                ':title'  => "Health formation $suffix",
                ':slug'   => $slug,
                ':pres'   => 'Test insertion health',
                ':status' => 'draft',
            ]);
            $ctx['courseId'] = (int) $db->lastInsertId();
            $ok('formation_courses', $ctx['courseId']);

            $stmtM = $db->prepare(
                'INSERT INTO formation_modules (course_id, title, sort_order, created_at) VALUES (:cid, :tit, 0, NOW())'
            );
            $stmtM->execute([':cid' => $ctx['courseId'], ':tit' => 'Module test']);
            $ok('formation_modules', (int) $db->lastInsertId(), 'inclus');
        } catch (\Throwable $e) {
            $ko('formation_courses', $e->getMessage());
        }
    } else {
        $ko('formation_courses', 'catégorie manquante');
    }

    // ── 3. coaching (ville + coach) ─────────────────────────────────────────
    try {
        $slug = "health-ville-$suffix";
        $stmt = $db->prepare('INSERT INTO coaching_cities (name, slug, created_at) VALUES (:n, :s, NOW())');
        $stmt->execute([':n' => "Ville $suffix", ':s' => $slug]);
        $ctx['cityId'] = (int) $db->lastInsertId();
        $ok('coaching_cities', $ctx['cityId']);
    } catch (\Throwable $e) {
        $ko('coaching_cities', $e->getMessage());
    }

    try {
        $slug = "health-spec-$suffix";
        $stmt = $db->prepare('INSERT INTO coaching_specialties (name, slug, icon, created_at) VALUES (:n, :s, :i, NOW())');
        $stmt->execute([':n' => "Spec $suffix", ':s' => $slug, ':i' => 'star']);
        $ctx['specId'] = (int) $db->lastInsertId();
        $ok('coaching_specialties', $ctx['specId']);
    } catch (\Throwable $e) {
        $ko('coaching_specialties', $e->getMessage());
    }

    if (!empty($ctx['cityId'])) {
        try {
            $slug = "health-coach-$suffix";
            $stmt = $db->prepare(
                'INSERT INTO coaching_coaches
                 (site_id, first_name, last_name, slug, email, title, city_id, status, is_available, created_at)
                 VALUES (6, :fn, :ln, :slug, :email, :title, :city, :status, 1, NOW())'
            );
            $stmt->execute([
                ':fn'     => 'Health',
                ':ln'     => "Coach $suffix",
                ':slug'   => $slug,
                ':email'  => "health.coach.$suffix@test.com",
                ':title'  => 'Coach test health',
                ':city'   => $ctx['cityId'],
                ':status' => 'active',
            ]);
            $ctx['coachId'] = (int) $db->lastInsertId();
            $ok('coaching_coaches', $ctx['coachId']);

            if (!empty($ctx['specId'])) {
                $db->prepare('INSERT INTO coaching_coach_specialties (coach_id, specialty_id) VALUES (?, ?)')
                    ->execute([$ctx['coachId'], $ctx['specId']]);
                $ok('coaching_coach_specialties', null, 'pivot OK');
            }
        } catch (\Throwable $e) {
            $ko('coaching_coaches', $e->getMessage());
        }
    } else {
        $ko('coaching_coaches', 'ville manquante');
    }

    // ── 4. marketing_newsletter_subs ────────────────────────────────────────
    try {
        $token = bin2hex(random_bytes(32));
        $stmt = $db->prepare(
            'INSERT INTO marketing_newsletter_subs (site_id, email, first_name, is_active, unsub_token, created_at)
             VALUES (1, :email, :fn, 1, :token, NOW())'
        );
        $stmt->execute([
            ':email' => "health.nl.$suffix@test.com",
            ':fn'    => 'Test',
            ':token' => $token,
        ]);
        $ok('marketing_newsletter_subs', (int) $db->lastInsertId());
    } catch (\Throwable $e) {
        $ko('marketing_newsletter_subs', $e->getMessage());
    }

    // ── 5. gdpr_deletion_requests ───────────────────────────────────────────
    try {
        $stmt = $db->prepare(
            'INSERT INTO gdpr_deletion_requests
             (site_id, user_type, user_email, request_type, reason, status, created_at)
             VALUES (4, :utype, :email, :rtype, :reason, :status, NOW())'
        );
        $stmt->execute([
            ':utype'  => 'other',
            ':email'  => "health.gdpr.$suffix@test.com",
            ':rtype'  => 'data_deletion',
            ':reason' => 'Health insert test',
            ':status' => 'pending',
        ]);
        $ok('gdpr_deletion_requests', (int) $db->lastInsertId());
    } catch (\Throwable $e) {
        $ko('gdpr_deletion_requests', $e->getMessage());
    }

    // ── 6. coaching_diagnostic_requests ─────────────────────────────────────
    try {
        $stmt = $db->prepare(
            'INSERT INTO coaching_diagnostic_requests
             (coach_id, first_name, last_name, email, coaching_type, message, status, created_at)
             VALUES (:cid, :fn, :ln, :email, :ctype, :msg, :status, NOW())'
        );
        $coachId = $ctx['coachId'] ?? null;
        $stmt->bindValue(':cid', $coachId, $coachId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->execute([
            ':fn'     => 'Diag',
            ':ln'     => "Test $suffix",
            ':email'  => "health.diag.$suffix@test.com",
            ':ctype'  => 'leadership',
            ':msg'    => 'Health insert test',
            ':status' => 'new',
        ]);
        $ok('coaching_diagnostic_requests', (int) $db->lastInsertId());
    } catch (\Throwable $e) {
        $ko('coaching_diagnostic_requests', $e->getMessage());
    }

    // ── 7. seo_metadata ─────────────────────────────────────────────────────
    if (!empty($ctx['courseId'])) {
        try {
            $stmt = $db->prepare(
                'INSERT INTO seo_metadata
                 (site_id, entity_type, entity_id, canonical_url, og_title, created_at)
                 VALUES (1, :type, :eid, :url, :og, NOW())'
            );
            $stmt->execute([
                ':type' => 'formation_course',
                ':eid'  => $ctx['courseId'],
                ':url'  => "https://alt-formation.fr/health-$suffix",
                ':og'   => "SEO health $suffix",
            ]);
            $ok('seo_metadata', (int) $db->lastInsertId());
        } catch (\Throwable $e) {
            $ko('seo_metadata', $e->getMessage());
        }
    } else {
        $ko('seo_metadata', 'formation manquante');
    }

    // ── 8. coaching_bookings ────────────────────────────────────────────────
    if (!empty($ctx['coachId'])) {
        try {
            $stmt = $db->prepare(
                'INSERT INTO coaching_bookings
                 (coach_id, first_name, last_name, email, booked_for, status, created_at)
                 VALUES (:cid, :fn, :ln, :email, :booked, :status, NOW())'
            );
            $stmt->execute([
                ':cid'    => $ctx['coachId'],
                ':fn'     => 'Client',
                ':ln'     => "Health $suffix",
                ':email'  => "health.book.$suffix@test.com",
                ':booked' => date('Y-m-d H:i:s', strtotime('+30 days')),
                ':status' => 'pending',
            ]);
            $ok('coaching_bookings', (int) $db->lastInsertId());
        } catch (\Throwable $e) {
            $ko('coaching_bookings', $e->getMessage());
        }
    } else {
        $ko('coaching_bookings', 'coach manquant');
    }

    $passed = count(array_filter($results, fn ($r) => $r['ok']));
    $failed = count($results) - $passed;

    $status = buildInsertHealthStatus(true);

    return [
        'status'   => $failed === 0 ? 'ok' : 'error',
        'suffix'   => $suffix,
        'summary'  => ['ok' => $passed, 'failed' => $failed, 'total' => count($results)],
        'results'  => $results,
        'ids'      => $ctx,
        'tables'   => $status['tables'],
        'time'     => date('Y-m-d H:i:s'),
    ];
}
