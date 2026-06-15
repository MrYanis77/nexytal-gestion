<?php
/**
 * modules/auth/password_reset_confirm.php — POST /api/admin/password-reset/confirm
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

        $stmt = $db->prepare(
            'SELECT id, admin_id, token_hash, expires_at FROM core_admin_password_resets ORDER BY created_at DESC'
        );
        $stmt->execute();
        $rows = $stmt->fetchAll();

        $resetRow = null;
        foreach ($rows as $row) {
            if (password_verify($token, $row['token_hash'])) {
                $resetRow = $row;
                break;
            }
        }

        if (!$resetRow) {
            Response::badRequest('Invalid or expired reset token');
            return;
        }

        if (strtotime($resetRow['expires_at']) < time()) {
            Response::badRequest('Reset token has expired');
            return;
        }

        $adminId = (int) $resetRow['admin_id'];
        $passwordHash = Auth::hashPassword($password);

        $db->prepare('UPDATE core_admin_users SET password_hash = :hash WHERE id = :id')
            ->execute([':hash' => $passwordHash, ':id' => $adminId]);

        $db->prepare('DELETE FROM core_admin_password_resets WHERE admin_id = :aid')
            ->execute([':aid' => $adminId]);

        $db->prepare('DELETE FROM core_admin_sessions WHERE admin_id = :admin_id')
            ->execute([':admin_id' => $adminId]);

        RateLimit::logAttempt('password_reset_confirm', $adminId, 'auth');
        Audit::log($adminId, null, 'password_reset', 'admin_user', $adminId, null, null);

        Response::success(null, 'Password has been reset successfully. Please login with your new password.');
    });
}
