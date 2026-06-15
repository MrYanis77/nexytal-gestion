<?php
/**
 * ProductionSecurity — Garde-fous configuration en environnement production.
 */

class ProductionSecurity
{
    public const DEFAULT_JWT_SECRET = 'NxYt4L_S3cr3t_K3y_2024_Ch4ng3_Th1s_T0_A_64_Ch4r_R4nd0m_Str1ng_Pl34s3!!';
    public const DEFAULT_INSERT_TEST_KEY = 'nexytal-insert-test';

    /**
     * Bloque le démarrage de l'API si JWT_SECRET par défaut ou trop court en production.
     */
    public static function assertBootConfig(): void
    {
        if (!defined('APP_ENV') || APP_ENV !== 'production') {
            return;
        }

        if (!defined('JWT_SECRET')
            || JWT_SECRET === self::DEFAULT_JWT_SECRET
            || strlen(JWT_SECRET) < 32
        ) {
            self::failBoot(
                'Server misconfiguration: set a strong JWT_SECRET (32+ chars) in api/config/env on production.'
            );
        }
    }

    /**
     * Endpoints de diagnostic (health/db, health/insert) — interdits en production.
     */
    public static function assertDiagnosticsAllowed(): void
    {
        if (defined('APP_ENV') && APP_ENV === 'production') {
            Response::notFound('Not found');
            exit;
        }
    }

    /**
     * Clé INSERT_TEST_KEY ne doit pas rester sur la valeur par défaut en production.
     */
    public static function assertInsertTestKeyConfigured(): bool
    {
        if (defined('APP_ENV') && APP_ENV === 'production') {
            $key = defined('INSERT_TEST_KEY') ? INSERT_TEST_KEY : '';
            if ($key === '' || $key === self::DEFAULT_INSERT_TEST_KEY) {
                Response::forbidden('INSERT_TEST_KEY must be configured for production diagnostics');
                return false;
            }
        }

        return true;
    }

    private static function failBoot(string $message): void
    {
        http_response_code(503);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error'   => $message,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}
