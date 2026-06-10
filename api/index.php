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
require_once __DIR__ . '/core/Upload.php';

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
    // En dev, autoriser toutes les origines
    header('Access-Control-Allow-Origin: *');
}

header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Site-Id, X-Requested-With');
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
        'hint'           => 'Vérifiez DB_HOST, DB_NAME, DB_USER, DB_PASS dans api/config/.env ou config.local.php',
    ];

    if (!empty($result['detail'])) {
        $payload['detail'] = $result['detail'];
    }

    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'data' => $payload]);
    exit;
});

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

// --- Module Blog ---
require_once __DIR__ . '/modules/blog/categories.php';
require_once __DIR__ . '/modules/blog/tags.php';
require_once __DIR__ . '/modules/blog/authors.php';
require_once __DIR__ . '/modules/blog/posts.php';
require_once __DIR__ . '/modules/blog/comments.php';
require_once __DIR__ . '/modules/blog/public_blog.php';
registerBlogCategoriesRoutes($router);
registerBlogTagsRoutes($router);
registerBlogAuthorsRoutes($router);
registerBlogPostsRoutes($router);
registerBlogCommentsRoutes($router);
registerPublicBlogRoutes($router);

// --- Module Recrutement ---
require_once __DIR__ . '/modules/recrutement/sectors.php';
require_once __DIR__ . '/modules/recrutement/jobs.php';
require_once __DIR__ . '/modules/recrutement/contract_types.php';
require_once __DIR__ . '/modules/recrutement/professions.php';
require_once __DIR__ . '/modules/recrutement/offers.php';
require_once __DIR__ . '/modules/recrutement/tags.php';
require_once __DIR__ . '/modules/recrutement/applications.php';
require_once __DIR__ . '/modules/recrutement/public_recrutement.php';
require_once __DIR__ . '/modules/recrutement/public_medical.php';
registerRecrutementSectorsRoutes($router);
registerRecrutementJobsRoutes($router);
registerRecrutementContractTypesRoutes($router);
registerRecrutementProfessionsRoutes($router);
registerRecrutementOffersRoutes($router);
registerRecrutementTagsRoutes($router);
registerRecrutementApplicationsRoutes($router);
registerPublicRecrutementRoutes($router);
registerPublicMedicalRoutes($router);

// --- Module Formation ---
require_once __DIR__ . '/modules/formation/categories.php';
require_once __DIR__ . '/modules/formation/courses.php';
require_once __DIR__ . '/modules/formation/public_formation.php';
registerFormationCategoriesRoutes($router);
registerFormationCoursesRoutes($router);
registerPublicFormationRoutes($router);

// --- Module Coaching ---
require_once __DIR__ . '/modules/coaching/cities.php';
require_once __DIR__ . '/modules/coaching/specialties.php';
require_once __DIR__ . '/modules/coaching/certifications.php';
require_once __DIR__ . '/modules/coaching/coaches.php';
require_once __DIR__ . '/modules/coaching/reviews.php';
require_once __DIR__ . '/modules/coaching/bookings.php';
require_once __DIR__ . '/modules/coaching/diagnostics.php';
require_once __DIR__ . '/modules/coaching/public_coaching.php';
registerCoachingCitiesRoutes($router);
registerCoachingSpecialtiesRoutes($router);
registerCoachingCertificationsRoutes($router);
registerCoachingCoachesRoutes($router);
registerCoachingReviewsRoutes($router);
registerCoachingBookingsRoutes($router);
registerCoachingDiagnosticsRoutes($router);
registerPublicCoachingRoutes($router);

// --- Module Marketing ---
require_once __DIR__ . '/modules/marketing/newsletter.php';
require_once __DIR__ . '/modules/marketing/email_logs.php';
registerMarketingNewsletterRoutes($router);
registerMarketingEmailLogsRoutes($router);

// --- Module GDPR ---
require_once __DIR__ . '/modules/gdpr/consents.php';
require_once __DIR__ . '/modules/gdpr/deletion_requests.php';
registerGdprConsentsRoutes($router);
registerGdprDeletionRequestsRoutes($router);

// --- Module Media ---
require_once __DIR__ . '/modules/media/media.php';
registerMediaRoutes($router);

// --- Module SEO ---
require_once __DIR__ . '/modules/seo/seo.php';
registerSeoRoutes($router);

// ===== DISPATCH =====
try {
    $router->dispatch();
} catch (\PDOException $e) {
    Response::serverError('Database error', $e->getMessage());
} catch (\Exception $e) {
    Response::serverError('Server error', $e->getMessage());
}
