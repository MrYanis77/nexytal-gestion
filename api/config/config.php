<?php
/**
 * config/config.php — Configuration globale Nexytal Backend
 *
 * Priorité : config.local.php > api/config/.env > valeurs par défaut
 */

require_once __DIR__ . '/load_env.php';

// ===== BASE DE DONNÉES (Ionos) =====
if (!defined('DB_HOST')) {
    define('DB_HOST', env('DB_HOST', 'db5020658636.hosting-data.io'));
}
if (!defined('DB_PORT')) {
    define('DB_PORT', (int) env('DB_PORT', '3306'));
}
if (!defined('DB_NAME')) {
    define('DB_NAME', env('DB_NAME', env('DB_DATABASE', 'dbs15772578')));
}
if (!defined('DB_USER')) {
    define('DB_USER', env('DB_USER', env('DB_USERNAME', 'dbu977482')));
}
if (!defined('DB_PASS')) {
    define('DB_PASS', env('DB_PASSWORD', env('DB_PASS', 'Nexytal@!77')));
}
if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));
}

// ===== JWT =====
if (!defined('JWT_SECRET')) {
    define('JWT_SECRET', env('JWT_SECRET', 'NxYt4L_S3cr3t_K3y_2024_Ch4ng3_Th1s_T0_A_64_Ch4r_R4nd0m_Str1ng_Pl34s3!!'));
}
if (!defined('JWT_EXPIRY')) {
    define('JWT_EXPIRY', (int) env('JWT_EXPIRY', '86400'));
}
if (!defined('JWT_ISSUER')) {
    define('JWT_ISSUER', env('JWT_ISSUER', 'nexytal-backend'));
}

// ===== UPLOADS =====
if (!defined('UPLOAD_DIR')) {
    define('UPLOAD_DIR', __DIR__ . '/../uploads/');
}
if (!defined('UPLOAD_URL')) {
    define('UPLOAD_URL', '/uploads/');
}
if (!defined('UPLOAD_MAX_SIZE')) {
    define('UPLOAD_MAX_SIZE', 5 * 1024 * 1024);
}

// ===== CORS =====
if (!defined('ALLOWED_ORIGINS')) {
    define('ALLOWED_ORIGINS', [
        'https://connexion.nexytal.com',
        'https://alt-formation.fr',
        'https://recrutement.nexytal.com',
        'https://medical.nexytal.com',
        'https://carriere.nexytal.com',
        'https://trainer.nexytal.com',
        'https://coaching.nexytal.com',
        'http://localhost:5173',
        'http://localhost:3000',
    ]);
}

// ===== ENVIRONNEMENT =====
if (!defined('APP_ENV')) {
    define('APP_ENV', env('APP_ENV', 'production'));
}

// ===== RATE LIMITING =====
if (!defined('RATE_LIMIT_MAX_ATTEMPTS')) {
    define('RATE_LIMIT_MAX_ATTEMPTS', (int) env('RATE_LIMIT_MAX_ATTEMPTS', '5'));
}
if (!defined('RATE_LIMIT_WINDOW_MINUTES')) {
    define('RATE_LIMIT_WINDOW_MINUTES', (int) env('RATE_LIMIT_WINDOW_MINUTES', '15'));
}

// ===== PAGINATION =====
if (!defined('DEFAULT_PAGE_SIZE')) {
    define('DEFAULT_PAGE_SIZE', (int) env('DEFAULT_PAGE_SIZE', '20'));
}
if (!defined('MAX_PAGE_SIZE')) {
    define('MAX_PAGE_SIZE', (int) env('MAX_PAGE_SIZE', '100'));
}
