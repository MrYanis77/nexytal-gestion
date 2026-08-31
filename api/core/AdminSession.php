<?php
/**
 * AdminSession — Création / validation / révocation des sessions admin.
 *
 * Compatible schéma v2 (PK id = hash du token) et Ionos prod (id INT + colonne token hashée).
 */

class AdminSession
{
    private static ?bool $hasTokenColumn = null;

    private static function hashToken(string $token): string
    {
        return hash('sha256', $token);
    }

    public static function usesTokenColumn(PDO $db): bool
    {
        if (self::$hasTokenColumn !== null) {
            return self::$hasTokenColumn;
        }

        try {
            $stmt = $db->query("SHOW COLUMNS FROM core_admin_sessions LIKE 'token'");
            self::$hasTokenColumn = (bool) $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (\Throwable $e) {
            self::$hasTokenColumn = false;
        }

        return self::$hasTokenColumn;
    }

    /**
     * Crée une session et retourne le token à inclure dans le JWT (session_id).
     */
    public static function create(
        PDO $db,
        int $adminId,
        string $ip,
        string $userAgent,
        string $expiresAt
    ): string {
        $token = Auth::generateRandomToken(64);

        if (self::usesTokenColumn($db)) {
            $stmt = $db->prepare(
                'INSERT INTO core_admin_sessions (admin_id, token, ip_address, user_agent, expires_at, created_at)
                 VALUES (:admin_id, :token, :ip, :user_agent, :expires_at, NOW())'
            );
            $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindValue(':token', self::hashToken($token), PDO::PARAM_STR);
            $stmt->bindValue(':ip', $ip, PDO::PARAM_STR);
            $stmt->bindValue(':user_agent', $userAgent, PDO::PARAM_STR);
            $stmt->bindValue(':expires_at', $expiresAt, PDO::PARAM_STR);
            $stmt->execute();

            return $token;
        }

        $stmt = $db->prepare(
            'INSERT INTO core_admin_sessions (id, admin_id, ip_address, user_agent, expires_at, created_at)
             VALUES (:id, :admin_id, :ip, :user_agent, :expires_at, NOW())'
        );
        $stmt->bindValue(':id', self::hashToken($token), PDO::PARAM_STR);
        $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->bindValue(':ip', $ip, PDO::PARAM_STR);
        $stmt->bindValue(':user_agent', $userAgent, PDO::PARAM_STR);
        $stmt->bindValue(':expires_at', $expiresAt, PDO::PARAM_STR);
        $stmt->execute();

        return $token;
    }

    public static function isValid(PDO $db, string $sessionToken, int $adminId): bool
    {
        if ($sessionToken === '') {
            return false;
        }

        if (self::usesTokenColumn($db)) {
            $stmt = $db->prepare(
                'SELECT id FROM core_admin_sessions
                 WHERE token IN (:session_hash, :session_id) AND admin_id = :admin_id AND expires_at > NOW()
                 LIMIT 1'
            );
        } else {
            $stmt = $db->prepare(
                'SELECT id FROM core_admin_sessions
                 WHERE id IN (:session_hash, :session_id) AND admin_id = :admin_id AND expires_at > NOW()
                 LIMIT 1'
            );
        }

        $stmt->bindValue(':session_hash', self::hashToken($sessionToken), PDO::PARAM_STR);
        $stmt->bindValue(':session_id', $sessionToken, PDO::PARAM_STR);
        $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();

        return (bool) $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public static function revoke(PDO $db, string $sessionToken, int $adminId): void
    {
        if ($sessionToken === '') {
            return;
        }

        if (self::usesTokenColumn($db)) {
            $stmt = $db->prepare(
                'DELETE FROM core_admin_sessions WHERE token IN (:session_hash, :session_id) AND admin_id = :admin_id'
            );
        } else {
            $stmt = $db->prepare(
                'DELETE FROM core_admin_sessions WHERE id IN (:session_hash, :session_id) AND admin_id = :admin_id'
            );
        }

        $stmt->bindValue(':session_hash', self::hashToken($sessionToken), PDO::PARAM_STR);
        $stmt->bindValue(':session_id', $sessionToken, PDO::PARAM_STR);
        $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();
    }

    public static function revokeAllForAdmin(PDO $db, int $adminId): void
    {
        $stmt = $db->prepare('DELETE FROM core_admin_sessions WHERE admin_id = :admin_id');
        $stmt->bindValue(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();
    }
}
