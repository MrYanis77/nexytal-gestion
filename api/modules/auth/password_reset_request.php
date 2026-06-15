<?php
/**
 * modules/auth/password_reset_request.php — POST /api/admin/password-reset/request
 */

function registerPasswordResetRequestRoutes(Router $router): void
{
    $router->post('/api/admin/password-reset/request', function () {
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $email = trim($data['email']);
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, email, is_active FROM core_admin_users WHERE email = :email LIMIT 1'
        );
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();
        $admin = $stmt->fetch();

        if (!$admin || !$admin['is_active']) {
            Response::success(null, 'If this email exists, a password reset link has been sent');
            return;
        }

        $adminId = (int) $admin['id'];
        $token = Auth::generateRandomToken(64);
        $tokenHash = password_hash($token, PASSWORD_BCRYPT);
        $expiresAt = date('Y-m-d H:i:s', time() + 3600);

        $db->prepare('DELETE FROM core_admin_password_resets WHERE admin_id = :aid')->execute([':aid' => $adminId]);

        $stmt = $db->prepare(
            'INSERT INTO core_admin_password_resets (admin_id, token_hash, expires_at, created_at)
             VALUES (:admin_id, :token_hash, :expires_at, NOW())'
        );
        $stmt->execute([':admin_id' => $adminId, ':token_hash' => $tokenHash, ':expires_at' => $expiresAt]);

        RateLimit::logAttempt('password_reset_request', $adminId, 'auth');

        $responseData = null;
        if (APP_ENV === 'development') {
            $responseData = ['token' => $token, 'expires_at' => $expiresAt];
        }

        Response::success($responseData, 'If this email exists, a password reset link has been sent');
    });
}
