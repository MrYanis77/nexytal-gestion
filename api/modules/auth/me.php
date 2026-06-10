<?php
/**
 * modules/auth/me.php — GET /api/admin/me
 * 
 * Retourne le profil de l'admin authentifié + sites accessibles.
 */

function registerAuthMeRoutes(Router $router): void
{
    $router->get('/api/admin/me', function () {
        $admin = Middleware::authenticate();
        $db = getDb();

        // Récupérer les sites accessibles
        if ($admin['role'] === 'superadmin') {
            $sites = getAllSites();
        } else {
            $stmt = $db->prepare(
                'SELECT s.id, s.name, s.slug, s.domain 
                 FROM core_sites s 
                 INNER JOIN core_admin_site_access asa ON s.id = asa.site_id 
                 WHERE asa.admin_id = :admin_id AND s.is_active = 1 
                 ORDER BY s.id'
            );
            $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
            $sites = $stmt->fetchAll();
        }

        Response::success([
            'id'         => (int) $admin['id'],
            'email'      => $admin['email'],
            'first_name' => $admin['first_name'],
            'last_name'  => $admin['last_name'],
            'role'       => $admin['role'],
            'avatar_url' => $admin['avatar_url'],
            'sites'      => $sites,
        ]);
    });
}
