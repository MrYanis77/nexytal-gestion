<?php
/**
 * core/RateLimit.php — Anti brute-force via core_admin_activity_logs
 * Aligné sur le schéma Ionos (bdd_nexytal).
 */

class RateLimit
{
    public static function check(string $action = 'login_failed'): void
    {
        $ip = self::getClientIp();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT COUNT(*) as attempts 
             FROM core_admin_activity_logs 
             WHERE ip_address = :ip 
               AND action = :action 
               AND created_at >= DATE_SUB(NOW(), INTERVAL :window MINUTE)'
        );
        $stmt->bindParam(':ip', $ip, PDO::PARAM_STR);
        $stmt->bindParam(':action', $action, PDO::PARAM_STR);
        $window = RATE_LIMIT_WINDOW_MINUTES;
        $stmt->bindParam(':window', $window, PDO::PARAM_INT);
        $stmt->execute();

        $result = $stmt->fetch();

        if ($result && (int) $result['attempts'] >= RATE_LIMIT_MAX_ATTEMPTS) {
            Response::tooManyRequests(
                sprintf('Too many failed attempts. Please try again in %d minutes.', RATE_LIMIT_WINDOW_MINUTES)
            );
            exit;
        }
    }

    /**
     * @param int|null $adminId Requis par le schéma Ionos (NOT NULL) — ignoré si null
     */
    public static function logAttempt(
        string $action,
        ?int $adminId = null,
        ?string $resource = 'auth',
        ?int $sessionId = null
    ): void {
        if ($adminId === null) {
            return;
        }

        try {
            $ip = self::getClientIp();
            $db = getDb();

            $stmt = $db->prepare(
                'INSERT INTO core_admin_activity_logs 
                 (admin_id, session_id, action, resource, ip_address, created_at) 
                 VALUES (:admin_id, :session_id, :action, :resource, :ip, NOW())'
            );
            $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindParam(':session_id', $sessionId, PDO::PARAM_INT);
            $stmt->bindParam(':action', $action, PDO::PARAM_STR);
            $stmt->bindParam(':resource', $resource, PDO::PARAM_STR);
            $stmt->bindParam(':ip', $ip, PDO::PARAM_STR);
            $stmt->execute();
        } catch (\Exception $e) {
            if (APP_ENV === 'development') {
                error_log('RateLimit log error: ' . $e->getMessage());
            }
        }
    }

    public static function getClientIp(): string
    {
        $headers = [
            'HTTP_CF_CONNECTING_IP',
            'HTTP_X_REAL_IP',
            'HTTP_X_FORWARDED_FOR',
            'REMOTE_ADDR',
        ];

        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ip = trim(explode(',', $_SERVER[$header])[0]);
                if (filter_var($ip, FILTER_VALIDATE_IP)) {
                    return $ip;
                }
            }
        }

        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }
}
