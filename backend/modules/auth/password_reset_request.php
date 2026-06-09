<?php
/**
 * modules/auth/password_reset_request.php — POST /api/admin/password-reset/request
 * 
 * Génère un token de reset, stocke dans core_password_reset_tokens,
 * log dans email_logs. L'envoi réel d'email est à configurer séparément.
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

        // Chercher l'admin
        $stmt = $db->prepare(
            'SELECT id, email, first_name, last_name, is_active 
             FROM core_admin_users 
             WHERE email = :email 
             LIMIT 1'
        );
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();
        $admin = $stmt->fetch();

        // Toujours répondre 200 même si l'email n'existe pas (sécurité)
        if (!$admin || !$admin['is_active']) {
            Response::success(null, 'If this email exists, a password reset link has been sent');
            return;
        }

        $adminId = (int) $admin['id'];

        // Invalider les anciens tokens non utilisés
        $stmt = $db->prepare(
            'UPDATE core_password_reset_tokens 
             SET used_at = NOW() 
             WHERE admin_id = :admin_id AND used_at IS NULL'
        );
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();

        // Générer un nouveau token
        $token = Auth::generateRandomToken(64);
        $expiresAt = date('Y-m-d H:i:s', time() + 3600); // Expire dans 1h

        $stmt = $db->prepare(
            'INSERT INTO core_password_reset_tokens (admin_id, token, expires_at, created_at) 
             VALUES (:admin_id, :token, :expires_at, NOW())'
        );
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->bindParam(':token', $token, PDO::PARAM_STR);
        $stmt->bindParam(':expires_at', $expiresAt, PDO::PARAM_STR);
        $stmt->execute();

        // Log dans email_logs (envoi simulé)
        $subject = 'Password Reset Request';
        $emailType = 'password_reset';
        $status = 'sent';

        $stmt = $db->prepare(
            'INSERT INTO email_logs (recipient_email, subject, email_type, status, created_at) 
             VALUES (:email, :subject, :email_type, :status, NOW())'
        );
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->bindParam(':subject', $subject, PDO::PARAM_STR);
        $stmt->bindParam(':email_type', $emailType, PDO::PARAM_STR);
        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        // Log activité
        RateLimit::logAttempt('password_reset_request', $adminId, 'auth');

        // En dev, retourner le token pour les tests
        $responseData = null;
        if (APP_ENV === 'development') {
            $responseData = ['token' => $token, 'expires_at' => $expiresAt];
        }

        Response::success($responseData, 'If this email exists, a password reset link has been sent');
    });
}
