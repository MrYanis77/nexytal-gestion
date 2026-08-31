<?php
/**
 * index.php — Point d'entrée unique (front controller) — Backend Nexytal
 * 
 * Charge la configuration, gère CORS, initialise le routeur,
 * enregistre toutes les routes et dispatche la requête.
 */

// ===== ERROR REPORTING =====
error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');

// ===== CHARGEMENT DES FICHIERS CORE =====
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/core/Response.php';
require_once __DIR__ . '/core/Router.php';
require_once __DIR__ . '/core/Auth.php';
require_once __DIR__ . '/core/Middleware.php';
require_once __DIR__ . '/core/RateLimit.php';
require_once __DIR__ . '/core/Audit.php';
require_once __DIR__ . '/core/Validator.php';
require_once __DIR__ . '/core/UploadDiskSpace.php';
require_once __DIR__ . '/core/UploadUrl.php';
require_once __DIR__ . '/core/Upload.php';
require_once __DIR__ . '/core/AdminSession.php';
require_once __DIR__ . '/core/RecruteurAuth.php';
require_once __DIR__ . '/core/ProductionSecurity.php';

ProductionSecurity::assertBootConfig();

// ===== AFFICHAGE ERREURS EN DEV =====
if (APP_ENV === 'development') {
    ini_set('display_errors', '1');
}

// ===== GESTION CORS =====
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if (in_array($origin, ALLOWED_ORIGINS, true)) {
    header("Access-Control-Allow-Origin: $origin");
    header('Access-Control-Allow-Credentials: true');
} else if (APP_ENV === 'development') {
    // En dev, restreindre aux origines localhost uniquement
    $devOrigins = ['http://localhost:3000', 'http://localhost:5173', 'http://127.0.0.1:3000', 'http://127.0.0.1:5173'];
    if (in_array($origin, $devOrigins, true)) {
        header("Access-Control-Allow-Origin: $origin");
        header('Access-Control-Allow-Credentials: true');
    } elseif ($origin === '') {
        // Requêtes sans origin (curl, postman) en dev
        header('Access-Control-Allow-Origin: http://localhost:3000');
    }
}

header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Site-Id, X-Requested-With, X-CSRF-Token');
header('Access-Control-Max-Age: 86400');

// ===== PREFLIGHT OPTIONS =====
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ===== HEADERS SÉCURITÉ =====
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Permissions-Policy: geolocation=(), camera=(), microphone=()");
if (APP_ENV === 'production') {
    header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' https: data:; font-src 'self' https:; connect-src 'self'");
}


// ===== INITIALISATION DU ROUTEUR =====
$router = new Router();

// ===== ROUTE HEALTH CHECK =====
$router->get('/api/health', function () {
    Response::success([
        'status'  => 'ok',
        'version' => '1.0.0',
        'time'    => date('Y-m-d H:i:s'),
    ]);
});

$router->get('/api/health/db', function () {
    ProductionSecurity::assertDiagnosticsAllowed();
    $result = testDbConnection();

    if ($result['connected']) {
        Response::success([
            'status'          => 'ok',
            'connected'       => true,
            'host'            => $result['host'],
            'database'        => $result['database'],
            'user'            => $result['user'],
            'config_sources'  => $result['config_sources'] ?? null,
        ]);
    }

    $payload = [
        'status'         => 'error',
        'connected'      => false,
        'host'           => $result['host'],
        'database'       => $result['database'],
        'user'           => $result['user'],
        'config_sources' => $result['config_sources'] ?? null,
        'hint'           => 'Vérifiez DB_PASSWORD dans api/config/.env (Ionos → Bases de données → réinitialiser dbu977482)',
    ];

    if (!empty($result['detail'])) {
        $payload['detail'] = $result['detail'];
    }

    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'data' => $payload]);
    exit;
});

require_once __DIR__ . '/modules/health/insert_tests.php';
registerHealthInsertRoutes($router);

// ===== ENREGISTREMENT DES ROUTES =====

// --- Module Auth ---
require_once __DIR__ . '/modules/auth/login.php';
require_once __DIR__ . '/modules/auth/logout.php';
require_once __DIR__ . '/modules/auth/me.php';
require_once __DIR__ . '/modules/auth/password_reset_request.php';
require_once __DIR__ . '/modules/auth/password_reset_confirm.php';
registerAuthLoginRoutes($router);
registerAuthLogoutRoutes($router);
registerAuthMeRoutes($router);
registerPasswordResetRequestRoutes($router);
registerPasswordResetConfirmRoutes($router);

// --- Module Users ---
require_once __DIR__ . '/modules/users/users.php';
registerUsersRoutes($router);

