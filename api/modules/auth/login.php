<?php
/**
 * modules/auth/login.php — POST /api/admin/login
 * 
 * Vérifie email/password, contrôle brute-force, génère JWT,
 * écrit session + last_login + activity_log.
 */

function registerAuthLoginRoutes(Router $router): void
{
    $router->post('/api/admin/login', function () {
        $data = Router::getJsonBody();

        // Validation — champ "email" = identifiant (ex: admin, admin@nexytal.com)
        Validator::make($data)
            ->required('email', 'Identifiant')
            ->required('password', 'Password')
            ->minLength('password', 6, 'Password')
            ->validate();

        $email = trim($data['email']);
        $password = $data['password'];

        // Anti brute-force
        RateLimit::check('login_failed');

        $db = getDb();

        // Chercher l'admin par email
        $stmt = $db->prepare(
            'SELECT id, email, password_hash, first_name, last_name, role, avatar_url, is_active 
             FROM core_admin_users 
             WHERE email = :email 
             LIMIT 1'
        );
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();
        $admin = $stmt->fetch();

        // Email non trouvé — message générique pour ne pas révéler l'existence du compte
        if (!$admin) {
            RateLimit::logAttempt('login_failed', null, 'auth');
            Response::unauthorized('Invalid email or password');
            return;
        }

        // Compte désactivé
        if (!$admin['is_active']) {
            RateLimit::logAttempt('login_failed', (int) $admin['id'], 'auth');
            Response::unauthorized('Account is deactivated');
            return;
        }

        // Vérifier le mot de passe
        if (!Auth::verifyPassword($password, $admin['password_hash'])) {
            RateLimit::logAttempt('login_failed', (int) $admin['id'], 'auth');
            Response::unauthorized('Invalid email or password');
            return;
        }

        // ===== Authentification réussie =====

        $adminId = (int) $admin['id'];
        $ip = RateLimit::getClientIp();
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';

        // Créer une session
        $sessionToken = Auth::generateRandomToken(64);
        $expiresAt = date('Y-m-d H:i:s', time() + JWT_EXPIRY);

        $stmt = $db->prepare(
            'INSERT INTO core_admin_sessions (admin_id, token, ip_address, user_agent, expires_at) 
             VALUES (:admin_id, :token, :ip, :user_agent, :expires_at)'
        );
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->bindParam(':token', $sessionToken, PDO::PARAM_STR);
        $stmt->bindParam(':ip', $ip, PDO::PARAM_STR);
        $stmt->bindParam(':user_agent', $userAgent, PDO::PARAM_STR);
        $stmt->bindParam(':expires_at', $expiresAt, PDO::PARAM_STR);
        $stmt->execute();
        $sessionId = (int) $db->lastInsertId();

        // Générer le JWT
        $jwt = Auth::generateToken([
            'sub'        => $adminId,
            'email'      => $admin['email'],
            'role'       => $admin['role'],
            'session_id' => $sessionId,
        ]);

        // Mettre à jour last_login
        $stmt = $db->prepare('UPDATE core_admin_users SET last_login = NOW() WHERE id = :id');
        $stmt->bindParam(':id', $adminId, PDO::PARAM_INT);
        $stmt->execute();

        // Log activité
        RateLimit::logAttempt('login_success', $adminId, 'auth', $sessionId);

        // Récupérer les sites accessibles
        $stmt = $db->prepare(
            'SELECT s.id, s.name, s.slug, s.domain 
             FROM core_sites s 
             INNER JOIN core_admin_site_access asa ON s.id = asa.site_id 
             WHERE asa.admin_id = :admin_id AND s.is_active = 1 
             ORDER BY s.id'
        );
        $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
        $stmt->execute();
        $sites = $stmt->fetchAll();

        // Si superadmin, donner accès à tous les sites
        if ($admin['role'] === 'superadmin') {
            $sites = getAllSites();
        }

        Response::success([
            'token' => $jwt,
            'admin' => [
                'id'         => $adminId,
                'email'      => $admin['email'],
                'first_name' => $admin['first_name'],
                'last_name'  => $admin['last_name'],
                'role'       => $admin['role'],
                'avatar_url' => $admin['avatar_url'],
            ],
            'sites'      => $sites,
            'expires_at' => $expiresAt,
        ], 'Login successful');
    });
}
