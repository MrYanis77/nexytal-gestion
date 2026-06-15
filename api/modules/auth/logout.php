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
            AdminSession::revoke($db, (string) $payload['session_id'], (int) $admin['id']);
        } else {
            AdminSession::revokeAllForAdmin($db, (int) $admin['id']);
        }

        // Log activité
        RateLimit::logAttempt('logout', (int) $admin['id'], 'auth');

        Response::success(null, 'Logged out successfully');
    });
}
