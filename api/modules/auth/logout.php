<?php
/**
 * modules/auth/logout.php — POST /api/admin/logout
 * 
 * Supprime la session active de l'admin.
 */

function registerAuthLogoutRoutes(Router $router): void
{
    $router->post('/api/admin/logout', function () {
        $admin = Middleware::authenticate();
        $db = getDb();

        // Extraire le token pour trouver la session
        $token = Auth::extractToken();
        $payload = Auth::verifyToken($token);

        if ($payload && isset($payload['session_id'])) {
            // Supprimer la session spécifique
            $stmt = $db->prepare(
                'DELETE FROM core_admin_sessions 
                 WHERE id = :session_id AND admin_id = :admin_id'
            );
            $stmt->bindParam(':session_id', $payload['session_id'], PDO::PARAM_INT);
            $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
        } else {
            // Supprimer toutes les sessions de l'admin (fallback)
            $stmt = $db->prepare('DELETE FROM core_admin_sessions WHERE admin_id = :admin_id');
            $stmt->bindParam(':admin_id', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
        }

        // Log activité
        RateLimit::logAttempt('logout', (int) $admin['id'], 'auth');

        Response::success(null, 'Logged out successfully');
    });
}
