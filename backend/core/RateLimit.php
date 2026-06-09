<?php
/**
 * core/RateLimit.php — Anti brute-force via core_admin_activity_logs
 * 
 * Compte les tentatives échouées par IP dans une fenêtre de temps.
 * Bloque après RATE_LIMIT_MAX_ATTEMPTS tentatives en RATE_LIMIT_WINDOW_MINUTES minutes.
 */

class RateLimit
{
    /**
     * Vérifie si l'IP est bloquée pour une action donnée.
     * Si bloquée, envoie une réponse 429 et arrête l'exécution.
     * 
     * @param string $action Action concernée (ex: 'login_failed')
     */
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
     * Enregistre une tentative dans core_admin_activity_logs
     * 
     * @param string $action Action (ex: 'login_failed', 'login_success')
     * @param int|null $adminId ID admin si connu
     * @param string|null $resource Ressource concernée (ex: 'auth')
     * @param int|null $sessionId ID de session si existant
     */
    public static function logAttempt(
        string $action,
        ?int $adminId = null,
        ?string $resource = 'auth',
        ?int $sessionId = null
    ): void {
        $ip = self::getClientIp();
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        $db = getDb();

        $stmt = $db->prepare(
            'INSERT INTO core_admin_activity_logs 
             (admin_id, session_id, action, resource, ip_address, user_agent, created_at) 
             VALUES (:admin_id, :session_id, :action, :resource, :ip, :user_agent, NOW())'
        );
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->bindParam(':session_id', $sessionId, PDO::PARAM_INT);
        $stmt->bindParam(':action', $action, PDO::PARAM_STR);
        $stmt->bindParam(':resource', $resource, PDO::PARAM_STR);
        $stmt->bindParam(':ip', $ip, PDO::PARAM_STR);
        $stmt->bindParam(':user_agent', $userAgent, PDO::PARAM_STR);
        $stmt->execute();
    }

    /**
     * Récupère l'adresse IP du client
     * Gère les proxys (X-Forwarded-For)
     */
    public static function getClientIp(): string
    {
        // Vérifier les headers proxy dans l'ordre de confiance
        $headers = [
            'HTTP_CF_CONNECTING_IP',   // Cloudflare
            'HTTP_X_REAL_IP',          // Nginx proxy
            'HTTP_X_FORWARDED_FOR',    // Proxy standard
            'REMOTE_ADDR',             // Direct
        ];

        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                // X-Forwarded-For peut contenir plusieurs IPs (client, proxy1, proxy2)
                $ip = trim(explode(',', $_SERVER[$header])[0]);
                if (filter_var($ip, FILTER_VALIDATE_IP)) {
                    return $ip;
                }
            }
        }

        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }
}
