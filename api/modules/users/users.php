<?php
/**
 * modules/users/users.php — CRUD Gestion des admins (superadmin uniquement)
 * 
 * GET    /api/admin/users           — Liste des admins avec leurs sites
 * POST   /api/admin/users           — Créer un admin + affecter sites
 * GET    /api/admin/users/{id}      — Détail admin
 * PUT    /api/admin/users/{id}      — Modifier (role, sites, is_active)
 * DELETE /api/admin/users/{id}      — Désactiver (soft : is_active = 0)
 * PUT    /api/admin/users/{id}/sites — MAJ sites accessibles
 */

function registerUsersRoutes(Router $router): void
{
    // ===== LISTE DES ADMINS =====
    $router->get('/api/admin/users', function () {
        Middleware::superadminOnly();
        $db = getDb();
        $pagination = Router::getPagination();

        $search = Router::getQueryParam('search');
        $role = Router::getQueryParam('role');

        $where = [];
        $params = [];

        if ($search) {
            $where[] = "(u.first_name LIKE :search OR u.last_name LIKE :search2 OR u.email LIKE :search3)";
            $params[':search'] = "%$search%";
            $params[':search2'] = "%$search%";
            $params[':search3'] = "%$search%";
        }
        if ($role) {
            $where[] = "u.role = :role";
            $params[':role'] = $role;
        }

        $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

        // Count
        $stmt = $db->prepare("SELECT COUNT(*) as total FROM core_admin_users u $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        // Fetch
        $stmt = $db->prepare(
            "SELECT u.id, u.email, u.first_name, u.last_name, u.role, u.avatar_url, u.is_active, u.last_login, u.created_at
             FROM core_admin_users u
             $whereClause
             ORDER BY u.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $users = $stmt->fetchAll();

        // Ajouter les sites pour chaque admin
        foreach ($users as &$user) {
            $stmt2 = $db->prepare(
                'SELECT s.id, s.name, s.slug, s.domain 
                 FROM core_sites s 
                 INNER JOIN core_admin_site_access asa ON s.id = asa.site_id 
                 WHERE asa.admin_id = :admin_id 
                 ORDER BY s.id'
            );
            $stmt2->bindParam(':admin_id', $user['id'], PDO::PARAM_INT);
            $stmt2->execute();
            $user['sites'] = $stmt2->fetchAll();
            $user['id'] = (int) $user['id'];
            $user['is_active'] = (bool) $user['is_active'];
        }

        Response::paginated($users, $total, $pagination['page'], $pagination['limit']);
    });

    // ===== CRÉER UN ADMIN =====
    $router->post('/api/admin/users', function () {
        $currentAdmin = Middleware::superadminOnly();
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('password', 'Password')
            ->minLength('password', 8, 'Password')
            ->required('first_name', 'First name')
            ->required('last_name', 'Last name')
            ->required('role', 'Role')
            ->in('role', ['superadmin', 'admin', 'editor', 'moderator', 'recruiter'], 'Role')
            ->validate();

        $db = getDb();

        // Vérifier unicité email
        $stmt = $db->prepare('SELECT id FROM core_admin_users WHERE email = :email LIMIT 1');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) {
            Response::badRequest('Email already exists');
            return;
        }

        // Créer l'admin
        $passwordHash = Auth::hashPassword($data['password']);
        $stmt = $db->prepare(
            'INSERT INTO core_admin_users (email, password_hash, first_name, last_name, role, avatar_url, is_active, created_at) 
             VALUES (:email, :password_hash, :first_name, :last_name, :role, :avatar_url, 1, NOW())'
        );
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindParam(':password_hash', $passwordHash, PDO::PARAM_STR);
        $stmt->bindParam(':first_name', $data['first_name'], PDO::PARAM_STR);
        $stmt->bindParam(':last_name', $data['last_name'], PDO::PARAM_STR);
        $stmt->bindParam(':role', $data['role'], PDO::PARAM_STR);
        $avatarUrl = $data['avatar_url'] ?? null;
        $stmt->bindParam(':avatar_url', $avatarUrl, PDO::PARAM_STR);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();

        // Affecter les sites
        if (!empty($data['site_ids']) && is_array($data['site_ids'])) {
            $stmtInsert = $db->prepare(
                'INSERT INTO core_admin_site_access (admin_id, site_id) VALUES (:admin_id, :site_id)'
            );
            foreach ($data['site_ids'] as $siteId) {
                $siteId = (int) $siteId;
                $stmtInsert->bindParam(':admin_id', $newId, PDO::PARAM_INT);
                $stmtInsert->bindParam(':site_id', $siteId, PDO::PARAM_INT);
                $stmtInsert->execute();
            }
        }

        // Audit
        Audit::log(
            (int) $currentAdmin['id'],
            null,
            'create',
            'admin_user',
            $newId,
            null,
            ['email' => $data['email'], 'role' => $data['role'], 'site_ids' => $data['site_ids'] ?? []]
        );

        Response::created(['id' => $newId], 'Admin user created successfully');
    });

    // ===== DÉTAIL ADMIN =====
    $router->get('/api/admin/users/{id}', function (array $params) {
        Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT id, email, first_name, last_name, role, avatar_url, is_active, last_login, created_at 
             FROM core_admin_users WHERE id = :id LIMIT 1'
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $user = $stmt->fetch();

        if (!$user) {
            Response::notFound('Admin user not found');
            return;
        }

        // Sites
        $stmt = $db->prepare(
            'SELECT s.id, s.name, s.slug, s.domain 
             FROM core_sites s 
             INNER JOIN core_admin_site_access asa ON s.id = asa.site_id 
             WHERE asa.admin_id = :admin_id 
             ORDER BY s.id'
        );
        $stmt->bindParam(':admin_id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $user['sites'] = $stmt->fetchAll();

        $user['id'] = (int) $user['id'];
        $user['is_active'] = (bool) $user['is_active'];

        Response::success($user);
    });

    // ===== MODIFIER ADMIN =====
    $router->put('/api/admin/users/{id}', function (array $params) {
        $currentAdmin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        // Récupérer l'ancien état
        $stmt = $db->prepare('SELECT * FROM core_admin_users WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $oldUser = $stmt->fetch();

        if (!$oldUser) {
            Response::notFound('Admin user not found');
            return;
        }

        // Valider les champs modifiables
        if (isset($data['role'])) {
            Validator::make($data)
                ->in('role', ['superadmin', 'admin', 'editor', 'moderator', 'recruiter'], 'Role')
                ->validate();
        }
        if (isset($data['email'])) {
            Validator::make($data)->email('email', 'Email')->validate();
            // Vérifier unicité
            $stmt = $db->prepare('SELECT id FROM core_admin_users WHERE email = :email AND id != :id LIMIT 1');
            $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            if ($stmt->fetch()) {
                Response::badRequest('Email already exists');
                return;
            }
        }

        // Construire la requête UPDATE dynamique
        $fields = [];
        $bindParams = [];

        $updatable = ['email', 'first_name', 'last_name', 'role', 'avatar_url', 'is_active'];
        foreach ($updatable as $field) {
            if (isset($data[$field])) {
                $fields[] = "$field = :$field";
                $bindParams[":$field"] = $data[$field];
            }
        }

        // Nouveau mot de passe ?
        if (!empty($data['password'])) {
            $fields[] = "password_hash = :password_hash";
            $bindParams[':password_hash'] = Auth::hashPassword($data['password']);
        }

        if (empty($fields)) {
            Response::badRequest('No fields to update');
            return;
        }

        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE core_admin_users SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        // MAJ sites si fournis
        if (isset($data['site_ids']) && is_array($data['site_ids'])) {
            $stmt = $db->prepare('DELETE FROM core_admin_site_access WHERE admin_id = :admin_id');
            $stmt->bindParam(':admin_id', $id, PDO::PARAM_INT);
            $stmt->execute();

            $stmtInsert = $db->prepare(
                'INSERT INTO core_admin_site_access (admin_id, site_id) VALUES (:admin_id, :site_id)'
            );
            foreach ($data['site_ids'] as $siteId) {
                $stmtInsert->bindValue(':admin_id', $id, PDO::PARAM_INT);
                $stmtInsert->bindValue(':site_id', (int) $siteId, PDO::PARAM_INT);
                $stmtInsert->execute();
            }
        }

        // Audit
        unset($oldUser['password_hash']);
        $newData = $data;
        unset($newData['password']);
        Audit::log((int) $currentAdmin['id'], null, 'update', 'admin_user', $id, $oldUser, $newData);

        Response::success(['id' => $id], 'Admin user updated successfully');
    });

    // ===== DÉSACTIVER ADMIN (soft delete) =====
    $router->delete('/api/admin/users/{id}', function (array $params) {
        $currentAdmin = Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];

        // Empêcher de se désactiver soi-même
        if ($id === (int) $currentAdmin['id']) {
            Response::badRequest('Cannot deactivate your own account');
            return;
        }

        $stmt = $db->prepare('SELECT id, email, role FROM core_admin_users WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $user = $stmt->fetch();

        if (!$user) {
            Response::notFound('Admin user not found');
            return;
        }

        // Soft delete : is_active = 0
        $stmt = $db->prepare('UPDATE core_admin_users SET is_active = 0, updated_at = NOW() WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        // Supprimer toutes les sessions
        $stmt = $db->prepare('DELETE FROM core_admin_sessions WHERE admin_id = :admin_id');
        $stmt->bindParam(':admin_id', $id, PDO::PARAM_INT);
        $stmt->execute();

        // Audit
        Audit::log((int) $currentAdmin['id'], null, 'deactivate', 'admin_user', $id, $user, ['is_active' => 0]);

        Response::success(null, 'Admin user deactivated');
    });

    // ===== MAJ SITES ACCESSIBLES =====
    $router->put('/api/admin/users/{id}/sites', function (array $params) {
        $currentAdmin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        if (!isset($data['site_ids']) || !is_array($data['site_ids'])) {
            Response::badRequest('site_ids array is required');
            return;
        }

        // Vérifier que l'admin existe
        $stmt = $db->prepare('SELECT id FROM core_admin_users WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) {
            Response::notFound('Admin user not found');
            return;
        }

        // Récupérer anciens sites
        $stmt = $db->prepare('SELECT site_id FROM core_admin_site_access WHERE admin_id = :admin_id');
        $stmt->bindParam(':admin_id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $oldSiteIds = array_column($stmt->fetchAll(), 'site_id');

        // Remplacer
        $stmt = $db->prepare('DELETE FROM core_admin_site_access WHERE admin_id = :admin_id');
        $stmt->bindParam(':admin_id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $stmtInsert = $db->prepare(
            'INSERT INTO core_admin_site_access (admin_id, site_id) VALUES (:admin_id, :site_id)'
        );
        foreach ($data['site_ids'] as $siteId) {
            $stmtInsert->bindValue(':admin_id', $id, PDO::PARAM_INT);
            $stmtInsert->bindValue(':site_id', (int) $siteId, PDO::PARAM_INT);
            $stmtInsert->execute();
        }

        // Audit
        Audit::log(
            (int) $currentAdmin['id'], null, 'update_sites', 'admin_user', $id,
            ['site_ids' => $oldSiteIds],
            ['site_ids' => $data['site_ids']]
        );

        Response::success(null, 'Site access updated');
    });
}