// --- Module Blog (bdd.sql : pas de blog_comments) ---
require_once __DIR__ . '/modules/blog/categories.php';
require_once __DIR__ . '/modules/blog/tags.php';
require_once __DIR__ . '/modules/blog/authors.php';
require_once __DIR__ . '/modules/blog/posts.php';
require_once __DIR__ . '/modules/blog/public_blog.php';
require_once __DIR__ . '/modules/blog/comments.php';
registerBlogCategoriesRoutes($router);
registerBlogTagsRoutes($router);
registerBlogAuthorsRoutes($router);
registerBlogPostsRoutes($router);
registerPublicBlogRoutes($router);
registerBlogCommentsRoutes($router);

// --- Module Recrutement ---
require_once __DIR__ . '/modules/recrutement/sectors.php';
require_once __DIR__ . '/modules/recrutement/entreprises.php';
require_once __DIR__ . '/modules/recrutement/recruteurs.php';
require_once __DIR__ . '/modules/recrutement/candidats.php';
require_once __DIR__ . '/modules/recrutement/competences.php';
require_once __DIR__ . '/modules/recrutement/users.php';
require_once __DIR__ . '/modules/recrutement/externes.php';
require_once __DIR__ . '/modules/recrutement/villes.php';
require_once __DIR__ . '/modules/recrutement/alertes.php';
require_once __DIR__ . '/modules/recrutement/favorites.php';
require_once __DIR__ . '/modules/recrutement/jobs.php';
require_once __DIR__ . '/modules/recrutement/offers.php';
require_once __DIR__ . '/modules/recrutement/applications.php';
require_once __DIR__ . '/modules/recrutement/public_recrutement.php';
require_once __DIR__ . '/modules/recrutement/public_medical.php';
require_once __DIR__ . '/modules/recrutement/public_offers.php';
require_once __DIR__ . '/modules/recrutement/scoring.php';
require_once __DIR__ . '/modules/recrutement/scoring_config.php';
require_once __DIR__ . '/modules/recrutement/stats.php';
require_once __DIR__ . '/modules/recrutement/demandes_urgentes.php';
require_once __DIR__ . '/modules/recrutement/api_aliases.php';
require_once __DIR__ . '/modules/recrutement/recruteur_portal.php';
registerRecrutementSectorsRoutes($router);
registerRecrutementEntreprisesRoutes($router);
registerRecrutementRecruteursRoutes($router);
registerRecrutementCandidatsRoutes($router);
registerRecrutementCompetencesRoutes($router);
registerRecrutementVillesRoutes($router);
registerRecrutementUsersRoutes($router);
registerRecrutementExternesRoutes($router);
registerRecrutementAlertesRoutes($router);
registerRecrutementFavoritesRoutes($router);
registerRecrutementJobsRoutes($router);
registerRecrutementOffersRoutes($router);
registerRecrutementApplicationsRoutes($router);
registerPublicRecrutementRoutes($router);
registerPublicMedicalRoutes($router);
registerPublicOffersRoutes($router);
registerRecrutementStatsRoutes($router);
registerRecrutementScoringConfigRoutes($router);
registerRecrutementApiAliasesRoutes($router);
registerRecruteurPortalRoutes($router);

// --- Module Coaching (coaches, référentiels, demandes, API publique) ---
require_once __DIR__ . '/modules/coaching/coaches.php';
require_once __DIR__ . '/modules/coaching/reference_data.php';
require_once __DIR__ . '/modules/coaching/requests.php';
require_once __DIR__ . '/modules/coaching/public_coaching.php';
registerCoachingCoachesRoutes($router);
registerCoachingSpecialtiesRoutes($router);
registerCoachingCertificationsRoutes($router);
registerCoachingCitiesRoutes($router);
registerCoachingLanguagesRoutes($router);
registerCoachingContactSlotsRoutes($router);
registerCoachingAppointmentSlotsRoutes($router);
registerCoachingRequestsRoutes($router);
registerPublicCoachingRoutes($router);

// --- Module Trainer (formateurs, référentiels, API publique) ---
require_once __DIR__ . '/modules/trainer/trainers.php';
require_once __DIR__ . '/modules/trainer/expertises.php';
require_once __DIR__ . '/modules/trainer/reference_data.php';
require_once __DIR__ . '/modules/trainer/public_trainer.php';
registerTrainerTrainersRoutes($router);
registerTrainerExpertisesRoutes($router);
registerTrainerSkillsRoutes($router);
registerTrainerCitiesRoutes($router);
registerTrainerCertificationsRoutes($router);
registerTrainerLanguagesRoutes($router);
registerTrainerReviewsRoutes($router);
registerPublicTrainerRoutes($router);

