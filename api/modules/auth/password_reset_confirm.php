<?php
/**
 * modules/auth/password_reset_confirm.php — POST /api/admin/password-reset/confirm
 * 
 * Consomme un token de reset, met à jour le password_hash, marque le token used_at.
 */

function registerPasswordResetConfirmRoutes(Router $router): void
{
    $router->post('/api/admin/password-reset/confirm', function () {
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('token', 'Token')
            ->required('password', 'Password')
            ->minLength('password', 8, 'Password')
            ->validate();

        $token = trim($data['token']);
        $password = $data['password'];
        $db = getDb();

        // Vérifier le token
        $stmt = $db->prepare(
            'SELECT id, admin_id, expires_at, used_at 
             FROM core_password_reset_tokens 
             WHERE token = :token 
             LIMIT 1'
        );
        $stmt->bindParam(':token', $token, PDO::PARAM_STR);
        $stmt->execute();
        $resetToken = $stmt->fetch();

        if (!$resetToken) {
            Response::badRequest('Invalid or expired reset token');
            return;
        }

        // Vérifier si déjà utilisé
        if ($resetToken['used_at'] !== null) {
            Response::badRequest('This reset token has already been used');
            return;
        }

        // Vérifier l'expiration
        if (strtotime($resetToken['expires_at']) < time()) {
            Response::badRequest('Reset token has expired');
            return;
        }

        $adminId = (int) $resetToken['admin_id'];

        // Mettre à jour le mot de passe
        $passwordHash = Auth::hashPassword($password);
        $stmt = $db->prepare('UPDATE core_admin_users SET password_hash = :hash WHERE id = :id');
        $stmt->bindParam(':hash', $passwordHash, PDO::PARAM_STR);
        $stmt->bindParam(':id', $adminId, PDO::PARAM_INT);
        $stmt->execute();

        // Marquer le token comme utilisé
        $stmt = $db->prepare(
            'UPDATE core_password_reset_tokens SET used_at = NOW() WHERE id = :id'
        );
        $stmt->bindParam(':id', $resetToken['id'], PDO::PARAM_INT);
        $stmt->execute();

        // Invalider toutes les sessions existantes (forcer reconnexion)
        $stmt = $db->prepare('DELETE FROM core_admin_sessions WHERE admin_id = :admin_id');
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();

        // Log activité
        RateLimit::logAttempt('password_reset_confirm', $adminId, 'auth');

        // Audit
        Audit::log($adminId, null, 'password_reset', 'admin_user', $adminId, null, null);

        Response::success(null, 'Password has been reset successfully. Please login with your new password.');
    });
}
