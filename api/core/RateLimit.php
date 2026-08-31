<?php
/**
 * core/RateLimit.php — Anti brute-force via core_admin_activity_logs
 * Aligné sur le schéma Ionos (bdd_nexytal).
 */

class RateLimit
{
    public static function check(string $action = 'login_failed'): void
    {
        try {
            $ip = self::getClientIp();
            $db = getDb();

            $stmt = $db->prepare(
                'SELECT COUNT(*) as attempts 
                 FROM core_audit_logs 
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
        } catch (\Throwable $e) {
            if (APP_ENV === 'development') {
                error_log('RateLimit check skipped: ' . $e->getMessage());
            }
        }
    }

    public static function logAttempt(
        string $action,
        ?int $adminId = null,
        ?string $resource = 'auth',
        ?string $sessionId = null
    ): void {
        try {
            $ip = self::getClientIp();
            $db = getDb();

            $stmt = $db->prepare(
                'INSERT INTO core_audit_logs 
                 (admin_id, action, entity_type, ip_address, created_at) 
                 VALUES (:admin_id, :action, :resource, :ip, NOW())'
            );
            $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindValue(':action', $action, PDO::PARAM_STR);
            $stmt->bindValue(':resource', $resource, PDO::PARAM_STR);
            $stmt->bindValue(':ip', $ip, PDO::PARAM_STR);
            $stmt->execute();
        } catch (\Exception $e) {
            if (APP_ENV === 'development') {
                error_log('RateLimit log error: ' . $e->getMessage());
            }
        }
    }

    public static function getClientIp(): string
    {
        $remoteAddr = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

        // Only trust proxy headers if the request comes from a known proxy
        $trustedProxies = array_filter(
            array_map('trim', explode(',', (string) env('TRUSTED_PROXIES', '127.0.0.1,::1'))),
            fn($v) => $v !== ''
        );

        $isTrustedProxy = in_array($remoteAddr, $trustedProxies, true);

        if ($isTrustedProxy) {
            $headers = [
                'HTTP_CF_CONNECTING_IP',
                'HTTP_X_REAL_IP',
                'HTTP_X_FORWARDED_FOR',
            ];

            foreach ($headers as $header) {
                if (!empty($_SERVER[$header])) {
                    $ip = trim(explode(',', $_SERVER[$header])[0]);
                    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                        return $ip;
                    }
                }
            }
        }

        return filter_var($remoteAddr, FILTER_VALIDATE_IP) ? $remoteAddr : '0.0.0.0';
    }
}