// --- Module Formation (catalogue, tarifs, carrières internes, API publique) ---
require_once __DIR__ . '/modules/formation/formation_schema.php';
require_once __DIR__ . '/modules/formation/courses.php';
require_once __DIR__ . '/modules/formation/categories.php';
require_once __DIR__ . '/modules/formation/pricing.php';
require_once __DIR__ . '/modules/formation/career_offers.php';
require_once __DIR__ . '/modules/formation/career_applications.php';
require_once __DIR__ . '/modules/formation/public_formation.php';
registerFormationCoursesRoutes($router);
registerFormationCategoriesRoutes($router);
registerFormationPricingRoutes($router);
registerFormationCareerOffersRoutes($router);
registerFormationCareerApplicationsRoutes($router);
registerPublicFormationRoutes($router);

// Diagnostic catalogue (production) — GET /api/health/formation-diag?key=INSERT_TEST_KEY
$router->get('/api/health/formation-diag', function () {
    $key = $_GET['key'] ?? '';
    $expected = defined('INSERT_TEST_KEY') ? (string) INSERT_TEST_KEY : '';
    if ($expected === '' || !hash_equals($expected, (string) $key)) {
        Response::notFound('Not found');
        return;
    }

    $db = getDb();
    $report = [
        'api_version' => 'v4',
        'uses_courses_table' => formationUsesCoursesTable($db),
        'formation_courses_exists' => formationTableExists($db, 'formation_courses'),
        'formations_legacy_exists' => formationTableExists($db, 'formations'),
        'steps' => [],
    ];

    $step = static function (string $label, callable $fn) use (&$report): void {
        try {
            $report['steps'][] = ['step' => $label, 'ok' => true, 'detail' => $fn()];
        } catch (Throwable $e) {
            $report['steps'][] = ['step' => $label, 'ok' => false, 'error' => $e->getMessage()];
        }
    };

    if (formationTableExists($db, 'formation_courses')) {
        $step('count formation_courses', function () use ($db) {
            return (int) $db->query('SELECT COUNT(*) FROM formation_courses WHERE site_id = 1')->fetchColumn();
        });
    }
    if (formationTableExists($db, 'formations')) {
        $step('count formations legacy', function () use ($db) {
            return (int) $db->query('SELECT COUNT(*) FROM formations WHERE site_id = 1')->fetchColumn();
        });
    }
    $step('formationListCourses', function () use ($db) {
        [$rows, $total] = formationListCourses($db, ['page' => 1, 'limit' => 3, 'offset' => 0], 1);
        return ['total' => $total, 'ids' => array_column($rows, 'id')];
    });

    $failed = array_filter($report['steps'], static fn ($s) => !$s['ok']);
    Response::json($report, $failed === [] ? 200 : 500);
});

// --- Module Marketing (bdd.sql : newsletter_lists, newsletter_subscribers, newsletter_subscriptions) ---
require_once __DIR__ . '/modules/marketing/newsletter.php';
require_once __DIR__ . '/modules/marketing/newsletter_extended.php';
require_once __DIR__ . '/modules/marketing/email_logs.php';
registerMarketingNewsletterRoutes($router);
registerMarketingNewsletterExtendedRoutes($router);
registerMarketingEmailLogsRoutes($router);

// --- Module GDPR (bdd.sql : gdpr_consents_log uniquement) ---
require_once __DIR__ . '/modules/gdpr/consents.php';
require_once __DIR__ . '/modules/gdpr/deletion_requests.php';
registerGdprConsentsRoutes($router);
registerGdprDeletionRequestsRoutes($router);

// --- Module SEO ---
require_once __DIR__ . '/modules/seo/seo.php';
registerSeoRoutes($router);

// --- Module Media (uploads) ---
require_once __DIR__ . '/modules/media/media.php';
registerMediaRoutes($router);

// --- Logs & exports serveur ---
require_once __DIR__ . '/modules/log_exports/logs.php';
registerLogsRoutes($router);

// --- Paramètres : export / import ---
require_once __DIR__ . '/modules/settings/data_portability.php';
registerDataPortabilityRoutes($router);

// --- Plans tarifaires par site (site_pricing_plans) ---
require_once __DIR__ . '/modules/settings/pricing_plans.php';
registerPricingPlansRoutes($router);

// ===== DISPATCH =====
try {
    $router->dispatch();
} catch (\PDOException $e) {
    Response::serverError('Database error', $e->getMessage());
} catch (\Exception $e) {
    Response::serverError('Server error', $e->getMessage());
}
