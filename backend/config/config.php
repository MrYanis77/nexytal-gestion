<?php
/**
 * config/config.php — Configuration globale Nexytal Backend
 * 
 * Variables de connexion BDD, JWT, uploads, CORS, environnement.
 * Ce fichier ne doit JAMAIS être accessible publiquement (.htaccess le bloque).
 */

// ===== BASE DE DONNÉES =====
define('DB_HOST', 'db5020658636.hosting-data.io');
define('DB_PORT', 3306);
define('DB_NAME', 'dbu12345678');
define('DB_USER', 'dbs15772578');
define('DB_PASS', 'Nexytal@!77');
define('DB_CHARSET', 'utf8mb4');

// ===== JWT =====
define('JWT_SECRET', 'NxYt4L_S3cr3t_K3y_2024_Ch4ng3_Th1s_T0_A_64_Ch4r_R4nd0m_Str1ng_Pl34s3!!');
define('JWT_EXPIRY', 86400); // 24h en secondes
define('JWT_ISSUER', 'nexytal-backend');

// ===== UPLOADS =====
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('UPLOAD_URL', '/uploads/');
define('UPLOAD_MAX_SIZE', 5 * 1024 * 1024); // 5 Mo

// ===== CORS — Domaines autorisés =====
define('ALLOWED_ORIGINS', [
    'https://alt-formation.fr',
    'https://recrutement.nexytal.com',
    'https://medical.nexytal.com',
    'https://carriere.nexytal.com',
    'https://trainer.nexytal.com',
    'https://coaching.nexytal.com',
    'http://localhost:5173',  // Dev local Vite
    'http://localhost:3000',  // Dev local alternatif
]);

// ===== ENVIRONNEMENT =====
define('APP_ENV', 'production'); // 'development' ou 'production'

// ===== RATE LIMITING =====
define('RATE_LIMIT_MAX_ATTEMPTS', 5);
define('RATE_LIMIT_WINDOW_MINUTES', 15);

// ===== PAGINATION PAR DÉFAUT =====
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);
