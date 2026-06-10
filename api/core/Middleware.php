<?php
/**
 * core/Middleware.php — Middleware d'authentification et d'autorisation
 * 
 * Vérifie JWT, contrôle rôle admin, contrôle accès site.
 * Utilisé par tous les endpoints admin.
 */

class Middleware
{
    /** @var array|null Données de l'admin authentifié (cache par requête) */
    private static ?array $currentAdmin = null;

    /**
     * Authentifie l'admin via JWT.
     * Retourne les données admin ou arrête la requête (401).
     * 
     * @return array Données admin : id, email, role, first_name, last_name
     */
    public static function authenticate(): array
    {
        if (self::$currentAdmin !== null) {
            return self::$currentAdmin;
        }

        $token = Auth::extractToken();

        if ($token === null) {
            Response::unauthorized('Missing authentication token');
            exit;
        }

        $payload = Auth::verifyToken($token);

        if ($payload === false) {
            Response::unauthorized('Invalid or expired token');
            exit;
        }

        // Vérifier que l'admin existe toujours et est actif
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, email, first_name, last_name, role, avatar_url, is_active 
             FROM core_admin_users 
             WHERE id = :id AND is_active = 1 
             LIMIT 1'
        );
        $stmt->bindParam(':id', $payload['sub'], PDO::PARAM_INT);
        $stmt->execute();
        $admin = $stmt->fetch();

        if (!$admin) {
            Response::unauthorized('Account not found or deactivated');
            exit;
        }

        // Vérifier que la session existe toujours
        if (isset($payload['session_id'])) {
            $stmt = $db->prepare(
                'SELECT id FROM core_admin_sessions 
                 WHERE id = :id AND admin_id = :admin_id AND expires_at > NOW() 
                 LIMIT 1'
            );
            $stmt->bindParam(':id', $payload['session_id'], PDO::PARAM_INT);
            $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();

            if (!$stmt->fetch()) {
                Response::unauthorized('Session expired or revoked');
                exit;
            }
        }

        self::$currentAdmin = $admin;
        return $admin;
    }

    /**
     * Vérifie que l'admin a l'un des rôles requis.
     * Appelle authenticate() automatiquement.
     * 
     * @param array $allowedRoles Rôles autorisés (ex: ['superadmin', 'admin'])
     * @return array Données admin
     */
    public static function requireRole(array $allowedRoles): array
    {
        $admin = self::authenticate();

        // Le superadmin a toujours accès
        if ($admin['role'] === 'superadmin') {
            return $admin;
        }

        if (!in_array($admin['role'], $allowedRoles, true)) {
            Response::forbidden('Insufficient role. Required: ' . implode(', ', $allowedRoles));
            exit;
        }

        return $admin;
    }

    /**
     * Vérifie que l'admin a accès au site spécifié.
     * Le superadmin a accès à tous les sites.
     * 
     * @param int $siteId ID du site
     * @return array Données admin
     */
    public static function requireSiteAccess(int $siteId): array
    {
        $admin = self::authenticate();

        // Le superadmin a accès à tout
        if ($admin['role'] === 'superadmin') {
            return $admin;
        }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT 1 FROM core_admin_site_access 
             WHERE admin_id = :admin_id AND site_id = :site_id 
             LIMIT 1'
        );
        $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        if (!$stmt->fetch()) {
            Response::forbidden('No access to this site');
            exit;
        }

        return $admin;
    }

    /**
     * Raccourci : exige le rôle superadmin
     */
    public static function superadminOnly(): array
    {
        return self::requireRole(['superadmin']);
    }

    /**
     * Retourne l'admin courant sans ré-authentifier (ou null)
     */
    public static function getCurrentAdmin(): ?array
    {
        return self::$currentAdmin;
    }

    /**
     * Récupère les IDs des sites accessibles par l'admin courant
     * 
     * @return array Liste d'IDs de sites
     */
    public static function getAccessibleSiteIds(): array
    {
        $admin = self::authenticate();

        // Superadmin → tous les sites
        if ($admin['role'] === 'superadmin') {
            $db = getDb();
            $stmt = $db->query('SELECT id FROM core_sites WHERE is_active = 1');
            return array_column($stmt->fetchAll(), 'id');
        }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT site_id FROM core_admin_site_access WHERE admin_id = :admin_id'
        );
        $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
        $stmt->execute();

        return array_column($stmt->fetchAll(), 'site_id');
    }

    /**
     * Récupère le site_id depuis le header ou query param
     * Vérifie l'accès pour l'admin courant.
     * 
     * @return int Site ID validé
     */
    public static function requireSiteIdFromRequest(): int
    {
        $siteId = $_GET['site_id'] ?? $_SERVER['HTTP_X_SITE_ID'] ?? null;

        if ($siteId === null) {
            Response::badRequest('site_id is required (query param or X-Site-Id header)');
            exit;
        }

        $siteId = (int) $siteId;

        if ($siteId <= 0) {
            Response::badRequest('Invalid site_id');
            exit;
        }

        self::requireSiteAccess($siteId);

        return $siteId;
    }

    /**
     * Réinitialise le cache admin (pour les tests)
     */
    public static function reset(): void
    {
        self::$currentAdmin = null;
    }
}
